#!/usr/bin/perl
# quick script to play NPR podcasts;
use strict;
use warnings;
use diagnostics;      # useful for debugging;
use feature 'say';    # beats print;
use Getopt::Long;     # for parsing command-line options;
use Moose; # for beautiful objects;
use Player;
use Program;
use Data::Dumper;
use threads;

my $usage = <<'END';
npr-player

. 

Usage: 
	 --option 1		
	 --option 2	
	 --help		# show this usage information

Supported options:

	-h, --help 		# show this usage information
	-v, --verbose		# enable chatty output

END

my $player = Player->new( episode => '02');

say "Starting thread for player instance...";
say "BEFORE PLAYING";

my $instance = threads->create( \&watch_input );
$player->play;

say "AFTER PLAYING";
sleep 5;
$player->stop;
#my $programs = $player->programs;
#
#say "Trying to display descriptions: ";
#say Dumper( $programs );
#say "REF TYPE IS: " . ref($programs);
#say "DESCRIPTION IS: " . $_->description for @$programs;


#my $base_url = $program->base_url;
#say "Trying to display base_url: '$base_url'";
sub watch_input { 
	while ( chomp( my $input = <STDIN> ) ) { 
		my $pid = $player->pid;
		`kill $pid` and exit if $input eq 'q';
		`kill $pid` if $input eq 'n';
	}
}

