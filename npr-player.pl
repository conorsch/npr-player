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

my $player = Player->new();
my $programs = $player->programs;

say "Trying to display descriptions: ";
say Dumper( $programs );
say "REF TYPE IS: " . ref($programs);
say "DESCRIPTION IS: " . $_->description for @$programs;


#my $base_url = $program->base_url;
#say "Trying to display base_url: '$base_url'";
