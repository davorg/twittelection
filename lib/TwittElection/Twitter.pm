package TwittElection::Twitter;

use strict;
use warnings;

use parent 'Net::Twitter';

use constant TOKEN_FILE => '.te_tokens';

sub authorise {
  my $self = shift;

  my ($access_token, $access_token_secret) = restore_tokens();

  if ( $access_token && $access_token_secret ) {
    $self->access_token($access_token);
    $self->access_token_secret($access_token_secret);
  }

  unless ( $self->authorized ) {
    # The client is not yet authorized: Do it now
    print "Authorize this app at ", $self->get_authorization_url,
          " and enter the PIN#\n";

    my $pin = <STDIN>; # wait for input
    chomp $pin;

    ($access_token, $access_token_secret) =
      $self->request_access_token(verifier => $pin);
    save_tokens($access_token, $access_token_secret); # if necessary
  }
}

sub save_tokens {
  my ($access_token, $access_token_secret) = @_;

  open my $tw_fh, '>', TOKEN_FILE or die $!;
  print $tw_fh "$access_token $access_token_secret";
}

sub restore_tokens {
  if (! -f TOKEN_FILE) {
    return (undef, undef);
  }  
  open my $tw_fh, '<', TOKEN_FILE or die $!;

  my $tokens = <$tw_fh>;

  return split / /, $tokens;
}

1;
