# $Id: get_ancestor_terms.pl 1893 2008-02-14 14:23:26Z erant $
#
# Script  : get_ancestor_terms.pl
# Purpose : Collects the ancestor terms from a given term in the given OBO ontology
# Usage   : /usr/bin/perl -w get_ancestor_terms.pl my_ontology.obo term_id > ancestors.txt
# License : Copyright (c) 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>

=head1 NAME

get_ancestor_terms.pl - Collects the ancestor terms (list of IDs) from a given term (existing ID) in the given OBO ontology.

=head1 DESCRIPTION

Collects the ancestor terms from a given term in the given OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

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

my $term_id = shift(@ARGV);

foreach my $term (@{$ontology->get_ancestor_terms($ontology->get_term_by_id($term_id))}) {
	print $term->id();
	print "\t", $term->name() if (defined $term->name());
	print "\n";
}