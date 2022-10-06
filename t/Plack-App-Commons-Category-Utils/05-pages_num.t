use strict;
use warnings;

use Plack::App::Commons::Category::Utils qw(pages_num);
use Test::More 'tests' => 3;
use Test::NoWarnings;

# Test.
my $ret = pages_num(4, 4);
is($ret, 1, '4 images and 4 images per page.');

# Test.
$ret = pages_num(4, 2);
is($ret, 2, '4 images and 2 images per page.');
