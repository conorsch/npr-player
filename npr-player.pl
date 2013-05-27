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

Requires mplayer.

Usage: 
	 --option 1		
	 --option 2	
	 --help		# show this usage information

Supported options:

	-h, --help 		# show this usage information
	-v, --verbose		# enable chatty output

END

my $player  = Player->new;

$player->play;
waitpid( $player->pid, 0 );
my $instance = threads->create( \&watch_input );

$instance->join;

say "AFTER PLAYING";
sleep 5;
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

