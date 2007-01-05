# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Ontology.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 108;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# $Id: Ontology.pm 291 2006-06-01 16:21:45Z erant $
#
# Purpose : onto-perl usage examples.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
use CCO::Core::Ontology;
use CCO::Core::Term;
use CCO::Core::Relationship;
use CCO::Core::RelationshipType;
use strict;
#use Data::Dumper;

# three new terms
my $n1 = CCO::Core::Term->new();
my $n2 = CCO::Core::Term->new();
my $n3 = CCO::Core::Term->new();

# new ontology
my $onto = CCO::Core::Ontology->new;
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
$def3->text("Definition of Three");
$n1->def($def1);
$n2->def($def2);
$n3->def($def3);

$onto->add_term($n1);
ok($onto->has_term($n1) == 1);
$onto->add_term($n2);
ok($onto->has_term($n2) == 1);
$onto->add_term($n3);
ok($onto->has_term($n3) == 1);

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
foreach my $t (@{$onto->get_terms()}) {
	$h{$t->id()} = $t;
	$c++;
}
ok($c == 5);
ok($h{"CCO:P0000001"}->name() eq "One");
ok($h{"CCO:P0000002"}->name() eq "Two");
ok($h{"CCO:P0000003"}->name() eq "Three");
ok($h{"CCO:P0000004"}->name() eq "Four");
ok($h{"CCO:P0000005"}->name() eq "Five");

# get terms with argument
my @processes = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P.*")};
ok($#processes == 4);
my @odd_processes = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P000000[35]")};
ok($#odd_processes == 1);
ok($odd_processes[0]->id() eq "CCO:P0000003");
ok($odd_processes[1]->id() eq "CCO:P0000005");
$onto->namespace("CCO");
my @same_processes = @{$onto->get_terms_by_subnamespace("P")};
ok(@same_processes == @processes);
my @no_processes = @{$onto->get_terms_by_subnamespace("p")};
ok($#no_processes == -1);

# get terms
ok($onto->get_term_by_id("CCO:P0000001")->name() eq "One");
ok($onto->get_term_by_name("One")->id() eq "CCO:P0000001");
ok($onto->get_term_by_name("Two")->id() eq "CCO:P0000002");
ok($onto->get_term_by_name("Three")->id() eq "CCO:P0000003");
ok($onto->get_term_by_name("Four")->id() eq "CCO:P0000004");

# add relationships
$onto->add_relationship($r12);
ok($onto->get_relationship_by_id("CCO:P0000001_is_a_CCO:P0000002")->head()->id() eq "CCO:P0000002");
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
$r11_21->id("CCO:R0001121"); $r11_21->type("r11-21");
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

# get children
my @children = @{$onto->get_child_terms($n1)}; 
ok(scalar(@children) == 0);

@children = @{$onto->get_child_terms($n3)}; 
ok($#{@children} == 1);
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

$r1->id("CCO:R0000001");
$r2->id("CCO:R0000002");
$r3->id("CCO:R0000003");

$r1->name("is_a");
$r2->name("part_of");
$r3->name("participates_in");




# add relationship types
ok($onto->get_number_of_relationship_types() == 0);
$onto->add_relationship_type($r1);
ok($onto->has_relationship_type($r1) == 1);
$onto->add_relationship_type($r2);
ok($onto->has_relationship_type($r2) == 1);
$onto->add_relationship_type($r3);
ok($onto->has_relationship_type($r3) == 1);
ok($onto->get_number_of_relationship_types() == 3);

# get descendents or ancestors linked by a particular relationship type 
my $rel_type1 = $onto->get_relationship_type_by_name("is_a");
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
my $relationship_type = $onto->add_relationship_type_as_string("CCO:R0000004", "has_participant");
ok($onto->has_relationship_type($relationship_type) == 1);
ok($onto->get_relationship_type_by_id("CCO:R0000004")->equals($relationship_type));
ok($onto->get_number_of_relationship_types() == 4);

# get relationship types
my @rt = @{$onto->get_relationship_types()};
ok(scalar @rt == 4);
my %rrt;
foreach my $relt (@rt) {
	$rrt{$relt->name()} = $relt;
}
ok($rrt{"is_a"}->name() eq "is_a");
ok($rrt{"part_of"}->name() eq "part_of");
ok($rrt{"participates_in"}->name() eq "participates_in");

ok($onto->get_relationship_type_by_id("CCO:R0000001")->name() eq "is_a");
ok($onto->get_relationship_type_by_name("is_a")->id() eq "CCO:R0000001");
ok($onto->get_relationship_type_by_name("part_of")->id() eq "CCO:R0000002");
ok($onto->get_relationship_type_by_name("participates_in")->id() eq "CCO:R0000003");

my @rtbt = @{$onto->get_relationship_types_by_term($n1)};

my %rtbth;
foreach my $relt (@rtbt) {
	$rtbth{$relt} = $relt;
}
ok($rtbth{"participates_in"} eq "participates_in");
ok($rtbth{"is_a"} eq "is_a");

# get_head_by_relationship_type
my @heads_n1 = @{$onto->get_head_by_relationship_type($n1, $onto->get_relationship_type_by_name("participates_in"))};
my %hbrt;
foreach my $head (@heads_n1) {
	$hbrt{$head->id()} = $head;
}
ok($hbrt{"CCO:P0000003"}->equals($n3));
ok($hbrt{"CCO:P0000004"}->equals($n4));
ok(@{$onto->get_head_by_relationship_type($n1, $onto->get_relationship_type_by_name("is_a"))}[0]->equals($n2));

# get_tail_by_relationship_type
ok(@{$onto->get_tail_by_relationship_type($n3, $onto->get_relationship_type_by_name("participates_in"))}[0]->equals($n1));
ok(@{$onto->get_tail_by_relationship_type($n2, $onto->get_relationship_type_by_name("is_a"))}[0]->equals($n1));

#export
#$onto->export(\*STDERR);


ok(1);
