#!/usr/local/bin/perl
# $Id: get_obsolete_term_id_vs_def_in_go.pl 2010-09-29 erick.antezana $
#
# Script  : get_obsolete_term_id_vs_def_in_go.pl
#
# Purpose : Collects the obsolete GO terms: id vs. def.
#
# Usage   : get_obsolete_term_id_vs_def_in_go.pl gene_ontology.obo > get_obsolete_term_id_vs_def_in_go.out
#
# License : Copyright (c) 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
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

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));

foreach my $term (@{$ontology->get_terms()}) {
	print $term->id(), "\t", $term->def()->text(), "\n" if (defined $term->id() && $term->def()->text() && $term->is_obsolete());
}

exit 0;

__END__

=head1 NAME

get_obsolete_term_id_vs_def_in_go.pl - Obsolete terms vs their definitions.

=head1 DESCRIPTION

Collects the obsolete terms (term id vs. its definition) from within an OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut