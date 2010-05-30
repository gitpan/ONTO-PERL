#!/usr/local/bin/perl
# $Id: term_id_vs_term_def.pl 1893 2010-02-14 14:23:26Z erant $
#
# Script  : term_id_vs_term_def.pl
#
# Purpose : Generates a flat file with two columns (TAB separated) with the 
#           term_id and term_definition from the elements of the given OBO ontology.
#
# Usage   : term_id_vs_term_def.pl my_ontology.obo > term_id_vs_term_def.txt
#
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
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

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));

foreach my $term (@{$ontology->get_terms()}) {
	print $term->id(), "\t", $term->def()->text(), "\n" if (defined $term->id() && $term->def()->text()); 
}

exit 0;

__END__

=head1 NAME

term_id_vs_term_def.pl - Gets the term IDs and term defintions of a given ontology.

=head1 DESCRIPTION

Generates a flat file with two columns (TAB separated) with the 
term_id and term_definition from the elements of the given OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut