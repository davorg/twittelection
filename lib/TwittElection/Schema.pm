use utf8;
package TwittElection::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-08-15 20:12:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:POtcyUDJVg5/NGxsfXb2fQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub get_schema {
  my $class = shift;

  my @vars = qw(TE_HOST TE_DB TE_USER TE_PASS);
  my @missing;

  foreach (@vars) {
    push @missing, $_ unless defined $ENV{$_};
  }

  if (@missing) {
    die "You need to define this environment variables: @missing\n";
  }

  return $class->connect(
    "dbi:mysql:database=$ENV{TE_DB}:host=$ENV{TE_HOST}",
    $ENV{TE_USER}, $ENV{TE_PASS},
    { mysql_enable_utf8 => 1 },  
  ) or die;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
