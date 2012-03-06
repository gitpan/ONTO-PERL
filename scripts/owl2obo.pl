#!/usr/local/bin/perl
# $Id: owl2obo.pl 2011-02-29 erick.antezana $
#
# script  : owl2obo.pl
#
# Purpose : Converts a file from OWL to OBO.
#
# Usage   : owl2obo.pl my_ontology.owl > my_ontology.obo
#
# License : Copyright (c) 2006-2012 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
###############################################################################

use Carp;
use strict;
use warnings;

use OBO::Parser::OWLParser;

my $my_parser = OBO::Parser::OWLParser->new();
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export('obo', \*STDOUT);

exit 0;

__END__

=head1 NAME

owl2obo.pl - OWL to OBO translator (oboinowl mapping).

=head1 DESCRIPTION

This script transforms an OWL file (cf. oboinowl mapping) into an OBO one (spec 1.4).
Use the obo2owl.pl to get the round-trip transformation.

This is not a universal translator from any OWL file into an OBO one.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2012 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut