use strict;
use Test::More;
use IO::Socket;
use Net::SMTP;

plan tests => 10;
use_ok('Net::Server::Mail::SMTP');

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
        my $m = Net::Server::Mail::SMTP->new(
          socket       => $conn,
          idle_timeout => 5
        ) or die "can't start server on port 2525";
        $m->process;
    }
}

my $smtp = Net::SMTP->new( "localhost:$server_port", Debug => 0 );
ok( defined $smtp );

ok( $smtp->mail("test\@bla.com") );
ok( !$smtp->mail("test\@bla.com") );
ok( $smtp->to('postmaster') );
ok( $smtp->to('postmaster') );
ok( $smtp->data );
ok( $smtp->datasend('To: postmaster') );
ok( $smtp->dataend );
ok( $smtp->quit );

kill 1, $pid;
wait;
