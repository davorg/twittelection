package TwittElection::Schema::ResultSet::Candidate;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

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
    twitter_problem => 104,
  });
}

1;
