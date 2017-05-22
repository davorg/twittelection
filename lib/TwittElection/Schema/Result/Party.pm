use utf8;
package TwittElection::Schema::Result::Party;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TwittElection::Schema::Result::Party

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

=head1 TABLE: C<party>

=cut

__PACKAGE__->table("party");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 yournextmp_id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "yournextmp_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 200 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<yournextmp_id>

=over 4

=item * L</yournextmp_id>

=back

=cut

__PACKAGE__->add_unique_constraint("yournextmp_id", ["yournextmp_id"]);

=head1 RELATIONS

=head2 candidates

Type: has_many

Related object: L<TwittElection::Schema::Result::Candidate>

=cut

__PACKAGE__->has_many(
  "candidates",
  "TwittElection::Schema::Result::Candidate",
  { "foreign.party_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-01-11 19:53:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AcBediHPwiMDFwtJHot2+Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub slugname {
  my $self = shift;

  my $slug = lc $self->name;
  $slug =~ s/\W+/-/g;

  return $slug;
}

sub count_blocking_candidates {
  my $self = shift;

  return $self->candidates->filter_blocked->count;
}

sub count_protected_candidates {
  my $self = shift;

  return $self->candidates->filter_protected->count;
}

sub blocking_candidates {
  my $self = shift;

  return $self->candidates->filter_blocked;
}

sub protected_candidates {
  my $self = shift;

  return $self->candidates->filter_protected;
}

sub count_tweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_tweeting->count;
}

sub count_nontweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_nontweeting->count;
}

sub tweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_tweeting;
}

sub nontweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_nontweeting;
}

sub count_candidates {
  my $self = shift;

  return $self->candidates->count;
}

__PACKAGE__->meta->make_immutable;
1;
