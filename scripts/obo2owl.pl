# $Id: obo2owl.pl 1 2006-07-12 15:37:55Z erant $
#
# Module  : obo2owl.pl
# Purpose : Converts a file from OBO to OWL.
# Usage: /usr/bin/perl -w obo2owl.pl $pre_cco_obo_path > $pre_cco_owl_path
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
################################################################################
use Carp;
use strict;
use warnings;
################################################################################
my $my_parser = CCO::Parser::OBOParser->new;
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export(\*STDOUT, "owl");