package Plack::App::Commons::Category;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Commons::Vote::Fetcher;
use Error::Pure qw(err);
use Plack::Request;
use Plack::Util::Accessor qw(category);
use Tags::HTML::Pager;

our $VERSION = 0.01;

sub _css {
	my $self = shift;

	$self->{'_html_pager'}->process_css;

	return;
}

sub _prepare_app {
	my $self = shift;

	if (! $self->category) {
		err 'No category.';
	}

	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_html_pager'} = Tags::HTML::Pager->new(
		%p,
		'url_page_cb' => sub {
			my $page = shift;

			return '?page='.$page;
		}
	);
	# TODO gallery view grid

	# Get list of photos in category.
	my @images = Commons::Vote::Fetcher->new->images_in_category($self->category);
	$self->{'_pages_num'} = scalar @images;
	# TODO

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	my $req = Plack::Request->new($env);

	$self->{'_actual_page'} = $req->parameters->{'page'};
	if (! $self->{'_actual_page'}) {
		$self->{'_actual_page'} = 1;
	}

	return;
}

sub _tags_middle {
	my $self = shift;

	# Image grid.
	# TODO
	
	# Pager.
	$self->{'_html_pager'}->process({
		'actual_page' => $self->{'_actual_page'},
		'pages_num' => $self->{'_pages_num'},
	});

	return;
}

1;

__END__
