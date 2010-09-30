#!/usr/local/bin/perl
# $Id: get_terms.pl 2010-09-29 Erick Antezana $
#
# Script  : get_terms.pl
#
# Purpose : Find all the terms in a given ontology.
#
# Usage   : get_terms.pl my_ontology.obo > terms.txt
#
# License : Copyright (c) 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
################################################################################

use OBO::Parser::OBOParser;
			
my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift @ARGV);

my @my_terms = @{$ontology->get_terms()}; # get all the terms

foreach my $t (@my_terms) {
	print $t->id(), "\t", $t->name(), "\n";
}

exit 0;

__END__

=head1 NAME

get_terms.pl - Find all the terms in a given ontology.

=head1 DESCRIPTION

This script retrieves all the names of the terms (and their IDs) 
in a given OBO-formatted ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut