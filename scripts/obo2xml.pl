# $Id: obo2xml.pl 1380 2007-08-06 16:19:56Z erant $
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
use OBO::Parser::OBOParser;
################################################################################
my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export(\*STDOUT, "xml");