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
use Time::Piece;                     # for easy manipulation of time by day of week or time of day;
use WWW::Mechanize;                  # for reading web pages programmatically;
use Episode;
use XML::Simple;
use Data::Dumper;

has 'description',
  is  => 'rw',
  isa => 'Str';

has 'short_title',
  is       => 'ro',
  isa      => 'Str',
  required => 1;

has 'title',
  is       => 'rw',
  isa      => 'Str',
  lazy => 1,
  required => 1,
  default => sub { 
	  return shift->tagged_content->{ channel }->{ title };
  },;

has 'feed_url',
  is  => 'rw',
  isa => 'Str';

has 'date',
  is      => 'rw',
  isa     => 'Str',
  default => sub { my $t = localtime; return $t->ymd };

has 'tagged_content',
  is      => 'rw',
  isa     => 'HashRef',
  lazy    => 1,
  builder => 'get_tagged_content';

has 'verbose',
  is      => 'rw',
  isa     => 'Int',
  default => 0;

has 'episode',
  is      => 'rw',
  isa     => 'Episode',
  builder => 'get_episode',
  ;

sub get_episode {
    my $self     = shift;
    my $episodes = $self->episodes;
    my $episode  = @{ $episodes }[ rand( scalar @$episodes ) ];
    return $episode;
}

sub supported_programs {
    my $class = shift;

    return (
        {
            short_title => 'me',
            title       => 'Morning Edition',
            description =>
"Morning Edition gives its audience news, analysis, commentary, and coverage of arts and sports. Stories are told through conversation as well as full reports. It's up-to-the-minute news that prepares listeners for the day ahead.",
            feed_url => 'http://www.npr.org/rss/rss.php?id=3',
        },
        {
            short_title => 'atc',
            title       => 'All Things Considered',
            description =>
"Every weekday, All Things Considered hosts Robert Siegel, Michele Norris and Melissa Block present the program's trademark mix of news, interviews, commentaries, reviews, and offbeat features.",
            feed_url => 'http://feeds.feedburner.com/NprProgramsATC'
        },
        {
            short_title => 'wesat',
            title       => 'Weekend Edition Saturday',
            description =>
"From civil wars in Bosnia and El Salvador, to hospital rooms, police stations, and America's backyards, National Public Radio's Peabody Award-winning correspondent Scott Simon brings a well-traveled perspective to his role as host of Weekend Edition Saturday.",
            feed_url => 'http://www.npr.org/rss/rss.php?id=7',
        },
        {
            short_title => 'wesun',
            title       => 'Weekend Edition Sunday',
            description =>
"Weekend Edition Sunday premiered on Jan. 18, 1987. Since then, Weekend Edition Sunday has covered newsmakers and artists, scientists and politicans, music makers of all kinds, writers, thinkers, theologians and all manner of news events. Originally hosted by Susan Stamberg, the show was anchored by Liane Hansen for 22 years.",
            feed_url => 'http://www.npr.org/rss/rss.php?id=10',
        },
        {
            short_title => 'wt',
            title       => 'Wiretap',
            description => "Wiretap rocks really hard.",
            feed_url    => 'http://www.cbc.ca/podcasting/includes/wiretap.xml',
        },
    );
}

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_;

    my $real_args = {};    # initialize empty hash ref for storing valid arguments to construtor;
    for my $arg ( @args ) {    # look at each arg received from caller;
        for my $supported_program ( $class->supported_programs ) {    # look at each supported program;
            if (   $supported_program->{ title } =~ m/$arg/i
                or $supported_program->{ short_title } =~ m/$arg/i )

            {
                return $class->$orig( $supported_program );           # use this setup;
            }
        }
    }

    return;                                                           # if we made it this far, return failure;

};

sub get_tagged_content {    # parse RSS feed into hash ref;
    my $self = shift;
    my $mech = WWW::Mechanize->new( autocheck => 1 );
    $mech->get( $self->feed_url );    # retrieve raw XML from RSS feed;

    my $tagged_content = XMLin( $mech->content ) or return;    # return failure unless content parses;
    return $tagged_content;                                    # pass back hashref to caller;
}

sub episodes {                                                 # build list of Episode objects for the current program;
    my $self = shift;
    my $episodes = [];                                         # initialize empty array ref for storing episodes;

    for my $item ( @{ $self->tagged_content->{ channel }->{ item } } ) {    # retrieve episode attributes from feed;
        $item->{ pub_date } = delete $item->{ pubDate };                    # rename value for consistency;
        $item->{ of } = $self->title or die "FUCKED UP BAD";
        push $episodes, $item;                                              # append this episode to our list;
    }

    $_ = Episode->new( $_ ) for @$episodes;                                 # construct Episode objects from args;
    return $episodes;                                                       # pass back array reference to episode attributes;
}

sub recommended {                                                           # return the right Program to list to now;
    my $class = shift;
    my $now   = localtime;

    if ( $now->hour < 8 ) {                                                 # if before 8:00AM;
        $now -= 86400;                                                      # subtract one day, to get yesterday's datetime;
    }

    if ( $now->wday ~~ [ 2 .. 5 ] ) {                                       # if today is a weekday;
        return $class->new( 'Morning Edition' );
    }

    elsif ( $now->wday == 7 ) {                                             # if today is Saturday;
        return $class->new( 'Weekend Edition Saturday' );
    }
    elsif ( $now->wday == 1 ) {                                             # if today is Sunday;
        return $class->new( 'Morning Edition Sunday' );
    }
}

1;

