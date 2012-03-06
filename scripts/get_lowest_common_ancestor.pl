#!/usr/local/bin/perl
# $Id: get_lowest_common_ancestor.pl 2011-10-16 erick.antezana $
#
# Script  : get_lowest_common_ancestor.pl
#
# Purpose : Gets the lowest common ancestor (LCA) of two terms in a given OBO ontology.
#
# Usage   : get_lowest_common_ancestor.pl my_ontology.obo term_id1 term_id2 > lca.txt
#
# License : Copyright (c) 2006-2012 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same relationships as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
################################################################################

use Carp;
use strict;
use warnings;

use OBO::Parser::OBOParser;

###############################################################################

my $my_parser    = OBO::Parser::OBOParser->new();
my $my_ncbi_onto = $my_parser->work(shift);

my $r = 'is_a';

my $root_id   = @{$my_ncbi_onto->get_root_terms()}[0]; # only one root term
my $taxon1_id = shift;
my $taxon2_id = shift;

my $stop = OBO::Util::Set->new();
$stop->add($root_id);

my @p1 = $my_ncbi_onto->get_paths_term_terms_same_rel($taxon1_id, $stop, $r);
my @p2 = $my_ncbi_onto->get_paths_term_terms_same_rel($taxon2_id, $stop, $r);

#
# alignment
#
my @pp1 = reverse @{$p1[0]};
my @pp2 = reverse @{$p2[0]};
my $i   = 0;
my $lca;
while (1) {
	my $a1 = $pp1[$i]->head()->id();
	my $a2 = $pp2[$i]->head()->id();
	if ($a1 eq $a2) {
		$lca = $a1;
	} else {
		last;
	}
	$i++;
}

print "LCA of '$taxon1_id' and '$taxon2_id' is: ", $lca;

exit 0;

__END__

=head1 NAME

get_lowest_common_ancestor.pl - the lowest common ancestor (LCA) of two terms in a given OBO ontology.

=head1 DESCRIPTION

Gets the lowest common ancestor (LCA) of two terms in a given OBO-formatted ontology.
This script is generally used with taxonomies (e.g. NCBI taxonomy). This version only 
gets the LCA computed through the 'is_a' relationship type. Also, it assumes that there
is only one root term in the ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2012 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut