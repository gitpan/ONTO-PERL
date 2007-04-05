# $Id: obo2xml.pl 1 2006-07-12 15:37:55Z erant $
#
# Module  : obo2xml.pl
# Purpose : Converts a file from OBO to XML.
# Usage: /usr/bin/perl -w obo2xml.pl $pre_cco_obo_path > $pre_cco_xml_path
# License : Copyright (c) 2006, 2007 Erick Antezana. All rights reserved.
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
$ontology->export(\*STDOUT, "xml");