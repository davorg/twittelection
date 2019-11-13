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

use constant {
  COL_CAND_ID      => 0,
  COL_CAND_NAME    => 1,
  COL_CAND_TWITTER => 14,
  COL_CONSTIT_ID   => 9,
  COL_CONSTIT_NAME => 10,
  COL_PARTY_ID     => 7,
  COL_PARTY_NAME   => 8,
};

our @EXPORT = qw[
  TWITTER_ACCT_PROTECTED
  TWITTER_ACCT_BLOCKED
  TWITTER_LIST_MISSING

  COL_CAND_ID
  COL_CAND_NAME
  COL_CAND_TWITTER
  COL_CONSTIT_ID
  COL_CONSTIT_NAME
  COL_PARTY_ID
  COL_PARTY_NAME
];

1;
