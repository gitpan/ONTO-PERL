# $Id: term_id_vs_term_def.pl 1381 2007-08-06 16:20:15Z erant $
#
# Module  : term_id_vs_def_in_go.pl
# Purpose : Generates a flat file with two columns (TAB separated) with the 
#			term_id and term_name from the elements of the given OBO ontology.
# Usage   : /usr/bin/perl -w term_id_vs_term_name.pl my_ontology.obo > term_id_vs_term_name.txt
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
################################################################################
use Carp;
use strict;
use warnings;

BEGIN {
push @INC, '..';
}
use OBO::Parser::OBOParser;
################################################################################
my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));

foreach my $term (@{$ontology->get_terms()}) {
	print $term->id(), "\t", $term->def()->text(), "\n" if (defined $term->id() && $term->def()->text()); 
}