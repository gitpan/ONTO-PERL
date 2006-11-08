# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Relationship.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 10;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# $Id: Relationship.t 291 2006-06-01 16:21:45Z erant $
#
# Purpose : onto-perl usage examples.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
use CCO::Core::Relationship;
use CCO::Core::Term;
use strict;

# three new relationships
my $r1 = CCO::Core::Relationship->new;
my $r2 = CCO::Core::Relationship->new;
my $r3 = CCO::Core::Relationship->new;

$r1->id("CCO:P0000001_is_a_CCO:P0000002");
$r2->id("CCO:P0000002_part_of_CCO:P0000003");
$r3->id("CCO:P0000001_has_child_CCO:P0000003");

$r1->type("is_a");
$r2->type("part_of");
$r3->type("has_child");

ok(!$r1->equals($r2));
ok(!$r2->equals($r3));
ok(!$r3->equals($r1));

# three new terms
my $n1 = CCO::Core::Term->new;
my $n2 = CCO::Core::Term->new;
my $n3 = CCO::Core::Term->new;

$n1->id("CCO:P0000001");
$n2->id("CCO:P0000002");
$n3->id("CCO:P0000003");

$n1->name("One");
$n2->name("Two");
$n3->name("Three");

# r1(n1, n2)
$r1->head($n2);
$r1->tail($n1);

# r2(n2, n3)
$r2->head($n3);
$r2->tail($n2);

# r3(n1, n3)
$r3->head($n3);
$r3->tail($n1);

# three new relationships
my $r4 = CCO::Core::Relationship->new;
my $r5 = CCO::Core::Relationship->new;
my $r6 = CCO::Core::Relationship->new;

$r4->id("CCO:R0000004");
$r5->id("CCO:R0000005");
$r6->id("CCO:R0000006");

$r4->type("r4");
$r5->type("r5");
$r6->type("r6");

$r4->link($n1, $n2);
$r5->link($n2, $n3);
$r6->link($n1, $n3);

ok($r4->head()->id() eq "CCO:P0000002");
ok($r5->head()->id() eq "CCO:P0000003");
ok($r6->head()->id() eq "CCO:P0000003");
ok($r4->tail()->id() eq "CCO:P0000001");
ok($r5->tail()->id() eq "CCO:P0000002");
ok($r6->tail()->id() eq "CCO:P0000001");

ok(1);
