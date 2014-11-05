#!/usr/bin/env perl
# $Id: obo_intersection.pl Copyright (c) 2013-10-29 erick.antezana $
#
# Script  : obo_intersection.pl
# Purpose : Finds the intersection ontology from my_first_ontology.obo and my_second_ontology.obo.
#           All the common terms by ID are added to the resulting ontology. This method provides 
#           a way of comparing two ontologies. The resulting ontology gives hints about the missing 
#           and identical terms (comparison done by term ID). A closer analysis should be done to 
#           identify the differences.
# Usage   : obo_intersection.pl my_first_ontology.obo my_second_ontology.obo > intersection.obo
# License : Copyright (c) 2006-2014 by Erick Antezana. All rights reserved.
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

my $my_parser   = OBO::Parser::OBOParser->new();
my $onto1       = $my_parser->work(shift @ARGV);
my $onto2       = $my_parser->work(shift @ARGV);
my $my_ontolome = OBO::Util::Ontolome->new();
my $union       = $my_ontolome->intersection($onto1, $onto2);
$union->export('obo', \*STDOUT);

exit 0;

__END__

=head1 NAME

obo_intersection.pl - Finds the intersection of two OBO-formatted ontologies.

=head1 DESCRIPTION

Finds the intersection ontology from my_first_ontology.obo and my_second_ontology.obo.
All the common terms by ID are added to the resulting ontology. This method provides 
a way of comparing two ontologies. The resulting ontology gives hints about the missing 
and identical terms (comparison done by term ID). A closer analysis should be done to 
identify the differences.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2014 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut