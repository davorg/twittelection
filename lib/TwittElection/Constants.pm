package TwittElection::Constants;

use strict;
use warnings;

require Exporter;
our @ISA = qw[Exporter];

use constant {
  TWITTER_ACCT_PROTECTED => 104,
  TWITTER_ACCT_BLOCKED   => 106,
  TWITTER_LIST_MISSING   => 108,
};

our @EXPORT = qw[
  TWITTER_ACCT_PROTECTED
  TWITTER_ACCT_BLOCKED
  TWITTER_LIST_MISSING
];

1;
