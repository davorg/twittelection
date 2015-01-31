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

1;