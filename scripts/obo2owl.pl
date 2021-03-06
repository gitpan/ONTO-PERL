#!/usr/bin/env perl
# $Id: obo2owl.pl 2011-02-29 erick.antezana $
#
# Script  : obo2owl.pl
#
# Purpose : Converts a file from OBO to OWL.
#
# Usage   : obo2owl.pl my_ontology.obo > my_ontology.owl http://www.myurl.org http://www.myurl.org/oboInOwl#
#
# License : Copyright (c) 2006-2014 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
###############################################################################

use Carp;
use strict;
use warnings;

use OBO::Parser::OBOParser;

my $my_parser   = OBO::Parser::OBOParser->new();
my $ontology    = $my_parser->work(shift);
my $url         = shift;
my $oboinowlurl = shift;
$ontology->export('owl', \*STDOUT, \*STDERR, $url, $oboinowlurl);

exit 0;

__END__

=head1 NAME

obo2owl.pl - OBO to OWL translator.

=head1 DESCRIPTION

This script transforms an OBO file (spec 1.2) into OWL (cf. oboinowl mapping).
Use the owl2obo.pl to get the round-trip transformation.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2014 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut