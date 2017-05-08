package TwittElection::App;

use strict;
use warnings;
use 5.010;

use Moose;

use TwittElection::Twitter;
use TwittElection::Schema;

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

has logger => (
  is         => 'ro',
  isa        => 'Log::Log4perl::Logger',
  lazy_build => 1,
);

1;
