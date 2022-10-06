use strict;
use warnings;

use Plack::App::Commons::Category::Utils qw(compute_index_values);
use Test::More 'tests' => 5;
use Test::NoWarnings;

# Test.
my $items = 0;
my $actual_page = undef;
my $items_on_page = 24;
my ($begin_index, $end_index) = compute_index_values($items, $actual_page, $items_on_page);
is($begin_index, undef, 'Begin index (0 items, actual page = undef, 24 images on page).');
is($end_index, undef, 'End index (0 items, actual page = undef, 24 images on page).');

# Test.
$items = 1;
$actual_page = 1;
$items_on_page = 24;
($begin_index, $end_index) = compute_index_values($items, $actual_page, $items_on_page);
is($begin_index, 0, 'Begin index (1 items, actual page = 1, 24 images on page).');
is($end_index, 0, 'End index (1 items, actual page = 1, 24 images on page)');
