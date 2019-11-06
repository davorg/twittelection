package TwittElection::Schema::ResultSet::Party;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub sort_by_name {
  my $self  = shift;
  my $where = $_[0] // {};
  my $opts  = $_[1] // {};

  $opts->{order_by} = 'name';

  return $self->search($where, $opts);
}

1;

