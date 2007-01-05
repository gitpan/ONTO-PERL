# $Id: go2owl.pl 1 2006-07-12 15:37:55Z erant $
#
# Module  : go2owl.pl
# Purpose : Converts GO to OWL.
# Usage: /usr/bin/perl -w go2owl.pl gene_ontology.obo > gene_ontology.owl
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
################################################################################
use Carp;
use strict;
use warnings;
use CCO::Parser::OBOParser;
################################################################################
my $my_parser = CCO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export(\*STDOUT, "obo");