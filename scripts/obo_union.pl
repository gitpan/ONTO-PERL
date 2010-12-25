#!/usr/local/bin/perl
# $Id: obo_union.pl 2010-10-29 erick.antezana $
#
# Script  : obo_union.pl
# Purpose : Finds the union ontology from the given OBO-formatted ontologies.
#           Creates an ontology having the union of terms and relationships from the given ontologies.
#           Remark1  - The IDspace's are collected and added to the result ontology
#           Remark2  - the union is made on the basis of the IDs
#           Remark3  - the default namespace is taken from the last ontology argument
# Usage   : obo_union.pl my_first_ontology.obo my_second_ontology.obo > union.obo
# License : Copyright (c) 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
###############################################################################

use Carp;
use strict;
use warnings;

use OBO::Parser::OBOParser;
use OBO::Util::Ontolome;

my $my_parser  = OBO::Parser::OBOParser->new();
my @ontologies = ();
my $i = 0;
foreach my $input_file (@ARGV) {
	my $ontology      = $my_parser->work($input_file);
	$ontologies[$i++] = $ontology;
}

my $my_ontolome = OBO::Util::Ontolome->new();
my $union       = $my_ontolome->union(@ontologies);
$union->export(\*STDOUT, "obo");

exit 0;

__END__

=head1 NAME

obo_union.pl - Finds the union of the given OBO-formatted ontologies.

=head1 DESCRIPTION

Creates an ontology having the union of terms and relationships from the given ontologies.
Remark1  - The IDspace's are collected and added to the result ontology
Remark2  - the union is made on the basis of the IDs
Remark3  - the default namespace is taken from the last ontology argument

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut