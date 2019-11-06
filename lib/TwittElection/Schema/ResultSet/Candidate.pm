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

sub sort_by_name {
  my $self  = shift;
  my $where = $_[0] // {};
  my $opts  = $_[1] // {};

  $opts->{order_by} = 'name';

  return $self->search($where, $opts);
}

1;
