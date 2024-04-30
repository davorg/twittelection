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

=head2 three_code

  data_type: 'char'
  default_value: 0
  is_nullable: 0
  size: 3

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 region

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 nation

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 list_name

  data_type: 'varchar'
  is_nullable: 0
  size: 25

=head2 list_id

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 20

=head2 candidates_updated_time

  data_type: 'datetime'
  default_value: '2000-01-01 00:00:00'
  is_nullable: 0

=head2 list_rebuilt_time

  data_type: 'datetime'
  default_value: '2000-01-01 00:00:00'
  is_nullable: 0

=head2 list_checked_time

  data_type: 'datetime'
  default_value: null
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "three_code",
  { data_type => "char", default_value => 0, is_nullable => 0, size => 3 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "region",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "nation",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "list_name",
  { data_type => "varchar", is_nullable => 0, size => 25 },
  "list_id",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 20,
  },
  "candidates_updated_time",
  {
    data_type     => "datetime",
    default_value => "2000-01-01 00:00:00",
    is_nullable   => 0,
  },
  "list_rebuilt_time",
  {
    data_type     => "datetime",
    default_value => "2000-01-01 00:00:00",
    is_nullable   => 0,
  },
  "list_checked_time",
  { data_type => "datetime", default_value => \"null", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_unique", ["name"]);

=head2 C<three_code_unique>

=over 4

=item * L</three_code>

=back

=cut

__PACKAGE__->add_unique_constraint("three_code_unique", ["three_code"]);

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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-04-30 15:00:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mv8nlkFMGjCb8FqXr3vrdA

# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Moose;
with 'TwittElection::Role::WithLists';

use LWP::Simple;
use JSON;

sub retrieve_candidates {
  my $self = shift;

  my $url = 'https://candidates.democracyclub.org.uk/api/v0.9/posts/' .
            $self->api_id;

  my $json = get($url);

  my $data = decode_json $json;
  return $data->{memberships};
}

sub describe {
  my $self = shift;

  return $self->name . ' (' . $self->mapit_id . ')';
}

sub slug_name {
  my $self = shift;

  my $slug = $self->list_name;
  $slug =~ s/-\d+$//;

  return $slug;
}

sub api_id {
  my $self = shift;

  my $api_id = 'WMC' . $self->demclub_id;

  return $api_id;
}

sub demclub_url {
  my $self = shift;

  # TODO: Get the date from the app class
  return 'https://candidates.democracyclub.org.uk/elections/parl.' .
    $self->list_name . '.2019-12-12';
}

sub tweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_tweeting;
}

sub non_tweeting_candidates {
  my $self = shift;

  return $self->candidates->filter_nontweeting;
}

sub url {
  my $self = shift;

  return 'https://twittelection.co.uk/c/' . $self->slug_name . '.html';
}

__PACKAGE__->meta->make_immutable;
1;
