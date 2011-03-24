#!/usr/local/bin/perl
# $Id: get_relationship_types.pl 2010-09-29 erick.antezana $
#
# Script  : get_relationship_types.pl
#
# Purpose : Find all the relationships in a given ontology.
#
# Usage   : get_relationships_type.pl my_ontology.obo > terms.txt
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

my @my_rels= @{$ontology->get_relationship_types()}; # get all the relationships types

foreach my $r (@my_rels) {
	print $r->name(), "\n";
}

exit 0;

__END__

=head1 NAME

get_relationship_types.pl - Find all the relationship types in a given ontology.

=head1 DESCRIPTION

This script retrieves all the relationship types in a given ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
