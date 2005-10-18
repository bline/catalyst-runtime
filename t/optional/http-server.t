#!perl

use strict;
use warnings;

use File::Path;
use FindBin;
use IO::Socket;
use Test::More;
eval "use File::Copy::Recursive";

plan skip_all => 'set TEST_HTTP to enable this test' unless $ENV{TEST_HTTP};
plan skip_all => 'File::Copy::Recursive required' if $@;
plan tests => 1;

# clean up
rmtree "$FindBin::Bin/../../t/var" if -d "$FindBin::Bin/../../t/var";

# create a TestApp and copy the test libs into it
mkdir "$FindBin::Bin/../../t/var";
chdir "$FindBin::Bin/../../t/var";
system "$FindBin::Bin/../../script/catalyst.pl TestApp";
chdir "$FindBin::Bin/../..";
File::Copy::Recursive::dircopy( 't/live/lib', 't/var/TestApp/lib' );

# spawn the standalone HTTP server
my $port = 30000 + int rand(1 + 10000);
my $pid = open my $server, 
    "$FindBin::Bin/../../t/var/TestApp/script/testapp_server.pl -port $port 2>&1 |"
    or die "Unable to spawn standalone HTTP server: $!";

# wait for it to start
print "Waiting for server to start...\n";
while ( check_port( 'localhost', $port ) != 1 ) {
    sleep 1;
}
    
# run the testsuite against the HTTP server
$ENV{CATALYST_SERVER} = "http://localhost:$port";
system( 'prove -r -Ilib/ t/live/' );

# shut it down
kill 2, $pid;
close $server;

# clean up
rmtree "$FindBin::Bin/../../t/var" if -d "$FindBin::Bin/../../t/var";

ok( 'done' );

sub check_port {
    my ( $host, $port ) = @_;

    my $remote = IO::Socket::INET->new(
        Proto    => "tcp",
        PeerAddr => $host,
        PeerPort => $port
    );
    if ($remote) {
        close $remote;
        return 1;
    }
    else {
        return 0;
    }
}
