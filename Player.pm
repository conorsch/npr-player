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


has 'program'  => ( is => 'rw', isa => 'Item', default => sub { Program->new });
has 'programs' => ( is => 'ro', isa => 'ArrayRef', default => sub { &program_list }); 
has 'pid' => ( is => 'rw', isa => 'Int' );
#
#sub program_list {
##    my @p = ( Program->new( $_ ) for @supported_programs );
##    my $program = Program->new( $supported_programs[0] ) ;
##	return $program;
#	my @programs = Program->new(@supported_programs) ;
#	say "PRINTING PROG: $_" for @programs;
#	return \@programs;
#}


  1;
