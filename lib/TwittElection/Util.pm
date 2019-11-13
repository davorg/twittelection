package TwittElection::Util;

use strict;
use warnings;

use parent 'Exporter';
our @EXPORT_OK = qw[partition_hash];

sub partition_hash {
  my ($hash1, $hash2) = @_;
  
  my ($one_not_two, $both, $two_not_one) = ({}, {}, {});
  
  for (keys %$hash1) {
    if (exists $hash2->{$_}) {
      $both->{$_} = [ $hash1->{$_}, $hash2->{$_} ];
    } else {
      $one_not_two->{$_} = $hash1->{$_};
    }
  }
  
  for (keys %$hash2) {
    next if exists $both->{$_};
    $two_not_one->{$_} = $hash2->{$_};
  }
  
  return ($one_not_two, $both, $two_not_one);
}

1;
