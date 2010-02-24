# $Id: goa2rdf.pl 1 2008-04-17 08:18:16Z Erick Antezana $
#
# Script  : goa2rdf.pl
#
# Purpose : Generates a simple RDF graph from a given GOA file.
#
# Usage:
#           perl goa2rdf.pl input_file.goa  > output_file.rdf
#
# License : Copyright (c) 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
##############################################################################

=head1 NAME

goa2rdf.pl - Generates a simple RDF graph from a given GOA file.

=head1 DESCRIPTION

Generates a simple RDF graph from a given GOA file.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008, 2009, 2010 by Erick Antezana

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use Carp;
use strict;
use warnings;

use OBO::CCO::GoaToRDF;

my $input_file = shift(@ARGV);
my $goa2rdf = OBO::CCO::GoaToRDF->new();

$goa2rdf->work(\*STDOUT, $input_file);






