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
use threads; # for running mplayer as separate PID;


my $program_list ; 

my @supported_programs = (
    {
        short_title => 'me',
        title       => 'Morning Edition',
        description => "Morning Edition gives its audience news, analysis, commentary, and coverage of arts and sports. Stories are told through conversation as well as full reports. It's up-to-the-minute news that prepares listeners for the day ahead.",
    },
    {
        short_title => 'atc',
        title       => 'All Things Considered',
        description => "Every weekday, All Things Considered hosts Robert Siegel, Michele Norris and Melissa Block present the program's trademark mix of news, interviews, commentaries, reviews, and offbeat features.",
    },
);

has 'program'  => ( is => 'rw', isa => 'Item', default => sub { Program->new( $supported_programs[ 0 ] ) });
has 'programs' => ( is => 'ro', isa => 'Item', default => sub {my $program = Program->new; return Program->program_list; }); 
has 'supported_programs' => ( is => 'rw', isa => 'Item', default => sub { return @supported_programs; } );
has 'programs' => ( is => 'rw', isa => 'Item', default => sub { return @supported_programs; } );
has 'pid' => ( is => 'rw', isa => 'Int' );
has 'software' => ( is => 'rw', isa => 'Str', default => '/usr/bin/mplayer' );

sub play { # play URL via mplayer (default), or whatever software user specified;
	my $self = shift;

	my $software = $self->software;
	my $url = $self->program->url;

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

sub stop { # kill running player;
	my $self = shift;
	my $pid = $self->pid or return;
	system( "kill $pid" ) == 0 or return;
	return 1; # return success to caller;
}
1;

