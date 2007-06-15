# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl SynonymTypeDef.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 8;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Core::SynonymTypeDef;

use strict;

my $std1 = CCO::Core::SynonymTypeDef->new();
my $std2 = CCO::Core::SynonymTypeDef->new();


# synonym_type_name
$std1->synonym_type_name("goslim_plant");
ok ($std1->synonym_type_name() eq "goslim_plant");
$std2->synonym_type_name("goslim_yeast");
ok ($std2->synonym_type_name() eq "goslim_yeast");

# description
$std1->description("Plant GO slim");
ok ($std1->description() eq "Plant GO slim");
$std2->description("Yeast GO slim");
ok ($std2->description() eq "Yeast GO slim");

# scope
$std1->scope("EXACT");
ok ($std1->scope() eq "EXACT");
$std2->scope("BROAD");
ok ($std2->scope() eq "BROAD");
# synonym type def as string

my $std3 = CCO::Core::SynonymTypeDef->new();

$std3->synonym_type_def_as_string("goslim_plant", "Plant GO slim", "EXACT");

ok($std1->equals($std3));

ok(1);
