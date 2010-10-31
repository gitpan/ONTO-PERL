#!/usr/local/bin/perl
# $Id: get_term_id_vs_term_namespace.pl 2010-09-29 Erick Antezana $
#
# Script  : get_term_id_vs_term_namespace.pl
#
# Purpose : Generates a flat file with two columns (TAB separated) with the 
#           get_term_id and term_namespace (e.g. biological process) from the elements 
#           of the given OBO ontology.
#
# Usage   : get_term_id_vs_term_namespace.pl my_ontology.obo > get_term_id_vs_term_namespace.txt
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
	print $term->id(), "\t", $term->namespace(), "\n" if (defined $term->namespace()); 
}

exit 0;

__END__

=head1 NAME

get_term_id_vs_term_namespace.pl - Gets the term IDs and its namespaces in a given ontology.

=head1 DESCRIPTION

Generates a flat file with two columns (TAB separated) with the 
get_term_id and term_namespace (e.g. biological process) from the elements 
of the given OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut