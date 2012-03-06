# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl OBOParser.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 61;
}

#########################

use OBO::Parser::OBOParser;
use strict;

my $my_parser = OBO::Parser::OBOParser->new();
ok(1);

my $mini_onto = $my_parser->work('./t/data/header.obo');
ok($mini_onto->id() eq 'APO');
ok($mini_onto->data_version() eq '3.2');
ok($mini_onto->date() eq '28:03:2011 13:57');
ok($mini_onto->saved_by() eq 'easr');
ok(($mini_onto->imports()->get_set())[0] eq 'ulo.obo');
ok(($mini_onto->idspaces()->get_set())[0]->as_string() eq 'APO http://www.cellcycleontology.org/ontology/APO "cell cycle ontology terms"');
ok($mini_onto->default_namespace() eq 'apo');

ok(($mini_onto->remarks()->get_set())[0] eq '<p>This file holds some fake terms.</p>');

my @txae = sort {lc($a) cmp lc($b)} $mini_onto->treat_xrefs_as_equivalent()->get_set();
ok($txae[0] eq 'EQUI');
ok($txae[1] eq 'TEST');

my %ssd = ('Arabidopsis' => 'Term used for Arabidopsis',
			'Citrus'     => 'Term used for citrus',
			'Maize'      => 'Term used for maize',
			'Poaceae'    => 'Term used for grasses',
			'Rice'       => 'Term used for rice',
			'Tomato'     => 'Term used for tomato',
			'reference'  => 'reference plant structure term');
my @ss = sort {lc($a) cmp lc($b)} keys %ssd;
ok($mini_onto->subset_def_map()->size() == 7);
my $i = 0;
foreach my $ssd (sort {lc($a) cmp lc($b)} $mini_onto->subset_def_map()->key_set()->get_set()) {
	ok($ssd eq $ss[$i]);
	ok($mini_onto->subset_def_map()->get($ssd)->description() eq $ssd{$ss[$i++]});
}
ok(scalar $mini_onto->synonym_type_def_set()->get_set() == 6);

$i = 0;
foreach my $subsetdef (sort {lc($a->name()) cmp lc($b->name())} $mini_onto->subset_def_map()->values()) {
	ok($subsetdef->as_string() eq $ss[$i]." \"".$ssd{$ss[$i++]}."\"");
}

# test on comments
my $F4 = $mini_onto->get_term_by_id('APO:F0000004');
ok($F4->is_anonymous());

# test on comments
my $F3 = $mini_onto->get_term_by_id('APO:F0000003');

my $rt = $mini_onto->get_relationship_type_by_id('is_a');
if (defined $rt)  {
	my %saw_is_a; # avoid duplicated arrows (RelationshipSet?)
	my @heads = @{$mini_onto->get_head_by_relationship_type($F3, $rt)}; 
	foreach my $head (grep (!$saw_is_a{$_}++, @heads)) {
		my $is_a_txt = "is_a: ".$head->id();
		my $head_name = $head->name();
		$is_a_txt .= ' ! '.$head_name if (defined $head_name);
		ok ($is_a_txt eq "is_a: APO:F0000002 ! dos")
	}
}

# instances
my $ins = $mini_onto->get_instance_by_id('APO:erick');
ok($mini_onto->has_instance($ins));
ok($ins->name() eq 'Erick Antezana');
my $tin = $mini_onto->get_term_by_id('APO:man');
ok($mini_onto->has_term($tin));
ok(!defined $tin->name());
ok($ins->is_instance_of($tin));
ok($tin->is_class_of($ins));
ok($mini_onto->get_number_of_instances() == 1); # will be 2 ('APO:erick' && 'APO:cecilia') once the properties are implemented

# export to OBO
open (FH, '>./t/data/test0.obo') || die 'Run as root the tests: ', $!;
$mini_onto->export('obo', \*FH, \*STDERR);
close FH;
my $ontology = $my_parser->work('./t/data/fake_ulo_apo.obo');

ok($ontology->has_term($ontology->get_term_by_id('APO:B9999993')));
ok($ontology->get_terms_by_name('small molecule')->size() == 1);
ok($ontology->has_term(($ontology->get_terms_by_name('small molecule')->get_set())[0]));
ok($ontology->get_relationship_by_id('APO:B9999998_is_a_APO:B0000000')->type() eq 'is_a');
ok($ontology->get_relationship_by_id('APO:B9999996_part_of_APO:B9999992')->type() eq 'part_of');

# export to OBO
open (FH, '>./t/data/test1.obo') || die 'Run as root the tests: ', $!;
$ontology->export('obo', \*FH);
close FH;

# export to RDF
# for RDF get the whole ontology, as we need interactions, processes ...
my $rdf_ontology = $my_parser->work('./t/data/out_I_A_thaliana.obo');
open (FH, '>./t/data/test1.rdf') || die 'Run as root the tests: ', $!;
$rdf_ontology->export('rdf', \*FH, \*STDERR, 'http://www.myontology.org/ontology/rdf/');
close FH;

# export to RDF (generic)
my $rdf_ontology_gen = $my_parser->work('./t/data/cell.obo');
open (FH, '>./t/data/test2.rdf') || die 'Run as root the tests: ', $!;
$rdf_ontology_gen->export('rdf', \*FH, \*STDERR, 'http://www.cellcycleontology.org/ontology/rdf/');
close FH;

# export to XML 1
open (FH, '>./t/data/test1.xml') || die 'Run as root the tests: ', $!;
$ontology->export('xml', \*FH);
close FH;

my $ontology2 = $my_parser->work('./t/data/pre_apo.obo');
my $has_participant = $ontology2->get_relationship_type_by_id('has_participant');
my $participates_in = $ontology2->get_relationship_type_by_id('participates_in');
ok($has_participant->inverse_of()->equals($participates_in));
ok($participates_in->inverse_of()->equals($has_participant));
ok($ontology2->get_number_of_terms() == 636);

# export to XML 2
open (FH, '>./t/data/test2.xml') || die 'Run as root the tests: ', $!;
$ontology2->export('xml', \*FH);
close FH;

# export to OWL 2
open (FH, '>./t/data/test2.owl') || die 'Run as root the tests: ', $!;
$ontology2->export('owl', \*FH, \*STDERR, 'http://www.cellcycleontology.org/ontology/owl/', 'http://www.cellcycleontology.org/formats/oboInOwl#');
close FH;

# export to DOT 2
open (FH, '>./t/data/test2.dot') || die 'Run as root the tests: ', $!;
$ontology2->export('dot', \*FH);
close FH;

# export back to obo
open (FH, '>./t/data/test2.obo') || die 'Run as root the tests: ', $!;
ok($ontology2->has_term($ontology2->get_term_by_id('APO:P0000205')));
ok($ontology2->has_term($ontology2->get_term_by_name('gene')));
$ontology2->export('obo', \*FH);
close FH;

# some tests
ok($ontology2->has_term($ontology2->get_term_by_id('APO:U0000009')));
ok($ontology2->has_term($ontology2->get_term_by_name('cell cycle')));
ok($ontology2->get_relationship_by_id('APO:P0000274_is_a_APO:P0000262')->type() eq 'is_a');
ok($ontology2->get_relationship_by_id('APO:P0000274_part_of_APO:P0000272')->type() eq 'part_of'); 

#
# a third ontology
# 
my $ontology3 = $my_parser->work('./t/data/ulo_apo.obo');
ok($ontology3->get_number_of_terms() == 11);
ok($ontology3->has_term($ontology3->get_term_by_id('APO:U0000009')));
ok($ontology3->has_term($ontology3->get_term_by_id('APO:U0000001')));

# export to OWL ULO
open (FH, '>./t/data/test_ulo_apo.owl') || die 'Run as root the tests: ', $!;
$ontology3->export('owl', \*FH, \*STDERR, 'http://www.cellcycleontology.org/ontology/owl/', 'http://www.cellcycleontology.org/formats/oboInOwl#');
close FH;

# export to DOT ULO
open (FH, '>./t/data/test_ulo_apo.dot') || die 'Run as root the tests: ', $!;
$ontology3->export('dot', \*FH);
close FH;
ok(1);