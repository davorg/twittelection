package TwittElection::Role::WithLists;

use Moose::Role;

use DateTime;
use Try::Tiny;
use Scalar::Util qw[blessed];
use TwittElection::Constants;

requires qw[name describe candidates candidates_updated_time
            list_rebuilt_time update list_name list_id];

sub maintain_list {
  # Here's how this should work.
  #
  # IF constit has a list id and that list exists
  #   Delete all members
  # ELSE
  #   Create new list
  #   Update list name and list id
  # END
  #
  # Insert list members

  # Twitter rate limits (https://dev.twitter.com/rest/public/rate-limits)
  # show_list : 15 / 15 min
  # list_members : 15 / 15 min
  # remove_list_members :
  # create_list :
  # add_list_member :

  # Some thoughts about a more intelligent approach.
  # Add a 'list_updated_timestamp' column to constituency table.
  # Only attempt to rebuild list if
  #   candidates_updated timestamp > list_updated_timestamp
  # Get current list members and current candidate list.
  # Only attempt to rebuild Twitter list if these lists differ.
  # Update list_updated_timestamp when we update Twitter list.
  #
  # Also, need to think about Twitter rate limiting.
  # Stop working as soon as we get a rate exceeded response.

  my $self = shift;
  my ($app) = @_;
  
  my $t = $app->twitter;

  $app->logger->info($self->describe);

  unless ($app->force) {
    unless ($self->candidates->count) {
      $app->logger->info('No candidates found');
      return;
    }

    if ($self->candidates_updated_time <= $self->list_rebuilt_time) {
      $app->logger->info('No need to rebuild list');
      return;
    }

    if ($app->delay and $self->list_rebuilt_time > DateTime->now->subtract(days=>1)) {
      $app->logger->info('List rebuilt too recently');
      return;
    }
  }

  my $list;
  my (%not_on_twitter, %on_both, %extra_on_twitter);
  try {
    if ($self->list_id) {
      $app->logger->info('Looking for list ', $self->list_name);
      try {
        $list = $t->show_list({
          owner_screen_name => 'twittelection',
          slug              => $self->list_name,
        });
      } catch {
        if ($_->code == 404) {
          $list = undef;
        } else {
          die $_;
        }
      };
      if ($list) {
        $app->logger->info("Found list: $list->{id}");
        foreach my $mem (@{$t->list_members({ list_id => $list->{id} })->{users}}) {
          $extra_on_twitter{$mem->{screen_name}} = 1;
        }
      } else {
        $app->logger->info('Create list for ' . $self->name);
        $list = $t->create_list({
          owner_screen_name => 'twittelection',
          description       => $self->name,
          name              => $self->abbrev_name,
        });

        $app->logger->info('Created list: ', $list->{slug});

        $self->update({
          list_name => $list->{slug},
          list_id   => $list->{id},
        });
      }
    } else {
      $app->logger->info('Create list for ' . $self->name);
      $list = $t->create_list({
        owner_screen_name => 'twittelection',
        description       => $self->name,
        name              => $self->abbrev_name,
      });

      $app->logger->info('Created list: ', $list->{slug});

      # Remove the number that Twitter will sometimes add at the end
      $list->{slug} =~ s/-\d+$//;

      $self->update({
        list_name => $list->{slug},
        list_id   => $list->{id},
      });
    }

    foreach my $cand ($self->candidates) {
      next unless $cand->twitter;
      $app->logger->info("$list->{id} -> " . $cand->name . ' / ' . $cand->twitter);

      if (exists $extra_on_twitter{$cand->twitter}) {
        delete $extra_on_twitter{$cand->twitter};
        $on_both{$cand->twitter} = 1;
      } else {
        $not_on_twitter{$cand->twitter} = 1;
      }
    }

    foreach my $tw (keys %not_on_twitter) {
      try {
        $app->logger->info("Adding list member: $tw");
        $t->add_list_member({
          list_id     => $list->{id},
          screen_name => $tw,
        });
      } catch {
        my $err = $_;
        die $_ unless blessed $err and $err->isa('Net::Twitter::Error');
        die $_ unless $err->has_twitter_error;

        # 104 and 106 means the user has blocked you
        # 108 means you're trying to add a non-existent user to a list
        die $_ unless $err->twitter_error_code == TWITTER_ACCT_PROTECTED or
                      $err->twitter_error_code == TWITTER_ACCT_BLOCKED or
                      $err->twitter_error_code == TWITTER_LIST_MISSING;

        my $cand = $app->candidate_rs->find({ twitter => $tw });

        unless ($cand) {
          $app->logger->warn("Can't find candidate: $tw");
          next;
        }

        $cand->update({
          twitter_problem => $err->twitter_error_code,
        });

        $app->logger->warn($err->twitter_error_code . ': ' .
                           $err->twitter_error_text);
      }
    }

    foreach (keys %extra_on_twitter) {
      $app->logger->info("Removing list member: $_");
      $t->remove_list_members({
        list_id     => $list->{id},
        screen_name => $_,
      });
    }

    $self->update({
      list_rebuilt_time => DateTime->now,
    });
  } catch {
    my $err = $_;
    $app->logger->logdie($err)
      unless blessed $err and $err->isa('Net::Twitter::Error');
    $app->logger->warn($err->code . ': ' . $err->error . ' (' .
                       $err->message . ')');
    if ($err->has_twitter_error) {
      $app->logger->warn($err->twitter_error_code . ': ' .
                         $err->twitter_error_text);
    }
    if ($err->code == 429 or $err->code == 403) {
      $app->logger->error('Rate limit exceeded');
      die;
    } else {
      return;
    }
  }
}

# List names can't be longer than 25 characters
sub abbrev_name {
  my $self = shift;

  return substr($self->name, 0, 25);
}

1;
