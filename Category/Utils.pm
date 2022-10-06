package Plack::App::Commons::Category::Utils;

use base qw(Exporter);
use strict;
use warnings;

use Error::Pure qw(err);
use POSIX qw(ceil);
use Readonly;

Readonly::Array our @EXPORT_OK => qw(adjust_actual_page compute_index_values
	pages_num);

our $VERSION = 0.01;

sub adjust_actual_page {
	my ($input_actual_page, $pages) = @_;

	if (! defined $pages) {
		err 'Not defined number of pages.';
	}
	if ($pages !~ m/^\d+$/ms) {
		err 'Number of pages must be a positive number.';
	}

	# No pages.
	if ($pages == 0) {
		return;
	}

	my $actual_page;
	if (! defined $input_actual_page) {
		$actual_page = 1;
	} else {
		$actual_page = $input_actual_page;
	}

	if ($actual_page > $pages) {
		$actual_page = $pages;
	}

	return $actual_page;
}

sub compute_index_values {
	my ($items, $actual_page, $items_on_page) = @_;

	if (! defined $actual_page) {
		return ();
	}

	my ($begin_index, $end_index);
	$begin_index = ($actual_page - 1) * $items_on_page;
	$end_index = ($actual_page * $items_on_page) - 1;
	if ($end_index + 1 > $items) {
		$end_index = $items - 1;
	}

	return ($begin_index, $end_index);
}

sub pages_num {
	my ($images, $images_on_page) = @_;

	my $pages_num = 0;
	if (defined $images) {
		$pages_num = ceil($images / $images_on_page);
	}

	return $pages_num;
}

1;
