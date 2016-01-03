use strict;
use Test::More;
use IO::Socket;

plan tests => 10;

eval('use Net::LMTP');
SKIP: {

    if ($@) {
        skip( "You don't seem to have Net::LMTP installed on your system", 10 );
    }
    else{
    use_ok('Net::Server::Mail::LMTP');

    my $server_port = 2525;
    my $server;

    while ( not defined $server && $server_port < 4000 ) {
        $server = IO::Socket::INET->new(
            Listen    => 1,
            LocalPort => ++$server_port,
        );
    }

    my $pid = fork;
    if ( !$pid ) {
        while ( my $conn = $server->accept ) {
            my $m = Net::Server::Mail::LMTP->new(
              socket       => $conn,
              idle_timeout => 5
            ) or die "can't start server on port 2525";
            $m->set_callback( 'DATA', sub { return $_[1] !~ /bad/ } );
            $m->process;
        }
      SKIP: {
            skip( 'This is the son', 10 );
        }
    }

    my $lmtp = Net::LMTP->new( 'localhost', $server_port, Debug => 0 );
    ok( defined $lmtp );

    ok( $lmtp->mail("test\@bla.com") );
    ok( !$lmtp->mail("test\@bla.com") );
    ok( $lmtp->to('bad') );
    ok( $lmtp->to('postmaster') );
    ok( $lmtp->data );
    ok( $lmtp->datasend('To: postmaster') );
    ok( $lmtp->dataend );
    ok( $lmtp->quit );

    kill 1, $pid;
    wait;
    }
}
