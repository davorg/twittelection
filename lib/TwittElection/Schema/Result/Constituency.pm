use utf8;
package TwittElection::Schema::Result::Constituency;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TwittElection::Schema::Result::Constituency

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

=head1 TABLE: C<constituency>

=cut

__PACKAGE__->table("constituency");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 mapit_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 list_name

  data_type: 'varchar'
  is_nullable: 0
  size: 25

=head2 list_id

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 candidates_updated_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '2000-01-01 00:00:00'
  is_nullable: 0

=head2 list_rebuilt_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '2000-01-01 00:00:00'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "mapit_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "list_name",
  { data_type => "varchar", is_nullable => 0, size => 25 },
  "list_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "candidates_updated_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "2000-01-01 00:00:00",
    is_nullable => 0,
  },
  "list_rebuilt_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "2000-01-01 00:00:00",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<mapit_id>

=over 4

=item * L</mapit_id>

=back

=cut

__PACKAGE__->add_unique_constraint("mapit_id", ["mapit_id"]);

=head1 RELATIONS

=head2 candidates

Type: has_many

Related object: L<TwittElection::Schema::Result::Candidate>

=cut

__PACKAGE__->has_many(
  "candidates",
  "TwittElection::Schema::Result::Candidate",
  { "foreign.constituency_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-01-14 11:25:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ntUlTTvAvlxD9DtwUsf9vg

# You can replace this text with custom code or comments, and it will be preserved on regeneration

use LWP::Simple;
use JSON;

sub retrieve_candidates {
  my $self = shift;

  my $url = 'http://yournextmp.popit.mysociety.org/api/v0.1/posts/' .
            $self->mapit_id .
            '?embed=membership.person';

  my $json = get($url);

  my $data = decode_json $json;
  return $data->{result}{memberships};
}

sub slug_name {
  my $self = shift;

  my $slug = $self->list_name;
  $slug =~ s/-\d+$//;

  return $slug;
}

# List names can't be longer than 25 characters
sub abbrev_name {
  my $self = shift;

  return substr($self->name, 0, 25);
}

sub tweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_tweeting;
}

sub non_tweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_nontweeting;
}
__PACKAGE__->meta->make_immutable;
1;
