# $Id: go2owl.pl 1380 2007-08-06 16:19:56Z erant $
#
# Module  : go2owl.pl
# Purpose : Converts GO to OWL.
# Usage: /usr/bin/perl -w go2owl.pl gene_ontology.obo > gene_ontology.owl
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
################################################################################
use Carp;
use strict;
use warnings;
use OBO::Parser::OBOParser;
################################################################################
my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export(\*STDOUT, "owl");

=head1 NAME

    go2owl.pl - Gene Ontology (in OBO) to OWL translator.

=head1 DESCRIPTION

This script transforms the OBO version of GO into OWL.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut