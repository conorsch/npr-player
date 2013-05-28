package Episode;
use strict;
use warnings;
use diagnostics;                     # useful for debugging;
use feature 'say';                   # beats print;
use Moose;                           # for beautiful objects;
use Moose::Util::TypeConstraints;    # for stronger attribute typing;
use MooseX::Aliases;                 # for dev-friendly overloading of method names (via aliases);
use Regexp::Common;                  # for pre-baked regular expressions;
use Time::Piece;                     # for easy manipulation of time by day of week or time of day;
use HTML::TreeBuilder;

has 'title',
  is       => 'ro',
  isa      => 'Str',
  required => 1;

has 'description',
  is  => 'ro',
  isa => 'Str',
  required => 1;

has 'pub_date',
  is  => 'ro',
  isa => 'Str',
  required => 1;

has 'guid',
  is  => 'ro',
  isa => 'Str';

has 'link',
  is    => 'ro',
  isa   => 'Str',
  alias => [ qw/ article article_url / ],
  required => 1;

has 'audio',
  is      => 'ro',
  isa     => 'Str',
  alias   => [ qw/ url podcast mp3 / ],
  builder => 'get_audio_url',
  lazy => 1;
  ;

has 'of',
  is => 'ro',
  required => 1;

subtype 'Url' => as 'Str' => where { /^$RE{URI}{HTTP}$/ } => message { "$_ is not a valid URL" };

sub url_date {    # return date formatted for interpolation in URL;
    my $self = shift;                 # unpack class object from caller;
    my $time = shift || localtime;    # assume right now, if no other epoch time given;
    $time -= 86400 if $time->hour < 8;    # change date to yesterday if before 8:00AM;
    $self->program->date( $time->ymd );          # store date in object;
    return $time->strftime( "%Y/%m/%Y%m%d" );    # return prettily formatted date value;
}

sub get_audio_url {                              # return URL to MP3 file for audio playback;
    my $self = shift;
    return $self->guid if $self->of =~ m/^Wiretap/; # Wiretap has audio URLs directly in RSS feed;
    my $audio = HTML::TreeBuilder->new_from_url( $self->article )->look_down( class => 'download' )->{ href } or return;
    return $audio;
}

1;
