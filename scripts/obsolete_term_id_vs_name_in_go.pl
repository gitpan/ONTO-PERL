# $Id: obsolete_term_id_vs_name_in_go.pl 1893 2008-02-14 14:23:26Z erant $
#
# Script  : obsolete_term_id_vs_name_in_go.pl
# Purpose : Collects the obsolete terms from within an OBO ontology.
# Usage: /usr/bin/perl -w obsolete_term_id_vs_name.pl gene_ontology.obo
# License : Copyright (c) 2007, 2008 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana@gmail.com>
#
################################################################################

=head1 NAME

obsolete_term_id_vs_name_in_go.pl - Obsolete terms vs their names.

=head1 DESCRIPTION

Collects the obsolete terms from within an OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use Carp;
use strict;
use warnings;

BEGIN {
push @INC, '..';
}
use OBO::Parser::OBOParser;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));

foreach my $term (@{$ontology->get_terms()}) {
	print $term->id(), "\t", $term->name(), "\n" if (defined $term->id() && $term->def()->text() && $term->is_obsolete());
}