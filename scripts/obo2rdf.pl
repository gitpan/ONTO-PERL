#!/usr/bin/env perl
# $Id: obo2rdf.pl Copyright (c) 2013-2013-09-02 erick.antezana $
#
# Script  : obo2rdf.pl
# Purpose : Converts a file from OBO to RDF.
# Usage   : obo2rdf.pl my_ontology.obo "http://www.mydomain.com/ontology/rdf/" SSB > my_ontology.rdf
# License : Copyright (c) 2006-2014 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
##############################################################################

use Carp;
use strict;
use warnings;

use OBO::Parser::OBOParser;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology  = $my_parser->work(shift);
my $url       = shift;
my $namespace = shift;

$ontology->export('rdf', \*STDOUT, \*STDERR, $url, $namespace);

exit 0;

__END__

=head1 NAME

obo2rdf.pl - OBO to RDF translator.

=head1 DESCRIPTION

This script transforms an OBO file into RDF.

Usage: 

   obo2rdf.pl INPUT.obo URL NAMESPACE > OUTPUT.rdf

Sample usage: 

   obo2rdf.pl my_ontology.obo "http://www.mydomain.com/ontology/rdf/" SSB > my_ontology.rdf

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2014 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
