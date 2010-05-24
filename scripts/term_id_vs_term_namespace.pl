#!/usr/local/bin/perl
# $Id: term_id_vs_term_namespace.pl 1893 2010-02-14 14:23:26Z erant $
#
# Script  : term_id_vs_term_namespace.pl
#
# Purpose : Generates a flat file with two columns (TAB separated) with the 
#           term_id and term_namespace (e.g. biological process) from the elements 
#           of the given OBO ontology.
#
# Usage   : term_id_vs_term_namespace.pl my_ontology.obo > term_id_vs_term_namespace.txt
#
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
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
	print $term->id(), "\t", $term->namespace(), "\n" if (defined $term->namespace()); 
}

exit 0;
