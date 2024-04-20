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

use DBD::SQLite::Constants ':dbd_sqlite_string_mode';

sub get_schema {
  my $class = shift;

  my @vars = qw(TE_DB_FILE);
  my @missing;

  foreach (@vars) {
    push @missing, $_ unless defined $ENV{$_};
  }

  if (@missing) {
    die "You need to define these environment variables: @missing\n";
  }

  my $dbh = $class->connect(
    "dbi:SQLite:database=$ENV{TE_DB_FILE}",
  ) or die;

#  $dbh->{sqlite_string_mode} = DBD_SQLITE_STRING_MODE_BYTES;

  return $dbh;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
