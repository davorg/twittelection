package TwittElection::Twitter;

use Moose;
extends 'Net::Twitter';

use DateTime;
use Try::Tiny;
use Scalar::Util qw[blessed];
use TwittElection::Constants;

sub authorise {
  my $self = shift;

  my($access_token, $access_token_secret) = restore_tokens();

  if ($access_token && $access_token_secret) {
    $self->access_token($access_token);
    $self->access_token_secret($access_token_secret);
  }

  unless ( $self->authorized ) {
    # The client is not yet authorized: Do it now
    print "Authorize this app at ", $self->get_authorization_url,
          " and enter the PIN#\n";
     
    my $pin = <STDIN>; # wait for input
    chomp $pin;
               
    my($access_token, $access_token_secret, $user_id, $screen_name) =
      $self->request_access_token(verifier => $pin);
    save_tokens($access_token, $access_token_secret); # if necessary
  }
}

sub save_tokens {
  my ($access_token, $access_token_secret) = @_;

  open my $tw_fh, '>', '.te_tokens' or die $!;
  print $tw_fh "$access_token $access_token_secret";
}

sub restore_tokens {
  if (! -f '.te_tokens') {
    return (undef, undef);
  }  
  open my $tw_fh, '<', '.te_tokens' or die $!;

  my $tokens = <$tw_fh>;

  return split / /, $tokens;
}

sub maintain_lists {
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
  my ($app, $rs) = @_;

  my %problems;

  foreach my $obj ($rs->all) {
    $app->logger->info($obj->name . ' (' . $obj->mapit_id . ')');

    unless ($app->force or $obj->candidates->count) {
      $app->logger->info('No candidates found');
      next;
    }

    unless ($app->force) {
      if ($obj->candidates_updated_time <= $obj->list_rebuilt_time) {
        $app->logger->info('No need to rebuild list');
        next;
      }

      if ($app->delay and $obj->list_rebuilt_time > DateTime->now->subtract(days=>1)) {
        $app->logger->info('List rebuilt too recently');
        next;
      }
    }

    my $list;
    my (%not_on_twitter, %on_both, %extra_on_twitter);
    try {
      if ($obj->list_id) {
        $app->logger->info('Looking for list ', $obj->list_name);
        try {
          $list = $self->show_list({
            owner_screen_name => 'twittelection',
            slug              => $obj->list_name,
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
          foreach my $mem (@{$self->list_members({ list_id => $list->{id} })->{users}}) {
            $extra_on_twitter{$mem->{screen_name}} = 1;
          }
        } else {
          $app->logger->info('Create ' . $obj->name);
          $list = $self->create_list({
            owner_screen_name => 'twittelection',
            description       => $obj->name,
            name              => $obj->abbrev_name,
          });

          $app->logger->info($list->{slug});

          $obj->update({
            list_name => $list->{slug},
            list_id   => $list->{id},
          });
        }
      } else {
        $app->logger->info('Create ' . $obj->name);
        $list = $self->create_list({
          owner_screen_name => 'twittelection',
          description       => $obj->name,
          name              => $obj->abbrev_name,
        });

        $app->logger->info($list->{slug});

        # Remove the number that Twitter will sometimes add at the end
        $list->{slug} =~ s/-\d+$//;

        $obj->update({
          list_name => $list->{slug},
          list_id   => $list->{id},
        });
      }

      foreach my $cand ($obj->candidates) {
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
          $self->add_list_member({
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

          push @{$problems{$err->twitter_error_code}}, $tw;

          $app->logger->warn($err->twitter_error_code . ': ' .
                             $err->twitter_error_text);
        }
      }

      foreach (keys %extra_on_twitter) {
        $app->logger->info("Removing list member: $_");
        $self->remove_list_members({
          list_id     => $list->{id},
          screen_name => $_,
        });
      }

      $obj->update({
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
        exit;
      } else {
        return;
      }
    }
  }

  if (keys %problems) {
    foreach (keys %problems) {
      $app->candidate_rs->search({
        twitter => $problems{$_},
      })->update({
        twitter_problem => $_,
      });
    }
  }
}

1;
