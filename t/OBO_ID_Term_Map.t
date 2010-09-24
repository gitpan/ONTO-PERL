# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl CCO_ID_Term_Map.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 27;
}

#########################

use Data::Dumper;
use OBO::XO::OBO_ID_Term_Map;
use strict;

my $my_set = OBO::XO::OBO_ID_Term_Map->new("./t/data/obo_id_term.map");

#
# check the current entries:
#
ok($my_set->contains_key('GO:0000001'));
ok($my_set->contains_value('Q6NMC8_ARATH'));

ok($my_set->contains_key('GO:0000002'));
ok($my_set->contains_value('RK20renamed_ARATH'));

ok($my_set->contains_key('GO:0000003'));
ok($my_set->contains_value('Q6XJG8_ARATH'));

ok($my_set->contains_key('GO:0000004'));
ok($my_set->contains_value('Q84JF0_ARATH'));

ok($my_set->contains_key('GO:0000006'));
ok($my_set->contains_value('(S)-N-acetyl-1-phenylethylamine hydrolase protein'));

ok($my_set->contains_key('GO:0000007'));
ok($my_set->contains_value('(-)-endo-fenchol synthase protein'));

ok($my_set->contains_key('GO:0000008'));
ok($my_set->contains_value('[acetyl-CoA carboxylase] kinase protein'));

ok($my_set->contains_key('GO:0000009'));
ok($my_set->contains_value('(-)-menthol dehydrogenase protein'));


ok($my_set->size() == 8);

#
# put (new id, new name)
#
ok($my_set->put('GO:0000005', 'Q84JF1_ARATH'));
ok($my_set->contains_key('GO:0000005'));
ok($my_set->contains_value('Q84JF1_ARATH'));

ok($my_set->size() == 9);

#
# put (existing id, new name) <- update the value
#
ok($my_set->put('GO:0000005', 'Q84JF2_ARATH'));
ok($my_set->contains_value('Q84JF2_ARATH'));

ok($my_set->size() == 9);

#
# removing
#
$my_set->remove_by_key('GO:0000005');
ok(!$my_set->contains_key('GO:0000005'));
ok(!$my_set->contains_value('Q84JF2_ARATH'));
ok($my_set->size() == 8);
