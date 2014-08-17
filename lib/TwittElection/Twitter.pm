package TwittElection::Twitter;

use Moose;
extends 'Net::Twitter';

sub authorise {
  my $self = shift;

  my($access_token, $access_token_secret) = restore_tokens();

  if ($access_token && $access_token_secret) {
    $self->access_token($access_token);
    $self->access_token_secret($access_token_secret);
  }

  unless ( $self->authorized ) {
    # The client is not yet authorized: Do it now
    print "Authorize this app at ", $self->get_authorization_url,
          " and enter the PIN#\n";
     
    my $pin = <STDIN>; # wait for input
    chomp $pin;
               
    my($access_token, $access_token_secret, $user_id, $screen_name) =
      $self->request_access_token(verifier => $pin);
    save_tokens($access_token, $access_token_secret); # if necessary
  }
}

sub save_tokens {
  my ($access_token, $access_token_secret) = @_;

  open my $tw_fh, '>', '.te_tokens' or die $!;
  print $tw_fh "$access_token $access_token_secret";
}

sub restore_tokens {
  open my $tw_fh, '<', '.te_tokens' or die $!;

  my $tokens = <$tw_fh>;

  return split / /, $tokens;
}

1;