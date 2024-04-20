use utf8;
package TwittElection::Schema::Result::Candidate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TwittElection::Schema::Result::Candidate

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<candidate>

=cut

__PACKAGE__->table("candidate");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 yournextmp_id

  data_type: 'int'
  is_nullable: 0
  size: 11

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 twitter

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 200

=head2 party_id

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0
  size: 11

=head2 constituency_id

  data_type: 'int'
  default_value: null
  is_foreign_key: 1
  is_nullable: 1
  size: 11

=head2 current_mp

  data_type: 'int'
  default_value: 0
  is_nullable: 0
  size: 11

=head2 twitter_problem

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0
  size: 6

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "yournextmp_id",
  { data_type => "int", is_nullable => 0, size => 11 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "twitter",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 200,
  },
  "party_id",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0, size => 11 },
  "constituency_id",
  {
    data_type => "int",
    default_value => \"null",
    is_foreign_key => 1,
    is_nullable => 1,
    size => 11,
  },
  "current_mp",
  { data_type => "int", default_value => 0, is_nullable => 0, size => 11 },
  "twitter_problem",
  { data_type => "smallint", default_value => 0, is_nullable => 0, size => 6 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<yournextmp_id_unique>

=over 4

=item * L</yournextmp_id>

=back

=cut

__PACKAGE__->add_unique_constraint("yournextmp_id_unique", ["yournextmp_id"]);

=head1 RELATIONS

=head2 constituency

Type: belongs_to

Related object: L<TwittElection::Schema::Result::Constituency>

=cut

__PACKAGE__->belongs_to(
  "constituency",
  "TwittElection::Schema::Result::Constituency",
  { id => "constituency_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 party

Type: belongs_to

Related object: L<TwittElection::Schema::Result::Party>

=cut

__PACKAGE__->belongs_to(
  "party",
  "TwittElection::Schema::Result::Party",
  { id => "party_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-04-20 15:48:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jFbSO9BGSq+lZdoTmGr5sw

sub dump {
  my $self = shift;
  my $delim = $_[0] || "\t";

  return join $delim, $self->name, $self->yournextmp_id, $self->twitter,
                      $self->party->yournextmp_id,
                      $self->constituency->mapit_id;
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
