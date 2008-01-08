# $Id: obo2owl.pl 1847 2008-01-08 12:38:58Z erant $
#
# Module  : obo2owl.pl
# Purpose : Converts a file from OBO to OWL.
# Usage: /usr/bin/perl -w obo2owl.pl my_ontology.obo > my_ontology.owl
# License : Copyright (c) 2006, 2007, 2008 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#

use Carp;
use strict;
use warnings;

BEGIN {
push @INC, '..'; # Running without installing 'ONTO-PERL'
}

use OBO::Parser::OBOParser;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export(\*STDOUT, "owl");

=head1 NAME

    obo2owl.pl - OBO to OWL translator.

=head1 DESCRIPTION

This script transforms an OBO file (spec 1.2) into OWL (cf. oboinowl mapping).

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut