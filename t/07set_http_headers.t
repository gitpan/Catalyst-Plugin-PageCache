#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use File::Path;

BEGIN {
    eval "use Catalyst::Plugin::Cache::FileCache";
    plan $@
        ? ( skip_all => 'needs Catalyst::Plugin::Cache::FileCache for testing' )
        : ( tests => 7 );
}

# remove previous cache
rmtree 't/var' if -d 't/var';

use Catalyst::Test 'TestApp';

# add config option
TestApp->config->{page_cache}->{set_http_headers} = 1;

# cache a page
my $cache_time = time;
ok( my $res = request('http://localhost/cache/count'), 'request ok' );
is( $res->content, 1, 'count is 1' );

# page will be served from cache and have http headers
ok( $res = request('http://localhost/cache/count'), 'request ok' );
is( $res->content, 1, 'count is still 1 from cache' );
is( $res->headers->{'cache-control'}, 'max-age=300', 'cache-control header ok' );
is( $res->headers->last_modified, $cache_time, 'last-modified header matches correct time' );
is( $res->headers->expires, $cache_time + 300, 'expires header matches correct time' );



