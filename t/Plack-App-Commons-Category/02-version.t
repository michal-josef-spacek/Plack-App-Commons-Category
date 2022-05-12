use strict;
use warnings;

use Plack::App::Commons::Category;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::Commons::Category::VERSION, 0.01, 'Version.');
