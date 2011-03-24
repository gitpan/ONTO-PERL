#!/usr/local/bin/perl
# $Id: get_root_terms.pl 2010-09-29 erick.antezana $
#
# Script  : get_root_terms.pl
#
# Purpose : Find all the root terms in a given ontology.
#
# Usage   : get_root_terms.pl my_ontology.obo > root_terms.txt
#
# License : Copyright (C) 2006-2011 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
################################################################################

use OBO::Parser::OBOParser;
			
my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift @ARGV);

my @my_terms = @{$ontology->get_root_terms()}; # get all the root terms

foreach my $t (@my_terms) {
	print $t->id(), "\t", $t->name(), "\n";
}

exit 0;

__END__

=head1 NAME

get_root_terms.pl - Find all the root terms in a given ontology.

=head1 DESCRIPTION

This script retrieves all the names of the root terms (and their IDs) 
in a given OBO-formatted ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut