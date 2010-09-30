#!/usr/local/bin/perl
# $Id: get_subontology_from.pl 2010-09-29 Erick Antezana $
#
# Script  : get_subontology_from.pl
#
# Purpose : Given an OBO-formatted ontology (such as the Gene Ontology), this script 
#           extracts a subontology (in OBO format) having as root node the provided term ID.
#           This script can easily be adapted to get such subontology (branch) taking into
#           account the name (or synonym) of a given term.
#
# Usage   : get_subontology_from.pl input_ontology.obo term_id > sub_ontology.obo
#
# License : Copyright (c) 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
###############################################################################

use strict;
use warnings;
use Carp;
use OBO::Parser::OBOParser;

my $my_parser     = OBO::Parser::OBOParser->new();
my $my_large_onto = $my_parser->work(shift @ARGV);

my $new_root      = $my_large_onto->get_term_by_id(shift @ARGV);
die "The term, you have asked as being the new root, does not exist!\n" if (!$new_root);
my $sub_ontology  = $my_large_onto->get_subontology_from($new_root);
$sub_ontology->export(\*STDOUT, "obo");

exit 0;

__END__

=head1 NAME

get_subontology_from.pl - Extracts a subontology (in OBO format) of a given ontology having as root the given term ID.

=head1 USAGE

get_subontology_from.pl input_ontology.obo term_id > sub_ontology.obo

=head1 DESCRIPTION

Given an OBO-formatted ontology (such as the Gene Ontology), this script 
extracts a subontology (in OBO format) having as root node the provided term ID.
This script can easily be adapted to get such subontology (branch) taking into
account the name (or synonym) of a given term.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut