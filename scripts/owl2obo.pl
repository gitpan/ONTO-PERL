# $Id: owl2obo.pl 1847 2008-01-08 12:38:58Z erant $
#
# Module  : owl2obo.pl
# Purpose : Converts a file from OWL to OBO.
# Usage: /usr/bin/perl -w owl2obo.pl my_ontology.owl > my_ontology.obo
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

use OBO::Parser::OWLParser;

my $my_parser = OBO::Parser::OWLParser->new();
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export(\*STDOUT, "obo");

=head1 NAME

    owl2obo.pl - OWL to OBO translator (oboinowl mapping).

=head1 DESCRIPTION

This script transforms an OWL file (cf. oboinowl mapping) into an OBO one (spec 1.2).

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut