# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GoaParser.t'

#########################

BEGIN {
	eval { require Test; };
    use Test;    
    plan tests => 6;
}
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
use CCO::Parser::GoaParser;
use Carp;
use strict;
use warnings;

my %taxa = (
	'4896' => 'Schizosaccharomyces pombe organism',
	'4932' => 'Saccharomyces cerevisiae organism', 
	'3702' => 'Arabidopsis thaliana organism',
	'9606' => 'Homo sapiens organism'
	);
my @files = ("./t/data/pre_cco_core.obo",
			"./t/data/out_cco.obo",
			"./t/data/goa_assoc_filt.txt", 
			"./t/data/cco_b_tair.ids",
			"./t/data/cco_b.ids");
my $my_parser = CCO::Parser::GoaParser->new();
ok(1);

my $start = time;
my $ontology = $my_parser->work(\@files, $taxa{'3702'});
my $end = time;
#print "Processed in ", $end - $start, " seconds\n"; 
ok(1);
ok($ontology->get_term_by_name("Q6NMC8_ARATH")); #this entry has no synonyms (i.e. no IPI id)
ok($ontology->get_term_by_name("RK20_ARATH"));
ok($ontology->get_term_by_name("Q6XJG8_ARATH"));
ok($ontology->get_term_by_name("Q84JF0_ARATH"));
