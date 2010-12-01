#!/usr/local/bin/perl
# $Id: get_term_synonyms.pl 2010-09-29 Erick Antezana $
#
# Script  : get_term_synonyms.pl
#
# Purpose : Find all the synonyms of a given term name in an ontology.
#
# Usage   : get_term_synonyms.pl my_ontology.obo term_name > term_synonyms.txt
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

my $my_term  = $ontology->get_term_by_name($name);
if ($my_term) {
	my @synonyms = $my_term->synonym_set();
	foreach my $s (@synonyms) {
		print $s->def()->text(), "\n";
	}
}
exit 0;

__END__

=head1 NAME

get_term_synonyms.pl - Find all the synonyms of a given term name in an ontology.

=head1 USAGE

get_term_synonyms.pl my_ontology.obo term_name > term_synonyms.txt

=head1 DESCRIPTION

This script retrieves all the synonyms of a term name (exact name match) in an OBO-formatted ontology. 

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut