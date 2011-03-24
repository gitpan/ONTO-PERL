#!/usr/local/bin/perl
# $Id: get_terms_by_name.pl 2010-09-29 erick.antezana $
#
# Script  : get_terms_by_name.pl
#
# Purpose : Find all the terms in a given ontology that have a given string in their names.
#
# Usage   : get_terms_by_name.pl my_ontology.obo name_string > ids_and_terms.txt
#
# License : Copyright (C) 2006-2011 by Erick Antezana. All rights reserved.
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

my $my_terms  = $ontology->get_terms_by_name($name);
if ($my_terms) {
	my @terms_arr = $my_terms->get_set();
	foreach my $t (sort {$a->id() cmp $b->id()} @terms_arr) {
		print $t->id(), "\t", $t->name(), "\n";
	}
}
exit 0;

__END__

=head1 NAME

get_terms_by_name.pl - Find all the terms in a given ontology that have a given string in their names.

=head1 USAGE

get_terms_by_name.pl my_ontology.obo name_string > ids_and_terms.txt

=head1 DESCRIPTION

This script retrieves all the terms (and their IDs) in an OBO-formatted ontology that 
match the given string (name search). 

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut