# $Id: term_id_vs_term_def.pl 1893 2008-02-14 14:23:26Z erant $
#
# Script  : term_id_vs_term_def.pl
# Purpose : Generates a flat file with two columns (TAB separated) with the 
#           term_id and term_definition from the elements of the given OBO ontology.
# Usage   : /usr/bin/perl -w term_id_vs_term_def.pl my_ontology.obo > term_id_vs_term_def.txt
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
################################################################################
use Carp;
use strict;
use warnings;

use OBO::Parser::OBOParser;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));

foreach my $term (@{$ontology->get_terms()}) {
	print $term->id(), "\t", $term->def()->text(), "\n" if (defined $term->id() && $term->def()->text()); 
}
