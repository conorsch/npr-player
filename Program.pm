package Program;

# quick script to play NPR podcasts;
use strict;
use warnings;
use diagnostics;                     # useful for debugging;
use feature 'say';                   # beats print;
use Getopt::Long;                    # for parsing command-line options;
use Moose;                           # for beautiful objects;
use Moose::Util::TypeConstraints;    # for stronger attribute typing;
use Regexp::Common;                  # for pre-baked regular expressions;
use Regexp::Common qw(time);
use POSIX;

my $base_uri = 'http://pd.npr.org/anon.npr-mp3/npr';    # declare first part of URL


subtype 'Url' 
	=> as 'Str' 
	=> where { /^$RE{URI}{HTTP}$/ } 
	=> message { "$_ is not a valid URL" }
;

subtype 'Date' 
	=> as 'Str' 
	=> where { /^$RE{time}{strftime}{-pat => '%Y\/%m\/%Y%m%d'}$/ } 
	=> message { "$_ is not a valid date; must use %Y/%m/%Y%m%d format" }
;

subtype 'SupportedProgram' 
	=> as 'Str' 
#	=> where { map { $_->title } @supported_programs } 
	=> message { "$_ is not a valid date; must use %Y/%m/%Y%m%d format" }
;
has 'url' => (
    is  => 'rw',
    isa => 'Url'
);

has 'episode'  => ( is => 'rw', isa => 'Str', default => '01' );
has 'base_url' => ( is => 'ro', isa => 'Url', default => 'http://pd.npr.org/anon.npr-mp3/npr' );    # declare first part of URL

has 'description'  => ( is => 'ro', isa => 'Str' );
has 'abbreviation' => ( is => 'ro', isa => 'Str' );
has 'short_title'  => ( is => 'ro', isa => 'Str', default => 'me' );
has 'title'        => ( is => 'ro', isa => 'Str' );
has 'date'         => ( is => 'ro', isa => 'Date', default => &today );

sub BUILD {
    my $self = shift;
	say "I AM BUILDING A PROGRAM";
    $self->url( $self->base_url . '/' . $self->short_title . '/' . $self->date . '_' . $self->short_title . '_' . $self->episode . '.mp3?dl=1' );
	say "HELLO I AM A PROGRAM AND MY URL IS:\n\t" . $self->url;
}

sub today {    # return today's date formatted for interpolation in URL;
    return POSIX::strftime( "%Y/%m/%Y%m%d", localtime );
}



1;
