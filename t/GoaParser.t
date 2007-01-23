# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GoaParser.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 2;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
use CCO::Parser::GoaParser;
use strict;

my %taxons = (
	'S_pombe' => '4896',
	'S_cerevisiae' => '4932',
	'A_thaliana' => '3702',
	'H_sapiens' => '9606'
	);
my  @taxons = values (%taxons);
my $my_parser = CCO::Parser::GoaParser->new;
ok(1);
my $start = time;
my $new_ontology=$my_parser->work("./t/data/pre_cco_taxa.obo","./t/data/out_cco.obo","./t/data/goa_assoc.txt", @taxons);
my $end = time;
print "Processed in ", $end - $start, " seconds\n"; 
ok(1);




