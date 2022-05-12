use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'Plack application for Wikimedia Commons category view.';
author 'Michal Josef Spacek <skim@cpan.org>';
author_requires 'English' => 0;
author_requires 'File::Object' => 0;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
license 'bsd';
name 'Plack-App-Commons-Category';
perl_version 5.008;
readme_from 'Category.pm';
recursive_author_tests('xt');
requires 'Commons::Link' => 0;
requires 'Commons::Vote::Fetcher' => 0;
requires 'Data::Commons::Image' => 0;
requires 'Error::Pure' => 0;
requires 'Plack::Request' => 0;
requires 'Plack::Util::Accessor' => 0;
requires 'POSIX' => 0;
requires 'Readonly' => 0;
requires 'Tags::HTML::Image::Grid' => 0;
requires 'Tags::HTML::Pager' => 0;
requires 'Unicode::UTF8' => 0;
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/Plack-App-Commons-Category/issues';
resources 'homepage' => 'https://github.com/michal-josef-spacek/Plack-App-Commons-Category';
resources 'repository' => 'git://github.com/michal-josef-spacek/Plack-App-Commong-Category';
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
