# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl RelationshipType.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 63;
}

#########################

use OBO::Core::RelationshipType;
use OBO::Core::Synonym;
use strict;

# three new relationships types
my $r1 = OBO::Core::RelationshipType->new();
my $r2 = OBO::Core::RelationshipType->new();
my $r3 = OBO::Core::RelationshipType->new();

$r1->id("CCO:L0000001");
$r2->id("CCO:L0000002");
$r3->id("CCO:L0000003");

ok($r1->is_anonymous() == 0); # not defined value.
$r1->is_anonymous(1);
ok($r1->is_anonymous() != 0);
ok($r1->is_anonymous() == 1);
$r1->is_anonymous(0);
ok($r1->is_anonymous() == 0);
ok($r1->is_anonymous() != 1);

$r1->name("is a");
$r2->name("part of");
$r3->name("participates in");

ok(!$r1->equals($r2));
ok(!$r2->equals($r3));
ok(!$r3->equals($r1));

# rel. type creator + date
$r1->created_by("erick_antezana");
ok($r1->created_by() eq "erick_antezana");
$r1->creation_date("2008-04-13T01:32:36Z ");
ok($r1->creation_date() eq "2008-04-13T01:32:36Z ");

# rel. type modificator + date
$r1->modified_by("erick_antezana");
ok($r1->modified_by() eq "erick_antezana");
$r1->modification_date("2008-04-13T01:32:36Z ");
ok($r1->modification_date() eq "2008-04-13T01:32:36Z ");

# default values
ok(!$r1->is_anti_symmetric());
ok(!$r1->is_cyclic());
ok(!$r1->is_metadata_tag());
ok(!$r1->is_reflexive());
ok(!$r1->is_symmetric());
ok(!$r1->is_transitive());

# inverse
my $r3_inv = OBO::Core::RelationshipType->new();
$r3_inv->id("CCO:L0000004");
$r3_inv->name("has participant");
$r3->def_as_string("This is the inverse rel of r3", '[CCO:ea]');
$r3_inv->inverse_of($r3);
ok($r3->inverse_of()->equals($r3_inv));
ok($r3_inv->inverse_of()->equals($r3));

# def as string
$r2->def_as_string("This is a dummy definition", '[CCO:vm, CCO:ls, CCO:ea "Erick Antezana", http://mydomain.com/key1=value1&key2=value2]');
ok($r2->def()->text() eq "This is a dummy definition");
my @refs_r2 = $r2->def()->dbxref_set()->get_set();
my %r_r2;
foreach my $ref_r2 (@refs_r2) {
	$r_r2{$ref_r2->name()} = $ref_r2->name();
}
ok($r_r2{"CCO:vm"} eq "CCO:vm");
ok($r_r2{"CCO:ls"} eq "CCO:ls");
ok($r_r2{"CCO:ea"} eq "CCO:ea");
ok($r_r2{"http://mydomain.com/key1=value1&key2=value2"} eq "http://mydomain.com/key1=value1&key2=value2");


# synonyms
my $syn1 = OBO::Core::Synonym->new();
$syn1->scope('EXACT');
my $def1 = OBO::Core::Def->new();
$def1->text("is_a");
my $sref1 = OBO::Core::Dbxref->new();
$sref1->name("CCO:vm");
my $srefs_set1 = OBO::Util::DbxrefSet->new();
$srefs_set1->add($sref1);
$def1->dbxref_set($srefs_set1);
$syn1->def($def1);
$r1->synonym_set($syn1);

my $syn2 = OBO::Core::Synonym->new();
$syn2->scope('BROAD');
my $def2 = OBO::Core::Def->new();
$def2->text("part_of");
my $sref2 = OBO::Core::Dbxref->new();
$sref2->name("CCO:ls");
$srefs_set1->add_all($sref1);
my $srefs_set2 = OBO::Util::DbxrefSet->new();
$srefs_set2->add_all($sref1, $sref2);
$def2->dbxref_set($srefs_set2);
$syn2->def($def2);
$r2->synonym_set($syn2);

ok(!defined (($r3->synonym_set())[0]));
ok(!$r3->synonym_set());

my $syn3 = OBO::Core::Synonym->new();
$syn3->scope('BROAD');
my $def3 = OBO::Core::Def->new();
$def3->text("part_of"); # fake synonym
my $sref3 = OBO::Core::Dbxref->new();
$sref3->name("CCO:ls");
my $srefs_set3 = OBO::Util::DbxrefSet->new();
$srefs_set3->add_all($sref1, $sref2);
$def3->dbxref_set($srefs_set3);
$syn3->def($def3);
$r3->synonym_set($syn3);

ok(($r1->synonym_set())[0]->equals($syn1));
ok(($r2->synonym_set())[0]->equals($syn2));
ok(($r3->synonym_set())[0]->equals($syn3));
ok(($r2->synonym_set())[0]->scope() eq 'BROAD');
ok(($r2->synonym_set())[0]->def()->equals(($r3->synonym_set())[0]->def()));
ok(($r2->synonym_set())[0]->equals(($r3->synonym_set())[0]));

# synonym as string
ok(($r2->synonym_as_string())[0] eq '"part_of" [CCO:ls, CCO:vm]');
$r2->synonym_as_string("part_of", '[CCO:vm2, CCO:ls2]', "EXACT");
ok(($r2->synonym_as_string())[0] eq '"part_of" [CCO:ls, CCO:vm]');
ok(($r2->synonym_as_string())[1] eq '"part_of" [CCO:ls2, CCO:vm2]');

# xref
my $xref1 = OBO::Core::Dbxref->new();
my $xref2 = OBO::Core::Dbxref->new();
my $xref3 = OBO::Core::Dbxref->new();
my $xref4 = OBO::Core::Dbxref->new();
my $xref5 = OBO::Core::Dbxref->new();

$xref1->name("XCCO:vm");
$xref2->name("XCCO:ls");
$xref3->name("XCCO:ea");
$xref4->name("XCCO:vm");
$xref5->name("XCCO:ls");

my $xrefs_set = OBO::Util::DbxrefSet->new();
$xrefs_set->add_all($xref1, $xref2, $xref3, $xref4, $xref5);
$r1->xref_set($xrefs_set);
ok($r1->xref_set()->contains($xref3));
my $xref_length = $r1->xref_set()->size();
ok($xref_length == 3);

# xref_set_as_string
my @empty_refs = $r2->xref_set_as_string();
ok($#empty_refs == -1);
$r2->xref_set_as_string('[YCCO:vm, YCCO:ls, YCCO:ea "Erick Antezana" {opt=first}]');
my @xrefs_r2 = $r2->xref_set()->get_set();
my %xr_r2;
foreach my $xref_r2 (@xrefs_r2) {
	$xr_r2{$xref_r2->name()} = $xref_r2->name();
}
ok($xr_r2{"YCCO:vm"} eq "YCCO:vm");
ok($xr_r2{"YCCO:ls"} eq "YCCO:ls");
ok($xr_r2{"YCCO:ea"} eq "YCCO:ea");

# subset
$r1->subset("CCO:P0000001_subset");
ok(($r1->subset())[0] eq "CCO:P0000001_subset");
$r2->subset("CCO:P0000002_subset1", "CCO:P0000002_subset2", "CCO:P0000002_subset3", "CCO:P0000002_subset4");
ok(($r2->subset())[0] eq "CCO:P0000002_subset1");
ok(($r2->subset())[1] eq "CCO:P0000002_subset2");
ok(($r2->subset())[2] eq "CCO:P0000002_subset3");
ok(($r2->subset())[3] eq "CCO:P0000002_subset4");
ok(!defined (($r3->subset())[0]));
ok(!$r3->subset());

# holds_over_chain
$r3->holds_over_chain($r1->id(), $r2->id());
ok(!defined $r1->holds_over_chain()->get_set());
ok(!defined $r2->holds_over_chain()->get_set());
my @hoc = $r3->holds_over_chain()->get_set();
ok(scalar(@hoc) == 1);
foreach my $holds_over_chain ($r3->holds_over_chain()->get_set()) {
	ok(@{$holds_over_chain}[0] eq $r1->id());
	ok(@{$holds_over_chain}[1] eq $r2->id());
}

# functional and inverse functional
ok(!$r1->functional());
ok(!$r1->inverse_functional());
ok(!$r2->functional());
ok(!$r2->inverse_functional());
$r1->functional(1);
$r1->inverse_functional(1);
$r2->functional(1);
$r2->inverse_functional(1);
ok($r1->functional());
ok($r1->inverse_functional());
ok($r2->functional());
ok($r2->inverse_functional());

ok(1);
