#!/usr/bin/perl
# quick script to play NPR podcasts;
use strict;
use warnings;
use diagnostics;               # useful for debugging;
use feature qw/switch say/;    # beats print;
use Getopt::Long;              # for parsing command-line options;
use Moose;                     # for beautiful objects;
use Player;
use Program;
use Data::Dumper;
use Time::Piece;
use threads;

my $usage = <<'END';
npr-player

Plays NPR podcasts via mplayer. Default settings will play 
today's Morning Edition, but it understands flags like --program 
and --episode in case you want to fine-tune your NPR listening. 

Matching by program name is done via a loose substring search, so 
command line use has sane defaults.

Requires mplayer.

Usage: 

	npr					# plays most recent program published
	npr Wiretap			# plays a recent episode of Wiretap
	npr wesun			# plays most recent Weekend Edition Sunday
	npr sat				# plays most recent Weekend Edition Saturday

Supported options:

	-h, --help 		# show this usage information
	-v, --verbose		# enable chatty output
END
use Getopt::Long;    # for parsing command-line options;

GetOptions(
    'program|p'      => \my $program,
    'help|h|?|usage' => \my $help,
    'verbose|v'      => \my $verbose,
) or die "$usage";

say $usage and exit if $help;    # print help/usage info when asked;

my @supported_programs = map {   # build a list of accepted arguments for program;
    $_->{ title },               # check for full title of program;
      $_->{ short_title },       # also accept abbreviations;
} Program->supported_programs;

if ( $program or @ARGV ) {       # overload arg-reading to accept --program as ARGV[0];
    $program = $ARGV[ 0 ] unless $program;    # don't clobber a manually specified --program;

    unless ( grep { /$program/i } @supported_programs ) { # make sure we understand this request;
        say "$usage\nThe program '$program' is not supported. Try one of the following:\n";
		say "\t- $_" for sort @supported_programs;
        exit 1;
    }
}

my $player = Player->new( { program => $program } );

$player->play;
waitpid( $player->pid, 0 );
my $instance = threads->create( \&watch_input );

$instance->join;

$player->stop;
my $programs = $player->programs;

sub watch_input {
    while ( chomp( my $input = <STDIN> ) ) {
        my $pid = $player->pid or die "Could not look up PID for player $!";
        if ( $input eq 'q' ) {
            say "Detected user input of 'q', killing player PID $pid...";
            `kill $pid`;
            exit;
        }
        else {
            say "I didn't understand the input '$input'";
            next;
        }
        `kill $pid` if $input eq 'n';
    }
}

