#!/usr/local/bin/perl
# $Id: get_child_terms.pl 2010-09-29 erick.antezana $
#
# Script  : get_child_terms.pl
#
# Purpose : Collects the child terms (not all the descendents) of a given term in the given OBO ontology
#
# Usage   : get_child_terms.pl my_ontology.obo term_id > child_terms.txt
#
# License : Copyright (C) 2006-2011 by Erick Antezana. All rights reserved.
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

foreach my $term (@{$ontology->get_child_terms($ontology->get_term_by_id($term_id))}) {
	print $term->id();
	print "\t", $term->name() if (defined $term->name());
	print "\n";
}

exit 0;

__END__

=head1 NAME

get_child_terms.pl - Collects the child terms (list of term IDs and their names) from a given term (existing ID) in the given OBO ontology.

=head1 DESCRIPTION

Collects the child terms of a given term in the given OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
