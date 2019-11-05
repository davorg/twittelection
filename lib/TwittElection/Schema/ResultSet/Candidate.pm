package TwittElection::Schema::ResultSet::Candidate;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use TwittElection::Constants;

sub filter_tweeting {
  my $self = shift;

  return $self->search({
    twitter => { '!=' => '' },
  });
}

sub filter_nontweeting {
  my $self = shift;

  return $self->search({
    twitter => '',
  });
}

sub filter_protected {
  my $self = shift;

  return $self->search({
    twitter_problem => TWITTER_ACCT_PROTECTED,
  });
}

sub filter_blocked {
  my $self = shift;

  return $self->search({
    twitter_problem => TWITTER_ACCT_BLOCKED,
  });
}

1;
