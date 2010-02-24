# $Id: obo2tran.pl 2028 2008-04-17 08:18:16Z Erick Antezana $
#
# Module  : obo2tran.pl
# Purpose : Converts a file from OBO to RDF.
# Usage: /usr/bin/perl -w obo2tran.pl my_ontology.obo > my_ontology.rdf
# License : Copyright (c) 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>

=head1 NAME

obo2tran.pl - OBOF into RDF translator. The resulting file has (full) transitive closure. 

=head1 DESCRIPTION

OBOF into RDF translator. The resulting file has (full) transitive closure.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use Carp;
use strict;
use warnings;

use OBO::Parser::OBOParser;
use OBO::Util::Ontolome;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology  = $my_parser->work(shift);
my $ome       = OBO::Util::Ontolome->new();
my $go_transitive_closure = $ome->transitive_closure($ontology);

my $url = shift || "http://www.mydomain.com/ontology/rdf/";
$go_transitive_closure->export(\*STDOUT, "rdf", $url, 1, 2);