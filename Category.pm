package Plack::App::Commons::Category;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Commons::Link;
use Commons::Vote::Fetcher;
use Data::Commons::Image;
use Data::HTML::Button;
use Data::HTML::Form;
use Data::HTML::Form::Input;
use Error::Pure qw(err);
use Plack::Request;
use Plack::Util::Accessor qw(category content_after_form image_grid_width image_width images_on_page
	page view_paginator view_prev_next);
use Readonly;
use Tags::HTML::Form;
use Tags::HTML::Image;
use Tags::HTML::Image::Grid;
use Tags::HTML::Pager;
use Tags::HTML::Pager::Utils qw(adjust_actual_page
	compute_index_values pages_num);
use Unicode::UTF8 qw(decode_utf8 encode_utf8);
use URL::Encode qw(url_decode_utf8);

Readonly::Scalar our $IMAGE_WIDTH => 800;
Readonly::Scalar our $IMAGE_GRID_WIDTH => 340;
Readonly::Scalar our $IMAGES_ON_PAGE => 24;

our $VERSION = 0.01;

sub _css {
	my $self = shift;

	if ($self->{'_page'} eq 'category') {
		$self->{'_html_image_grid'}->process_css;
		$self->{'_html_pager'}->process_css;
	} elsif ($self->{'_page'} eq 'category_form') {
		$self->{'_html_form'}->process_css;
	} elsif ($self->{'_page'} eq 'image') {
		$self->{'_html_image'}->process_css;
	}

	return;
}

sub _prepare_app {
	my $self = shift;

	# Inherite defaults.
	$self->SUPER::_prepare_app;

	# Default value for images on page.
	if (! defined $self->images_on_page) {
		$self->images_on_page($IMAGES_ON_PAGE);
	}

	# Default value for image width.
	if (! defined $self->image_width) {
		$self->image_width($IMAGE_WIDTH);
	}

	# Default value for image grid width.
	if (! defined $self->image_grid_width) {
		$self->image_grid_width($IMAGE_GRID_WIDTH);
	}

	# Wikimedia Commons link object.
	$self->{'_link'} = Commons::Link->new;

	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_html_form'} = Tags::HTML::Form->new(
		%p,
		'form' => Data::HTML::Form->new(
			'css_class' => 'form',
			'label' => 'Wikimedia Commons category form',
		),
		'submit' => Data::HTML::Button->new(
			'data' => [
				['d', 'View category'],
			],
			'data_type' => 'tags',
			'name' => 'page',
			'type' => 'submit',
			'value' => 'category',
		),
	);
	$self->{'_html_pager'} = Tags::HTML::Pager->new(
		%p,
		'url_page_cb' => sub {
			my $page = shift;

			return '?page=category&page_num='.$page;
		},
		defined $self->view_paginator ? (
			'flag_paginator' => $self->view_paginator,
		) : (),
		defined $self->view_prev_next ? (
			'flag_prev_next' => $self->view_prev_next,
		) : (),
	);
	$self->{'_html_image'} = Tags::HTML::Image->new(
		%p,
		'img_src_cb' => sub {
			my $image = shift;
			return $self->{'_link'}->thumb_link($image->commons_name, $self->image_width);
		},
	);
	$self->{'_html_image_grid'} = Tags::HTML::Image::Grid->new(
		%p,
		'img_link_cb' => sub {
			my $image = shift;
			return '?page=image&actual_image='.$image->commons_name;
		},
		'img_src_cb' => sub {
			my $image = shift;
			return $self->{'_link'}->thumb_link($image->commons_name, $self->image_grid_width);
		},
		'img_width' => $self->image_grid_width,
	);

	return;
}

sub _load_category {
	my $self = shift;

	if ($self->{'_loaded_category'}
		&& $self->{'_loaded_category'} eq $self->category) {

		return;
	}

	# XXX Logging.
	print 'Loading category: '.encode_utf8($self->category)."\n";

	# Get list of photos in category.
	my @images = Commons::Vote::Fetcher->new->images_in_category($self->category);
	$self->{'_pages_num'} = pages_num(scalar @images, $self->images_on_page);

	# Images count.
	$self->{'_images_count'} = scalar @images;

	# Create image objects.
	$self->{'_images'} = [];
	foreach my $image_hr (@images) {
		push @{$self->{'_images'}}, Data::Commons::Image->new(
			# TODO Other information.
			'comment' => $image_hr->{'title'},
			'commons_name' => $image_hr->{'title'},
		);
	}

	$self->{'_loaded_category'} = $self->category;

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	my $req = Plack::Request->new($env);

	# Process which on which page we are.
	if ($req->parameters->{'page'}) {
		$self->{'_page'} = $req->parameters->{'page'};
	} elsif (defined $self->page) {
		$self->{'_page'} = $self->page;
	} else {
		$self->{'_page'} = 'category_form';
	}

	# Category page.
	if ($self->{'_page'} eq 'category') {
		if ($req->parameters->{'category'}) {
			$self->category(decode_utf8($req->parameters->{'category'}));
		}
		$self->_load_category;

		# Adjust actual page.
		$self->{'_actual_page'} = adjust_actual_page($req->parameters->{'page_num'},
			$self->{'_pages_num'});

		# Select images for page.
		my ($page_begin_image_index, $page_end_image_index) = compute_index_values(
			$self->{'_images_count'}, $self->{'_actual_page'}, $self->images_on_page);
		if (defined $page_begin_image_index && defined $page_end_image_index) {
			$self->{'_page_images'} = [
				@{$self->{'_images'}}[$page_begin_image_index .. $page_end_image_index],
			];
		} else {
			$self->{'_page_images'} = $self->{'_images'};
		}

	# Image page.
	} elsif ($self->{'_page'} eq 'image') {
		if ($req->parameters->{'actual_image'}) {
			$self->{'_html_image'}->init(
				Data::Commons::Image->new(
					'commons_name' => url_decode_utf8(
						$req->parameters->{'actual_image'}),
				),
			);
		}
	}

	return;
}

sub _tags_middle {
	my $self = shift;

	# Category form.
	if ($self->{'_page'} eq 'category_form') {
		$self->{'_html_form'}->process(Data::HTML::Form::Input->new(
			'id' => 'category',
			'label' => 'Category',
			'type' => 'text',
		));

		# Extra conent after form.
		if (defined $self->content_after_form) {
			$self->content_after_form->($self);
		}

	# Category view.
	} elsif ($self->{'_page'} eq 'category') {

		# Image grid.
		$self->{'_html_image_grid'}->process($self->{'_page_images'});

		# Pager.
		$self->{'_html_pager'}->process({
			'actual_page' => $self->{'_actual_page'},
			'pages_num' => $self->{'_pages_num'},
		});

	# Image view.
	} elsif ($self->{'_page'} eq 'image') {
		$self->{'_html_image'}->process;
	}

	# TODO Loading page.

	return;
}

1;

__END__
