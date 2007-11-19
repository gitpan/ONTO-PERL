# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Ontology.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 180;
}

#########################
# $Id: Ontology.t 1635 2007-11-19 10:51:36Z erant $
#
# Purpose : onto-perl usage examples.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
use CCO::Core::Ontology;
use CCO::Core::Term;
use CCO::Core::Relationship;
use CCO::Core::RelationshipType;
use CCO::Core::SynonymTypeDef;
use CCO::Parser::OBOParser;
use CCO::Util::TermSet;

# three new terms
my $n1 = CCO::Core::Term->new();
my $n2 = CCO::Core::Term->new();
my $n3 = CCO::Core::Term->new();

# new ontology
my $onto = CCO::Core::Ontology->new();
ok($onto->get_number_of_terms() == 0);
ok($onto->get_number_of_relationships() == 0);
ok(1);

$n1->id("CCO:P0000001");
$n2->id("CCO:P0000002");
$n3->id("CCO:P0000003");

$n1->name("One");
$n2->name("Two");
$n3->name("Three");

my $def1 = CCO::Core::Def->new();
$def1->text("Definition of One");
my $def2 = CCO::Core::Def->new();
$def2->text("Definition of Two");
my $def3 = CCO::Core::Def->new();
$def3->text("Definition of Tres");
$n1->def($def1);
$n2->def($def2);
$n3->def($def3);

$n1->xref_set_as_string("[GO:0000001]");
$n2->xref_set_as_string("[GO:0000002]");
$n3->xref_set_as_string("[GO:0000003]");

$onto->add_term($n1);
ok($onto->has_term($n1) == 1);
$onto->add_term($n2);
ok($onto->has_term($n2) == 1);
$onto->add_term($n3);
ok($onto->has_term($n3) == 1);

# modifying a term name directly
$n3->name("Trej");
ok($onto->get_term_by_id("CCO:P0000003")->name() eq "Trej");
# modifying a term name via the ontology
$onto->get_term_by_id("CCO:P0000003")->name("Three");
ok($onto->get_term_by_id("CCO:P0000003")->name() eq "Three");

ok($onto->get_number_of_terms() == 3);
ok($onto->get_number_of_relationships() == 0);

$onto->delete_term($n1);
ok($onto->has_term($n1) == 0);
ok($onto->get_number_of_terms() == 2);
ok($onto->get_number_of_relationships() == 0);

$onto->add_term($n1);
ok($onto->has_term($n1) == 1);
ok($onto->get_number_of_terms() == 3);
ok($onto->get_number_of_relationships() == 0);

# new term
my $n4 = CCO::Core::Term->new();
$n4->id("CCO:P0000004");
$n4->name("Four");
my $def4 = CCO::Core::Def->new();
$def4->text("Definition of Four");
$n4->def($def4);
ok($onto->has_term($n4) == 0);
$onto->delete_term($n4);
ok($onto->has_term($n4) == 0);
$onto->add_term($n4);
ok($onto->has_term($n4) == 1);

# add term as string
my $new_term = $onto->add_term_as_string("CCO:P0000005", "Five");
$new_term->def_as_string("This is a dummy definition", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");
ok($onto->has_term($new_term) == 1);
ok($onto->get_term_by_id("CCO:P0000005")->equals($new_term));
ok($onto->get_number_of_terms() == 5);
my $n5 = $new_term; 

# five new relationships
my $r12 = CCO::Core::Relationship->new();
my $r23 = CCO::Core::Relationship->new();
my $r13 = CCO::Core::Relationship->new();
my $r14 = CCO::Core::Relationship->new();
my $r35 = CCO::Core::Relationship->new();

$r12->id("CCO:P0000001_is_a_CCO:P0000002");
$r23->id("CCO:P0000002_part_of_CCO:P0000003");
$r13->id("CCO:P0000001_participates_in_CCO:P0000003");
$r14->id("CCO:P0000001_participates_in_CCO:P0000004");
$r35->id("CCO:P0000003_part_of_CCO:P0000005");

$r12->type("is_a");
$r23->type("part_of");
$r13->type("participates_in");
$r14->type("participates_in");
$r35->type("part_of");

$r12->link($n1, $n2); 
$r23->link($n2, $n3);
$r13->link($n1, $n3);
$r14->link($n1, $n4);
$r35->link($n3, $n5);

# get all terms
my $c = 0;
my %h;
ok($onto->has_term_id("CCO:P0000003"));
ok(!$onto->has_term_id("CCO:P0000033"));
foreach my $t (@{$onto->get_terms()}) {
	if ($t->id() eq "CCO:P0000003"){
		ok($onto->has_term($t));
		$onto->set_term_id($t, "CCO:P0000033");
		ok($onto->has_term($t));
		$t = $onto->get_term_by_id("CCO:P0000033");
	}
	
	$t->name("Uj") if ($t->id() eq "CCO:P0000001");

	$h{$t->id()} = $t;
	$c++;	
}
ok(!$onto->has_term_id("CCO:P0000003"));
ok($onto->has_term_id("CCO:P0000033"));

ok($onto->get_number_of_terms() == 5);
ok($c == 5);
ok($h{"CCO:P0000001"}->name() eq "Uj"); # The name has been changed above
ok($h{"CCO:P0000002"}->name() eq "Two");
ok($h{"CCO:P0000033"}->name() eq "Three"); # The ID has been changed above
ok($h{"CCO:P0000004"}->name() eq "Four");
ok($h{"CCO:P0000005"}->name() eq "Five");

# modifying a term id via the ontology
ok($onto->set_term_id($onto->get_term_by_id("CCO:P0000033"), "CCO:P0000003")->id() eq "CCO:P0000003");
ok($onto->has_term_id("CCO:P0000003"));
ok(!$onto->has_term_id("CCO:P0000033"));
ok($onto->get_number_of_terms() == 5);

# get terms with argument
my @processes = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P.*")};
ok($#processes == 4);
my @odd_processes = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P000000[35]")};
ok($#odd_processes == 1);
ok($odd_processes[0]->id() eq "CCO:P0000003");
ok($odd_processes[1]->id() eq "CCO:P0000005");
ok($onto->idspace_as_string() eq "");
$onto->idspace_as_string("CCO", "http://www.cellcycle.org/ontology/CCO", "cell cycle ontology terms");
ok($onto->idspace()->local_idspace() eq "CCO");
my @same_processes = @{$onto->get_terms_by_subnamespace("P")};
ok(@same_processes == @processes);
my @no_processes = @{$onto->get_terms_by_subnamespace("p")};
ok($#no_processes == -1);

# get term and terms
ok($onto->get_term_by_id("CCO:P0000001")->name() eq "Uj");
ok($onto->get_term_by_name("Uj")->equals($n1));
$n1->synonym_as_string("Uno", "[CCO:ls, CCO:vm]", "EXACT");
ok(($n1->synonym_as_string())[0] eq "\"Uno\" [CCO:ls, CCO:vm]"
|| ($n1->synonym_as_string())[0] eq "\"Uno\" [CCO:vm, CCO:ls]"); # other architecture
$n1->synonym_as_string("One", "[CCO:ls, CCO:vm]", "BROAD");
ok($onto->get_term_by_name_or_synonym("Uno")->equals($n1)); # needs to be EXACT
ok($onto->get_term_by_name_or_synonym("One") eq ''); # undef due to BROAD
ok($onto->get_term_by_name("Two")->equals($n2));
ok($onto->get_term_by_name("Three")->equals($n3));
ok($onto->get_term_by_name("Four")->equals($n4));

ok($onto->get_term_by_xref("GO", "0000001")->equals($n1));
ok($onto->get_term_by_xref("GO", "0000002")->equals($n2));
ok($onto->get_term_by_xref("GO", "0000003")->equals($n3));

ok($onto->get_terms_by_name("Uj")->contains($n1));
ok($onto->get_terms_by_name("Two")->contains($n2));
ok($onto->get_terms_by_name("Three")->contains($n3));
ok($onto->get_terms_by_name("Four")->contains($n4));

# add relationships
$onto->add_relationship($r12);
ok($onto->get_relationship_by_id("CCO:P0000001_is_a_CCO:P0000002")->head()->id() eq "CCO:P0000002");
ok($onto->has_relationship_id("CCO:P0000001_is_a_CCO:P0000002"));

my @relas = @{$onto->get_relationships_by_target_term($onto->get_term_by_id("CCO:P0000002"))};
ok($relas[0]->id()         eq "CCO:P0000001_is_a_CCO:P0000002");
ok($relas[0]->tail()->id() eq "CCO:P0000001");
ok($relas[0]->head()->id() eq "CCO:P0000002");

$onto->add_relationship($r23);
$onto->add_relationship($r13);
$onto->add_relationship($r14);
$onto->add_relationship($r35);

ok($onto->get_number_of_terms() == 5);
ok($onto->get_number_of_relationships() == 5);

# add relationships and terms linked by this relationship
my $n11 = CCO::Core::Term->new();
my $n21 = CCO::Core::Term->new();
$n11->id("CCO:P0000011"); $n11->name("One one"); $n11->def_as_string("Definition One one", "");
$n21->id("CCO:P0000021"); $n21->name("Two one"); $n21->def_as_string("Definition Two one", "");
my $r11_21 = CCO::Core::Relationship->new();
$r11_21->id("CCO:L0001121"); $r11_21->type("r11-21");
$r11_21->link($n11, $n21);
$onto->add_relationship($r11_21); # adds to the ontology the terms linked by this relationship
ok($onto->get_number_of_terms() == 7);
ok($onto->get_number_of_relationships() == 6);

# get all relationships
my %hr;
foreach my $r (@{$onto->get_relationships()}) {
	$hr{$r->id()} = $r;
}
ok($hr{"CCO:P0000001_is_a_CCO:P0000002"}->head()->equals($n2));
ok($hr{"CCO:P0000002_part_of_CCO:P0000003"}->head()->equals($n3));
ok($hr{"CCO:P0000001_participates_in_CCO:P0000003"}->head()->equals($n3));
ok($hr{"CCO:P0000001_participates_in_CCO:P0000004"}->head()->equals($n4));

# recover a previously stored relationship
ok($onto->get_relationship_by_id("CCO:P0000001_participates_in_CCO:P0000003")->equals($r13));
ok($onto->has_relationship_id("CCO:P0000001_participates_in_CCO:P0000003"));

# get children
my @children = @{$onto->get_child_terms($n1)}; 
ok(scalar(@children) == 0);

@children = @{$onto->get_child_terms($n3)}; 
ok($#children == 1);
my %ct;
foreach my $child (@children) {
	$ct{$child->id()} = $child;
} 
ok($ct{"CCO:P0000002"}->equals($n2));
ok($ct{"CCO:P0000001"}->equals($n1));

@children = @{$onto->get_child_terms($n2)};
ok(scalar(@children) == 1);
ok($children[0]->id eq "CCO:P0000001");

# get parents
my @parents = @{$onto->get_parent_terms($n3)};
ok(scalar(@parents) == 1);
@parents = @{$onto->get_parent_terms($n1)};
ok(scalar(@parents) == 3);
@parents = @{$onto->get_parent_terms($n2)};
ok(scalar(@parents) == 1);
ok($parents[0]->id eq "CCO:P0000003");

# get all descendents
my @descendents1 = @{$onto->get_descendent_terms($n1)};
ok(scalar(@descendents1) == 0);
my @descendents2 = @{$onto->get_descendent_terms($n2)};
ok(scalar(@descendents2) == 1);
ok($descendents2[0]->id eq "CCO:P0000001");
my @descendents3 = @{$onto->get_descendent_terms($n3)};
ok(scalar(@descendents3) == 2);
my @descendents5 = @{$onto->get_descendent_terms($n5)};
ok(scalar(@descendents5) == 3);

# get all ancestors
my @ancestors1 = @{$onto->get_ancestor_terms($n1)};
ok(scalar(@ancestors1) == 4);
my @ancestors2 = @{$onto->get_ancestor_terms($n2)};
ok(scalar(@ancestors2) == 2);
ok($ancestors2[0]->id eq "CCO:P0000003");
my @ancestors3 = @{$onto->get_ancestor_terms($n3)};
ok(scalar(@ancestors3) == 1);

# get descendents by term subnamespace
@descendents1 = @{$onto->get_descendent_terms_by_subnamespace($n1, 'P')};
ok(scalar(@descendents1) == 0);
@descendents2 = @{$onto->get_descendent_terms_by_subnamespace($n2, 'P')}; 
ok(scalar(@descendents2) == 1);
ok($descendents2[0]->id eq "CCO:P0000001");
@descendents3 = @{$onto->get_descendent_terms_by_subnamespace($n3, 'P')};
ok(scalar(@descendents3) == 2);
@descendents3 = @{$onto->get_descendent_terms_by_subnamespace($n3, 'R')};
ok(scalar(@descendents3) == 0);

# get ancestors by term subnamespace
@ancestors1 = @{$onto->get_ancestor_terms_by_subnamespace($n1, 'P')};
ok(scalar(@ancestors1) == 4);
@ancestors2 = @{$onto->get_ancestor_terms_by_subnamespace($n2, 'P')}; 
ok(scalar(@ancestors2) == 2);
ok($ancestors2[0]->id eq "CCO:P0000003");
@ancestors3 = @{$onto->get_ancestor_terms_by_subnamespace($n3, 'P')};
ok(scalar(@ancestors3) == 1);
@ancestors3 = @{$onto->get_ancestor_terms_by_subnamespace($n3, 'R')};
ok(scalar(@ancestors3) == 0);


# three new relationships types
my $r1 = CCO::Core::RelationshipType->new();
my $r2 = CCO::Core::RelationshipType->new();
my $r3 = CCO::Core::RelationshipType->new();

$r1->id("is_a");
$r2->id("part_of");
$r3->id("participates_in");

$r1->name("is a");
$r2->name("part_of");
$r3->name("participates_in");

ok(!$onto->has_relationship_type_id("is_a"));
ok(!$onto->has_relationship_type_id("part_of"));
ok(!$onto->has_relationship_type_id("participates_in"));

# add relationship types and test if they were added
ok($onto->get_number_of_relationship_types() == 0);
$onto->add_relationship_type($r1);
ok($onto->has_relationship_type($r1));
ok($onto->has_relationship_type($onto->get_relationship_type_by_id("is_a")));
ok($onto->has_relationship_type($onto->get_relationship_type_by_name("is a")));
ok($onto->has_relationship_type_id("is_a"));
$onto->add_relationship_type($r2);
ok($onto->has_relationship_type($r2));
ok($onto->has_relationship_type_id("part_of"));
$onto->add_relationship_type($r3);
ok($onto->has_relationship_type($r3));
ok($onto->has_relationship_type_id("participates_in"));
ok($onto->get_number_of_relationship_types() == 3);

# get descendents or ancestors linked by a particular relationship type 
my $rel_type1 = $onto->get_relationship_type_by_name("is a");
my $rel_type2 = $onto->get_relationship_type_by_name("part_of");
my $rel_type3 = $onto->get_relationship_type_by_name("participates_in");

my @descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n5, $rel_type1)};
ok(scalar(@descendents7) == 0); 
@descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n5, $rel_type2)};
ok(scalar(@descendents7) == 2);
@descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n2, $rel_type1)};
ok(scalar(@descendents7) == 1);
@descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n3, $rel_type3)};
ok(scalar(@descendents7) == 1); 

my @ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n1, $rel_type1)};
ok(scalar(@ancestors7) == 1); 
@ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n1, $rel_type2)};
ok(scalar(@ancestors7) == 0);
@ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n1, $rel_type3)};
ok(scalar(@ancestors7) == 2);
@ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n2, $rel_type2)};
ok(scalar(@ancestors7) == 2); 

# add relationship type as string
my $relationship_type = $onto->add_relationship_type_as_string("has_participant", "has_participant");
ok($onto->has_relationship_type($relationship_type) == 1);
ok($onto->get_relationship_type_by_id("has_participant")->equals($relationship_type));
ok($onto->get_number_of_relationship_types() == 4);

# get relationship types
my @rt = @{$onto->get_relationship_types()};
ok(scalar @rt == 4);
my %rrt;
foreach my $relt (@rt) {
	$rrt{$relt->name()} = $relt;
}
ok($rrt{"is a"}->name() eq "is a");
ok($rrt{"part_of"}->name() eq "part_of");
ok($rrt{"participates_in"}->name() eq "participates_in");

ok($onto->get_relationship_type_by_id("is_a")->name() eq "is a");
ok($onto->get_relationship_type_by_name("is a")->id() eq "is_a");
ok($onto->get_relationship_type_by_name("part_of")->id() eq "part_of");
ok($onto->get_relationship_type_by_name("participates_in")->id() eq "participates_in");

# get_relationships_by_(source|target)_term
my @rtbs = @{$onto->get_relationships_by_source_term($n1)};

my %rtbsh;
foreach my $rel (@rtbs) {
	$rtbsh{$rel->type()} = $rel->type();
}
ok($rtbsh{"participates_in"} eq "participates_in");
ok($rtbsh{"is_a"} eq "is_a");

my @rtbt = @{$onto->get_relationships_by_target_term($n3)};

my %rtbth;
foreach my $rel (@rtbt) {
	$rtbth{$rel->type()} = $rel->type();
}
ok($rtbth{"participates_in"} eq "participates_in");
ok($rtbth{"part_of"} eq "part_of");

# get_head_by_relationship_type
my @heads_n1 = @{$onto->get_head_by_relationship_type($n1, $onto->get_relationship_type_by_name("participates_in"))};
my %hbrt;
foreach my $head (@heads_n1) {
	$hbrt{$head->id()} = $head;
}
ok($hbrt{"CCO:P0000003"}->equals($n3));
ok($hbrt{"CCO:P0000004"}->equals($n4));
ok(@{$onto->get_head_by_relationship_type($n1, $onto->get_relationship_type_by_name("is a"))}[0]->equals($n2));

# get_tail_by_relationship_type
ok(@{$onto->get_tail_by_relationship_type($n3, $onto->get_relationship_type_by_name("participates_in"))}[0]->equals($n1));
ok(@{$onto->get_tail_by_relationship_type($n2, $onto->get_relationship_type_by_name("is a"))}[0]->equals($n1));

#export
$onto->remark("This is a test ontology");
#$onto->export(\*STDERR);

# subontology_by_terms
my $terms = CCO::Util::TermSet->new();
$terms->add_all($n1, $n2, $n3);
my $so = $onto->subontology_by_terms($terms);
ok($so->get_number_of_terms() == 3);
ok($so->has_term($n1));
ok($so->has_term($n2));
ok($so->has_term($n3));

$n1->name("mitotic cell cycle");
$n2->name("cell cycle process");
$n3->name("re-entry into mitotic cell cycle after pheromone arrest");

ok($onto->get_term_by_name("mitotic cell cycle")->equals($n1));
ok($onto->get_term_by_name("cell cycle process")->equals($n2));
ok($onto->get_term_by_name("re-entry into mitotic cell cycle after pheromone arrest")->equals($n3));

ok($onto->get_terms_by_name("mitotic cell cycle")->contains($n1));
ok($onto->get_terms_by_name("cell cycle process")->contains($n2));
ok($onto->get_terms_by_name("re-entry into mitotic cell cycle after pheromone arrest")->contains($n3));

ok($onto->get_terms_by_name("mitotic cell cycle")->size() == 2);
ok($onto->get_terms_by_name("mitotic cell cycle")->contains($n1));
ok($onto->get_terms_by_name("mitotic cell cycle")->contains($n3));

ok(($onto->get_terms_by_name("cell cycle process")->get_set())[0]->id() eq $n2->id());
ok(($onto->get_terms_by_name("re-entry into mitotic cell cycle after pheromone arrest")->get_set())[0]->id() eq $n3->id());

ok($onto->get_terms_by_name("cell cycle")->size() == 3);
$so->imports("o1", "02");
$so->date("11:03:2007 21:46");
$so->data_version("09:03:2007 19:30");
$so->idspace_as_string("CCO", "http://www.cellcycleontology.org/ontology/CCO", "cell cycle terms");
ok($so->idspace->local_idspace() eq "CCO");
ok($so->idspace->uri() eq "http://www.cellcycleontology.org/ontology/CCO");
ok($so->idspace->description() eq "cell cycle terms");
$so->remark("This is a test ontology");
$so->subsets("Jukumari Term used for jukumari", "Jukucha Term used for jukucha");
my $std1 = CCO::Core::SynonymTypeDef->new();
my $std2 = CCO::Core::SynonymTypeDef->new();
$std1->synonym_type_def_as_string("acronym", "acronym", "EXACT");
$std2->synonym_type_def_as_string("common_name", "common name", "EXACT");
$so->synonym_type_def_set($std1, $std2);
$n1->subset("Jukumari");
$n1->subset("Jukucha");
$n2->def_as_string("This is a dummy definition", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"] {opt=first}");
$n1->xref_set_as_string("CCO:ea");
$n3->synonym_as_string("This is a dummy synonym definition", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"] {opt=first}", "EXACT");
$n3->alt_id("CCO:P0000033");
$n3->namespace("cellcycle");
$n3->is_obsolete("1");
$n3->union_of("GO:0001");
$n3->union_of("GO:0002");
$n2->intersection_of("GO:0003");
$n2->intersection_of("part_of GO:0004");
#$so->export(\*STDERR, 'owl');
#$so->export(\*STDERR, 'obo');
ok($onto->get_number_of_relationships() == 6);
$onto->create_rel($n4, 'part_of', $n5);
ok($onto->get_number_of_relationships() == 7);
ok(1);

# subontology tests
my $my_parser = CCO::Parser::OBOParser->new();
my $alpha_onto = $my_parser->work("./t/data/alpha.obo");

my $root = $alpha_onto->get_term_by_id("MYO:0000000");
my $sub_o = $alpha_onto->get_subontology_from($root);
ok ($sub_o->get_number_of_terms() == 16);

$root = $alpha_onto->get_term_by_id("MYO:0000002");
$sub_o = $alpha_onto->get_subontology_from($root);
ok ($sub_o->get_number_of_terms() == 9);

$root = $alpha_onto->get_term_by_id("MYO:0000014");
$sub_o = $alpha_onto->get_subontology_from($root);
ok ($sub_o->get_number_of_terms() == 2);

# get paths from term1 to term2

my $o1  = CCO::Core::Ontology->new();
my $d5  = CCO::Core::Term->new();
my $d2  = CCO::Core::Term->new();
my $d6  = CCO::Core::Term->new();
my $d1  = CCO::Core::Term->new();
my $d7  = CCO::Core::Term->new();
my $d8  = CCO::Core::Term->new();
my $d10 = CCO::Core::Term->new();
my $d11 = CCO::Core::Term->new();

my $d20  = CCO::Core::Term->new();
my $d21  = CCO::Core::Term->new();
my $d32  = CCO::Core::Term->new();
my $d23  = CCO::Core::Term->new();
my $d24  = CCO::Core::Term->new();
my $d25  = CCO::Core::Term->new();
my $d26  = CCO::Core::Term->new();
my $d27  = CCO::Core::Term->new();
my $d28  = CCO::Core::Term->new();
my $d29  = CCO::Core::Term->new();

$d5->id("5");
$d2->id("2");
$d6->id("6");
$d1->id("1");
$d7->id("7");
$d8->id("8");
$d10->id("10");
$d11->id("11");

$d20->id("20");
$d21->id("21");
$d32->id("32");
$d23->id("23");
$d24->id("24");
$d25->id("25");
$d26->id("26");
$d27->id("27");
$d28->id("28");
$d29->id("29");


$d5->name("5");
$d2->name("2");
$d6->name("6");
$d1->name("1");
$d7->name("7");
$d8->name("8");
$d10->name("10");
$d11->name("11");

$d20->name("20");
$d21->name("21");
$d32->name("32");
$d23->name("23");
$d24->name("24");
$d25->name("25");
$d26->name("26");
$d27->name("27");
$d28->name("28");
$d29->name("29");

my $r = 'is_a';
$o1->add_relationship_type_as_string($r, $r);
$o1->create_rel($d5,$r,$d2);
$o1->create_rel($d2,$r,$d6);
$o1->create_rel($d2,$r,$d1);
$o1->create_rel($d2,$r,$d7);
$o1->create_rel($d7,$r,$d8);
$o1->create_rel($d7,$r,$d11);
$o1->create_rel($d1,$r,$d10);
$o1->create_rel($d1,$r,$d8);


$o1->create_rel($d5,$r,$d23);
$o1->create_rel($d11,$r,$d28);
$o1->create_rel($d28,$r,$d29);
$o1->create_rel($d8,$r,$d27);
$o1->create_rel($d27,$r,$d26);
$o1->create_rel($d10,$r,$d24);
$o1->create_rel($d24,$r,$d25);
$o1->create_rel($d25,$r,$d26);
$o1->create_rel($d6,$r,$d20);
$o1->create_rel($d20,$r,$d21);
$o1->create_rel($d20,$r,$d32);
$o1->create_rel($d21,$r,$d25);

my @ref_paths = $o1->get_paths_term1_term2($d5->id(), $d26->id());
ok ($#ref_paths == 3);

@ref_paths = $o1->get_paths_term1_term2($d5->id(), $d29->id());
ok ($#ref_paths == 0);

my @p = ("5_is_a_2", "2_is_a_7", "7_is_a_11", "11_is_a_28", "28_is_a_29");

foreach my $ref_path (@ref_paths) {
	foreach my $tt (@$ref_path) {
		ok ($tt->id() eq shift @p);
	}
}


my $stop  = CCO::Util::Set->new();
map {$stop->add($_->id())} @{$o1->get_terms()};

my @pref1 = $o1->get_paths_term_terms($d5->id(), $stop);
ok ($#pref1 == 22);
