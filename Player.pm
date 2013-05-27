package Player;

# quick script to play NPR podcasts;
use strict;
use warnings;
use diagnostics;                     # useful for debugging;
use feature 'say';                   # beats print;
use Getopt::Long;                    # for parsing command-line options;
use Moose;                           # for beautiful objects;
use Moose::Util::TypeConstraints;    # for stronger attribute typing;
use Regexp::Common;                  # for pre-baked regular expressions;
use Program;
use threads;                         # for running mplayer as separate PID;

has 'program',
  is       => 'rw',
  isa      => 'Program',
  lazy     => 1,
  default  => sub { return Program->recommended; },
  required => 1,
  handles  => [ qw( articles recommended ) ];

has 'pid' => ( is => 'rw', isa => 'Int' );
has 'software' => ( is => 'rw', isa => 'Str', default => '/usr/bin/mplayer' );
has 'verbose',
is => 'rw',
isa => 'Int',
default => 1;

sub now_playing { 
	my $self = shift;
	return $self->program->episode;
}

after 'play' => sub {
	my $self = shift;
	my $episode = $self->now_playing;
	if ( $self->verbose ) {
		say "Now playing: '" , $episode->title, "'";
		say "Published on: ", $episode->pub_date;

	}
};

sub play {    # play URL via mplayer (default), or whatever software user specified;
    my $self = shift;

    my $software = $self->software;
    my $url      = $self->program->episode->url;

    my $pid = fork();
    $self->pid( $pid );
    if ( $pid == 0 ) {
        exec( "$software $url >/dev/null 2>&1" ) or die "Could not fork out to player $!";
    }
    elsif ( defined( $pid ) ) {
        return $pid;
    }
    else {
        die "Could not fork out to player $!";
    }
}

sub stop {    # kill running player;
    my $self = shift;
    my $pid = $self->pid or return;
    return system( "kill $pid" ) == 0;
}

1;

