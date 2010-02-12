# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl RelationshipType.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 39;
}

#########################
# $Id: RelationshipType.t 291 2006-06-01 16:21:45Z erant $
#
# Purpose : ONTO-PERL usage examples.
# Contact : Erick Antezana <erick.antezana@gmail.com>
#
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

$r1->name("is a");
$r2->name("part of");
$r3->name("participates in");

ok(!$r1->equals($r2));
ok(!$r2->equals($r3));
ok(!$r3->equals($r1));

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
$r3_inv->inverse_of($r3);
ok($r3->inverse_of()->equals($r3_inv));

# def as string
$r2->def_as_string("This is a dummy definition", '[CCO:vm, CCO:ls, CCO:ea "Erick Antezana"]');
ok($r2->def()->text() eq "This is a dummy definition");
my @refs_r2 = $r2->def()->dbxref_set()->get_set();
my %r_r2;
foreach my $ref_r2 (@refs_r2) {
	$r_r2{$ref_r2->name()} = $ref_r2->name();
}
ok($r_r2{"CCO:vm"} eq "CCO:vm");
ok($r_r2{"CCO:ls"} eq "CCO:ls");
ok($r_r2{"CCO:ea"} eq "CCO:ea");

# synonyms
my $syn1 = OBO::Core::Synonym->new();
$syn1->type('EXACT');
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
$syn2->type('BROAD');
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
$syn3->type('BROAD');
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
ok(($r2->synonym_set())[0]->type() eq 'BROAD');
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

ok(1);
