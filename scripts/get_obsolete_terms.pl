#!/usr/local/bin/perl
# $Id: get_obsolete_terms.pl 1 2010-03-27 14:23:26Z easr $
#
# Script  : get_obsolete_terms.pl
#
# Purpose : Find all the obsolete terms in a given ontology.
#
# Usage   : get_obsolete_terms.pl my_ontology.obo > obsolete_terms.txt
#
# License : Copyright (c) 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
###############################################################################

use OBO::Parser::OBOParser;
			
my $my_parser = OBO::Parser::OBOParser->new();
my $ontology  = $my_parser->work(shift @ARGV);
my $name      = shift @ARGV;

foreach my $term (@{$ontology->get_terms()}) {
	if ($term->is_obsolete()) {
		print $term->id(), "\t", $term->name(), "\n" if (defined $term->id() && $term->name());
	}
}

exit 0;

__END__

=head1 NAME

get_obsolete_terms.pl - Find all the obsolete terms in a given ontology.

=head1 USAGE

get_obsolete_terms.pl my_ontology.obo > obsolete_terms.txt

=head1 DESCRIPTION

This script retrieves all the obsolete terms (and their IDs) in a given ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut