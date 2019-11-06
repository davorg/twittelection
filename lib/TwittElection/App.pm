package TwittElection::App;

use strict;
use warnings;
use 5.010;

use Moose;
use Log::Log4perl qw[:easy];
use LWP::Simple;
use Text::CSV_XS;
use DateTime;
use URI;

use TwittElection::Twitter;
use TwittElection::Schema;

has base_url => (
  is => 'ro',
  isa => 'URI',
  default => sub { URI->new('https//twittelection.co.uk') },
);

has election_date => (
  is => 'ro',
  isa => 'DateTime',
  default => sub { DateTime->new( year => 2019, month => 12, day => 12 ) },
);

has twitter => (
  is         => 'ro',
  isa        => 'TwittElection::Twitter',
  lazy_build => 1,
);

sub _build_twitter {
  my $t = TwittElection::Twitter->new(
    traits          => [ 'API::RESTv1_1', 'OAuth' ],
    ssl             => 1,
    consumer_key    => $ENV{TE_TW_API_KEY},
    consumer_secret => $ENV{TE_TW_API_SEC},
  );

  $t->authorise;

  return $t;
}

has schema => (
  is         => 'ro',
  isa        => 'TwittElection::Schema',
  lazy_build => 1,
);

sub _build_schema {
  return TwittElection::Schema->get_schema;
}

has constituency_rs => (
  is         => 'ro',
  isa        => 'DBIx::Class::ResultSet',
  lazy_build => 1,
);

sub _build_constituency_rs {
  return $_[0]->schema->resultset('Constituency');
}

has candidate_rs => (
  is         => 'ro',
  isa        => 'DBIx::Class::ResultSet',
  lazy_build => 1,
);

sub _build_candidate_rs {
  return $_[0]->schema->resultset('Candidate');
}

has csv_parser => (
  is         => 'ro',
  isa        => 'Text::CSV_XS',
  lazy_build => 1,
);

sub _build_csv_parser {
  return Text::CSV_XS->new({ binary => 1, auto_diag => 1 });
}

has verbose => (
  is         => 'ro',
  isa        => 'Bool',
  required   => 1,
  default    => 0,
);

has force => (
  is         => 'rw',
  isa        => 'Bool',
  required   => 1,
  default    => 0,
);

has logger => (
  is         => 'ro',
  isa        => 'Log::Log4perl::Logger',
  lazy_build => 1,
);

sub _build_logger {
  my $log_options = {
    level => $INFO,
    utf8  => 1,
  };

  $log_options->{level} = $TRACE if $_[0]->verbose;

  Log::Log4perl->easy_init($log_options);

  return Log::Log4perl->get_logger;
}

has data_filename => (
  is         => 'ro',
  isa        => 'Str',
  lazy_build => 1,
);

sub _build_data_filename {
  my $self = shift;
  return 'candidates-parl.' . $self->election_date->ymd . '.csv';
}

has data_url => (
  is         => 'ro',
  isa        => 'URI',
  lazy_build => 1,
);

sub _build_data_url {
  my $self = shift;

  return URI->new('https://candidates.democracyclub.org.uk/media/' .
                  $self->data_filename);
}

has data_fh => (
  is         => 'ro',
  isa        => 'FileHandle',
  lazy_build => 1,
);

sub _build_data_fh {
  my $self = shift;

  $self->get_file;

  open my $fh, '<', $self->data_filename or die $!;

  return $fh;
}

has has_changed => (
  is       => 'rw',
  isa      => 'Bool',
  required => 1,
  default  => 0,
);

sub get_file {
  my $self = shift;

  getstore($self->data_url, $self->data_filename);
}

sub get_data_line {
  my $self = shift;

  my $csv_parser = $self->csv_parser;

  return $csv_parser->getline($self->data_fh);
}

1;
