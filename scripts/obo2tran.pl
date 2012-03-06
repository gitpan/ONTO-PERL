#!/usr/local/bin/perl
# $Id: obo2tran.pl 2011-09-29 erick.antezana $
#
# Script  : obo2tran.pl
#
# Purpose : Converts a file from OBO to an RDF version with transitive closure relationship (e.g. is_a, part_of).
#
# Usage   : obo2tran.pl my_ontology.obo [my_url] > my_ontology.rdf
#
# License : Copyright (c) 2006-2012 by Erick Antezana. All rights reserved.
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
use OBO::Util::Ontolome;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology  = $my_parser->work(shift);
my $ome       = OBO::Util::Ontolome->new();
my $go_transitive_closure = $ome->transitive_closure($ontology);

my $url = shift || "http://www.mydomain.com/ontology/rdf/";
$go_transitive_closure->export('rdf', \*STDOUT, \*STDERR, $url, 1, 2);

exit 0;

__END__

=head1 NAME

obo2tran.pl - OBOF into RDF translator. The resulting file has (full) transitive closures over 'is_a' and 'part_of'. 

=head1 DESCRIPTION

OBOF into RDF translator. The resulting file has (full) transitive closures ('is_a' and 'part_of').

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2012 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut