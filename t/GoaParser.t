# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GoaParser.t'

#########################

BEGIN {
	eval { require Test; };
    use Test;    
    plan tests => 5;
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
			"./t/data/goa_assoc.txt", 
			"./t/data/cco_b.ids");
my $my_parser = CCO::Parser::GoaParser->new;
ok(1);

my $start = time;
my $new_ontology = $my_parser->work(\@files, \%taxa);
my $end = time;
print "Processed in ", $end - $start, " seconds\n"; 
ok(1);
#ok($new_ontology->get_term_by_name("Q6NMC8_ARATH"));
ok($new_ontology->get_term_by_name("RK20_ARATH"));
ok($new_ontology->get_term_by_name("Q6XJG8_ARATH"));
ok($new_ontology->get_term_by_name("Q84JF0_ARATH"));

#ok($goaAssocSet = $my_parser->parse("./t/data/goa_assoc.txt")); #takes too long



