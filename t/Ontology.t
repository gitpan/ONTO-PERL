# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Ontology.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 227;
}

#########################
#
# Purpose : ONTO-PERL usage examples.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
use OBO::Core::Ontology;
use OBO::Core::Term;
use OBO::Core::Relationship;
use OBO::Core::RelationshipType;
use OBO::Core::SynonymTypeDef;
use OBO::Parser::OBOParser;
use OBO::Util::TermSet;


# three new terms
my $n1 = OBO::Core::Term->new();
my $n2 = OBO::Core::Term->new();
my $n3 = OBO::Core::Term->new();

# new ontology
my $onto = OBO::Core::Ontology->new();
ok($onto->get_number_of_terms() == 0);
ok($onto->get_number_of_relationships() == 0);
ok(1);

my $my_ssd = OBO::Core::SubsetDef->new();
$my_ssd->as_string("GO_SS", "Term used for My GO");
$onto->subset_def_set($my_ssd);

my @my_ssd = $onto->subset_def_set()->get_set();
ok($my_ssd[0]->name() eq "GO_SS");
ok($my_ssd[0]->description() eq "Term used for My GO");

$n1->id("CCO:P0000001");
$n2->id("CCO:P0000002");
$n3->id("CCO:P0000003");

$n1->name("One");
$n2->name("Two");
$n3->name("Three");

my $def1 = OBO::Core::Def->new();
$def1->text("Definition of One");
my $def2 = OBO::Core::Def->new();
$def2->text("Definition of Two");
my $def3 = OBO::Core::Def->new();
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
my $n4 = OBO::Core::Term->new();
$n4->id("CCO:P0000004");
$n4->name("Four");
my $def4 = OBO::Core::Def->new();
$def4->text("Definition of Four");
$n4->def($def4);
ok($onto->has_term($n4) == 0);
$onto->delete_term($n4);
ok($onto->has_term($n4) == 0);
$onto->add_term($n4);
ok($onto->has_term($n4) == 1);

# add term as string
my $new_term = $onto->add_term_as_string("CCO:P0000005", "Five");
$new_term->def_as_string("This is a dummy definition", '[CCO:vm, CCO:ls, CCO:ea "Erick Antezana"]');
ok($onto->has_term($new_term) == 1);
ok($onto->get_term_by_id("CCO:P0000005")->equals($new_term));
ok($onto->get_number_of_terms() == 5);
my $n5 = $new_term; 

# five new relationships
my $r12 = OBO::Core::Relationship->new();
my $r23 = OBO::Core::Relationship->new();
my $r13 = OBO::Core::Relationship->new();
my $r14 = OBO::Core::Relationship->new();
my $r35 = OBO::Core::Relationship->new();

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
my @processes         = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P.*")};
my @sorted_processes  = @{$onto->get_terms_sorted_by_id("CCO:P.*")};
my @sorted_processes2 = @{$onto->get_terms_sorted_by_id()};
ok($#processes == $#sorted_processes); # should be 5
for (my $i = 0; $i <= $#sorted_processes; $i++) {
	ok($processes[$i]->id() eq $sorted_processes[$i]->id());
	ok($processes[$i]->id() eq $sorted_processes2[$i]->id());
}
ok($#processes == 4);
ok($#sorted_processes2 == 4);

my @odd_processes        = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P000000[35]")};
my @sorted_odd_processes = @{$onto->get_terms_sorted_by_id("CCO:P000000[35]")};
ok($#odd_processes == $#sorted_odd_processes); # should be 2
for (my $i = 0; $i <= $#sorted_odd_processes; $i++) {
	ok($odd_processes[$i]->id() eq $sorted_odd_processes[$i]->id());
}
ok($#odd_processes == 1);
ok($odd_processes[0]->id() eq "CCO:P0000003");
ok($odd_processes[1]->id() eq "CCO:P0000005");

# IDspace's
my $ids = $onto->idspaces();
ok($ids->is_empty() == 1);
my $id1 = OBO::Core::IDspace->new();
$id1->as_string("CCO", "http://www.cellcycle.org/ontology/CCO", "cell cycle ontology terms");
$onto->idspaces($id1);
ok(($onto->idspaces()->get_set())[0]->local_idspace() eq "CCO");
my @same_processes = @{$onto->get_terms_by_subnamespace("P")};
ok(@same_processes == @processes);
my @no_processes = @{$onto->get_terms_by_subnamespace("p")};
ok($#no_processes == -1);

# get term and terms
ok($onto->get_term_by_id("CCO:P0000001")->name() eq "Uj");
ok($onto->get_term_by_name("Uj")->equals($n1));
$n1->synonym_as_string("Uno", "[CCO:ls, CCO:vm]", "EXACT");
ok(($n1->synonym_as_string())[0] eq "\"Uno\" [CCO:ls, CCO:vm]");
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
my $n11 = OBO::Core::Term->new();
my $n21 = OBO::Core::Term->new();
$n11->id("CCO:P0000011"); $n11->name("One one"); $n11->def_as_string("Definition One one", "");
$n21->id("CCO:P0000021"); $n21->name("Two one"); $n21->def_as_string("Definition Two one", "");
my $r11_21 = OBO::Core::Relationship->new();
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

# get descendents of a term (using its unique ID)
@descendents1 = @{$onto->get_descendent_terms("CCO:P0000001")};
ok(scalar(@descendents1) == 0);
@descendents2 = @{$onto->get_descendent_terms("CCO:P0000002")};
ok(scalar(@descendents2) == 1);
ok($descendents2[0]->id eq "CCO:P0000001");
@descendents3 = @{$onto->get_descendent_terms("CCO:P0000003")};
ok(scalar(@descendents3) == 2);
@descendents5 = @{$onto->get_descendent_terms("CCO:P0000005")};
ok(scalar(@descendents5) == 3);

# get all ancestors
my @ancestors1 = @{$onto->get_ancestor_terms($n1)};
ok(scalar(@ancestors1) == 4);
my @ancestors2 = @{$onto->get_ancestor_terms($n2)};
ok(scalar(@ancestors2) == 2);
ok($ancestors2[0]->id() eq "CCO:P0000003" || $ancestors2[0]->id() eq "CCO:P0000005");
ok($ancestors2[1]->id() eq "CCO:P0000003" || $ancestors2[1]->id() eq "CCO:P0000005");
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
ok($ancestors2[0]->id() eq "CCO:P0000003" || $ancestors2[0]->id() eq "CCO:P0000005");
ok($ancestors2[1]->id() eq "CCO:P0000003" || $ancestors2[1]->id() eq "CCO:P0000005");
@ancestors3 = @{$onto->get_ancestor_terms_by_subnamespace($n3, 'P')};
ok(scalar(@ancestors3) == 1);
@ancestors3 = @{$onto->get_ancestor_terms_by_subnamespace($n3, 'R')};
ok(scalar(@ancestors3) == 0);


# three new relationships types
my $r1 = OBO::Core::RelationshipType->new();
my $r2 = OBO::Core::RelationshipType->new();
my $r3 = OBO::Core::RelationshipType->new();

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
my @rt  = @{$onto->get_relationship_types()};
my @srt = @{$onto->get_relationship_types_sorted_by_id()};
ok(scalar @rt == 4);
ok($#rt == $#srt);
my @RT = sort { $a->id() cmp $b->id() } @rt;
for (my $i = 0; $i<=$#srt; $i++) {
	ok($srt[$i]->name() eq $RT[$i]->name());
}

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

@rtbt = @{$onto->get_relationships_by_target_term($n3, "participates_in")};
foreach my $rel (@rtbt) {
	ok ($rel->id() eq "CCO:P0000001_participates_in_CCO:P0000003");
}

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
$onto->remarks("This is a test ontology");
#$onto->export(\*STDERR);

# subontology_by_terms
my $terms = OBO::Util::TermSet->new();
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

# More IDspace's tests
$ids = $onto->idspaces();
ok($ids->is_empty() == 0);
my $id2 = OBO::Core::IDspace->new();
my $id3 = OBO::Core::IDspace->new();

$id2->as_string("CCO", "http://www.cellcycle.org/ontology/CCO", "cell cycle ontology terms");
$id3->as_string("GO", "urn:lsid:bioontology.org:GO:", "gene ontology terms");
$so->idspaces($id2, $id3);

my $idspaces = $so->idspaces();
ok($idspaces->size() == 2);

my @IDs = sort {$a->local_idspace() cmp $b->local_idspace()} ($so->idspaces()->get_set());
ok($IDs[0]->as_string() eq "CCO http://www.cellcycle.org/ontology/CCO \"cell cycle ontology terms\"");
ok($IDs[1]->as_string() eq "GO urn:lsid:bioontology.org:GO: \"gene ontology terms\"");

$so->remarks("1. This is a test ontology", "2. This is a second remark", "3. This is the last remark");
my @remarks = sort ($so->remarks()->get_set());
ok($remarks[0] eq "1. This is a test ontology");
ok($remarks[1] eq "2. This is a second remark");
ok($remarks[2] eq "3. This is the last remark");

my $ssd1 = OBO::Core::SubsetDef->new();
my $ssd2 = OBO::Core::SubsetDef->new();
$ssd1->as_string("Jukumari", "Term used for jukumari");
$ssd2->as_string("Jukucha", "Term used for jukucha");
$so->subset_def_set($ssd1, $ssd2);

my @ssd = sort {$a->name() cmp $b->name()} $so->subset_def_set()->get_set();
ok($ssd[0]->name() eq "Jukucha");
ok($ssd[1]->name() eq "Jukumari");
ok($ssd[0]->description() eq "Term used for jukucha");
ok($ssd[1]->description() eq "Term used for jukumari");

my $std1 = OBO::Core::SynonymTypeDef->new();
my $std2 = OBO::Core::SynonymTypeDef->new();
$std1->as_string("acronym", "acronym", "EXACT");
$std2->as_string("common_name", "common name", "EXACT");
$so->synonym_type_def_set($std1, $std2);
$n1->subset("Jukumari");
$n1->subset("Jukucha");

my @terms_by_ss = @{$so->get_terms_by_subset("Jukumari")};
ok($terms_by_ss[0]->name() eq "mitotic cell cycle");
@terms_by_ss = @{$so->get_terms_by_subset("Jukucha")};
ok($terms_by_ss[0]->name() eq "mitotic cell cycle");

$n2->def_as_string("This is a dummy definition", '[CCO:vm, CCO:ls, CCO:ea "Erick Antezana" {opt=first}]');
$n1->xref_set_as_string("CCO:ea");
$n3->synonym_as_string("This is a dummy synonym definition", '[CCO:vm, CCO:ls, CCO:ea "Erick Antezana" {opt=first}]', "EXACT");
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

# subontology tests and get_root tests
my $my_parser = OBO::Parser::OBOParser->new();
my $alpha_onto = $my_parser->work("./t/data/alpha.obo");

my $root  = $alpha_onto->get_term_by_id("MYO:0000000");
my @roots = @{$alpha_onto->get_root_terms()};
my %raices;
foreach my $r (@roots) {
	$raices{$r->id()} = $r;
}
my @raicillas = ("MYO:33820", "MYO:0000000", "MYO:0000050", "MYO:0000557");
foreach my $rc (@raicillas) {
	ok ($alpha_onto->get_term_by_id($rc)->equals($raices{$rc}));
}

my $sub_o = $alpha_onto->get_subontology_from($root);
ok ($sub_o->get_number_of_terms() == 16);
@roots = @{$sub_o->get_root_terms()};
ok ($root->equals($roots[0])); # MYO:0000000

$root = $alpha_onto->get_term_by_id("MYO:0000002");
$sub_o = $alpha_onto->get_subontology_from($root);
ok ($sub_o->get_number_of_terms() == 9);
@roots = @{$sub_o->get_root_terms()};
ok ($root->equals($roots[0])); # MYO:0000002

$root = $alpha_onto->get_term_by_id("MYO:0000014");
$sub_o = $alpha_onto->get_subontology_from($root);
ok ($sub_o->get_number_of_terms() == 2);
@roots = @{$sub_o->get_root_terms()};
ok ($root->equals($roots[0])); # MYO:0000014

# get paths from term1 to term2

my $o1  = OBO::Core::Ontology->new();
my $d5  = OBO::Core::Term->new();
my $d2  = OBO::Core::Term->new();
my $d6  = OBO::Core::Term->new();
my $d1  = OBO::Core::Term->new();
my $d7  = OBO::Core::Term->new();
my $d8  = OBO::Core::Term->new();
my $d10 = OBO::Core::Term->new();
my $d11 = OBO::Core::Term->new();

my $d20  = OBO::Core::Term->new();
my $d21  = OBO::Core::Term->new();
my $d32  = OBO::Core::Term->new();
my $d23  = OBO::Core::Term->new();
my $d24  = OBO::Core::Term->new();
my $d25  = OBO::Core::Term->new();
my $d26  = OBO::Core::Term->new();
my $d27  = OBO::Core::Term->new();
my $d28  = OBO::Core::Term->new();
my $d29  = OBO::Core::Term->new();

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


my $stop  = OBO::Util::Set->new();
map {$stop->add($_->id())} @{$o1->get_terms()};

my @pref1 = $o1->get_paths_term_terms($d5->id(), $stop);
ok ($#pref1 == 22);
