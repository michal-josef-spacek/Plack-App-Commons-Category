use strict;
use warnings;

use Plack::App::Commons::Category::Utils;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::Commons::Category::Utils::VERSION, 0.01, 'Version.');
