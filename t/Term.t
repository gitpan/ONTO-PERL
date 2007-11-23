# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Term.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 66;
}

#########################

use CCO::Core::Term;
use CCO::Core::Def;
use CCO::Util::DbxrefSet;
use CCO::Core::Dbxref;
use CCO::Core::Synonym;
use strict;

# three new terms
my $n1 = CCO::Core::Term->new();
my $n2 = CCO::Core::Term->new();
my $n3 = CCO::Core::Term->new();

# name, namespace, code
ok($n1->idspace() eq "NN");
ok($n1->subnamespace() eq "X");
ok($n1->code() eq "0000000");

# id's
$n1->id("CCO:P0000001");
ok($n1->id() eq "CCO:P0000001");
$n2->id("CCO:P0000002");
ok($n2->id() eq "CCO:P0000002");
$n3->id("CCO:P0000003");
ok($n3->id() eq "CCO:P0000003");

# name, namespace, code
ok($n1->idspace() eq "CCO");
ok($n1->subnamespace() eq "P");
ok($n1->code() eq "0000001");

# alt_id
$n1->alt_id("CCO:P0000001_alt_id");
ok(($n1->alt_id()->get_set())[0] eq "CCO:P0000001_alt_id");
$n2->alt_id("CCO:P0000002_alt_id1", "CCO:P0000002_alt_id2", "CCO:P0000002_alt_id3", "CCO:P0000002_alt_id4");
ok(($n2->alt_id()->get_set())[0] eq "CCO:P0000002_alt_id1");
ok(($n2->alt_id()->get_set())[1] eq "CCO:P0000002_alt_id2");
ok(($n2->alt_id()->get_set())[2] eq "CCO:P0000002_alt_id3");
ok(($n2->alt_id()->get_set())[3] eq "CCO:P0000002_alt_id4");
ok(!defined (($n3->alt_id()->get_set())[0]));
ok(!$n3->alt_id()->get_set());

# subset
$n1->subset("CCO:P0000001_subset");
ok(($n1->subset())[0] eq "CCO:P0000001_subset");
$n2->subset("CCO:P0000002_subset1", "CCO:P0000002_subset2", "CCO:P0000002_subset3", "CCO:P0000002_subset4");
ok(($n2->subset())[0] eq "CCO:P0000002_subset1");
ok(($n2->subset())[1] eq "CCO:P0000002_subset2");
ok(($n2->subset())[2] eq "CCO:P0000002_subset3");
ok(($n2->subset())[3] eq "CCO:P0000002_subset4");
ok(!defined (($n3->subset())[0]));
ok(!$n3->subset());

# name
$n1->name("One");
ok($n1->name() eq "One");
$n2->name("Two");
ok($n2->name() eq "Two");
$n3->name("Three");
ok($n3->name() eq "Three");

ok($n1->is_obsolete() == 0); # not defined value.
$n1->is_obsolete(1);
ok($n1->is_obsolete() != 0);
ok($n1->is_obsolete() == 1);
$n1->is_obsolete(0);
ok($n1->is_obsolete() == 0);
ok($n1->is_obsolete() != 1);

ok($n1->is_anonymous() == 0); # not defined value.
$n1->is_anonymous(1);
ok($n1->is_anonymous() != 0);
ok($n1->is_anonymous() == 1);
$n1->is_anonymous(0);
ok($n1->is_anonymous() == 0);
ok($n1->is_anonymous() != 1);

# synonyms
my $syn1 = CCO::Core::Synonym->new();
$syn1->type('EXACT');
my $def1 = CCO::Core::Def->new();
$def1->text("Hola mundo1");
my $sref1 = CCO::Core::Dbxref->new();
$sref1->name("CCO:vm");
my $srefs_set1 = CCO::Util::DbxrefSet->new();
$srefs_set1->add($sref1);
$def1->dbxref_set($srefs_set1);
$syn1->def($def1);
$n1->synonym_set($syn1);

my $syn2 = CCO::Core::Synonym->new();
$syn2->type('BROAD');
my $def2 = CCO::Core::Def->new();
$def2->text("Hola mundo2");
my $sref2 = CCO::Core::Dbxref->new();
$sref2->name("CCO:ls");
$srefs_set1->add_all($sref1);
my $srefs_set2 = CCO::Util::DbxrefSet->new();
$srefs_set2->add_all($sref1, $sref2);
$def2->dbxref_set($srefs_set2);
$syn2->def($def2);
$n2->synonym_set($syn2);

ok(!defined (($n3->synonym_set())[0]));
ok(!$n3->synonym_set());

my $syn3 = CCO::Core::Synonym->new();
$syn3->type('BROAD');
my $def3 = CCO::Core::Def->new();
$def3->text("Hola mundo2");
my $sref3 = CCO::Core::Dbxref->new();
$sref3->name("CCO:ls");
my $srefs_set3 = CCO::Util::DbxrefSet->new();
$srefs_set3->add_all($sref1, $sref2);
$def3->dbxref_set($srefs_set3);
$syn3->def($def3);
$n3->synonym_set($syn3);

ok(($n1->synonym_set())[0]->equals($syn1));
ok(($n2->synonym_set())[0]->equals($syn2));
ok(($n3->synonym_set())[0]->equals($syn3));
ok(($n2->synonym_set())[0]->type() eq 'BROAD');
ok(($n2->synonym_set())[0]->def()->equals(($n3->synonym_set())[0]->def()));
ok(($n2->synonym_set())[0]->equals(($n3->synonym_set())[0]));

# synonym as string
ok(($n2->synonym_as_string())[0] eq "\"Hola mundo2\" [CCO:ls, CCO:vm]");
$n2->synonym_as_string("Hello world2", "[CCO:vm2, CCO:ls2]", "EXACT");
ok(($n2->synonym_as_string())[0] eq "\"Hello world2\" [CCO:ls2, CCO:vm2]");
ok(($n2->synonym_as_string())[1] eq "\"Hola mundo2\" [CCO:ls, CCO:vm]");

# xref
my $xref1 = CCO::Core::Dbxref->new();
my $xref2 = CCO::Core::Dbxref->new();
my $xref3 = CCO::Core::Dbxref->new();
my $xref4 = CCO::Core::Dbxref->new();
my $xref5 = CCO::Core::Dbxref->new();

$xref1->name("XCCO:vm");
$xref2->name("XCCO:ls");
$xref3->name("XCCO:ea");
$xref4->name("XCCO:vm");
$xref5->name("XCCO:ls");

my $xrefs_set = CCO::Util::DbxrefSet->new();
$xrefs_set->add_all($xref1, $xref2, $xref3, $xref4, $xref5);
$n1->xref_set($xrefs_set);
ok($n1->xref_set()->contains($xref3));
my $xref_length = $n1->xref_set()->size();
ok($xref_length == 3);

# xref_set_as_string
my @empty_refs = $n2->xref_set_as_string();
ok($#empty_refs == -1);
$n2->xref_set_as_string("[YCCO:vm, YCCO:ls, YCCO:ea \"Erick Antezana\"] {opt=first}");
my @xrefs_n2 = $n2->xref_set()->get_set();
my %xr_n2;
foreach my $xref_n2 (@xrefs_n2) {
	$xr_n2{$xref_n2->name()} = $xref_n2->name();
}
ok($xr_n2{"YCCO:vm"} eq "YCCO:vm");
ok($xr_n2{"YCCO:ls"} eq "YCCO:ls");
ok($xr_n2{"YCCO:ea"} eq "YCCO:ea");

# def
my $def = CCO::Core::Def->new();
$def->text("Hola mundo");
my $ref1 = CCO::Core::Dbxref->new();
my $ref2 = CCO::Core::Dbxref->new();
my $ref3 = CCO::Core::Dbxref->new();

$ref1->name("CCO:vm");
$ref2->name("CCO:ls");
$ref3->name("CCO:ea");

my $refs_set = CCO::Util::DbxrefSet->new();
$refs_set->add_all($ref1,$ref2,$ref3);
$def->dbxref_set($refs_set);
$n1->def($def);
ok($n1->def()->text() eq "Hola mundo");
ok($n1->def()->dbxref_set()->size == 3);
$n2->def($def);

# def as string
ok($n2->def_as_string() eq "\"Hola mundo\" [CCO:ea, CCO:ls, CCO:vm]");
$n2->def_as_string("This is a dummy definition", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\" {opt=first}]");
ok($n2->def()->text() eq "This is a dummy definition");
my @refs_n2 = $n2->def()->dbxref_set()->get_set();
my %r_n2;
foreach my $ref_n2 (@refs_n2) {
	$r_n2{$ref_n2->name()} = $ref_n2->name();
}
ok($n2->def()->dbxref_set()->size == 3);
ok($r_n2{"CCO:vm"} eq "CCO:vm");
ok($r_n2{"CCO:ls"} eq "CCO:ls");
ok($r_n2{"CCO:ea"} eq "CCO:ea");
ok($n2->def_as_string() eq "\"This is a dummy definition\" [CCO:ea \"Erick Antezana\" {opt=first}, CCO:ls, CCO:vm]");

# disjoint_from:
$n2->disjoint_from($n1->id(), $n3->id());
my @dis = sort {$a cmp $b} $n2->disjoint_from();
ok($#dis == 1);
ok($dis[0] eq $n1->id());
ok($dis[1] eq $n3->id());

ok(1);
