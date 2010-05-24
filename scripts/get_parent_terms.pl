#!/usr/local/bin/perl
# $Id: get_parent_terms.pl 1 2010-03-27 14:23:26Z erant $
#
# Script  : get_parent_terms.pl
#
# Purpose : Collects the parent terms (not all the ancestors) of a given term in the given OBO ontology
#
# Usage   : get_parent_terms.pl my_ontology.obo term_id > parent_terms.txt
#
# License : Copyright (c) 2010 by Erick Antezana. All rights reserved.
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

my $term_id = shift(@ARGV);

foreach my $term (@{$ontology->get_parent_terms($ontology->get_term_by_id($term_id))}) {
	print $term->id();
	print "\t", $term->name() if (defined $term->name());
	print "\n";
}

exit 0;

=head1 NAME

get_parent_terms.pl - Collects the parent terms (list of term IDs and their names) from a given term (existing ID) in the given OBO ontology.

=head1 DESCRIPTION

Collects the parent terms of a given term in the given OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut