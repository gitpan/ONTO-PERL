#!/usr/local/bin/perl
# $Id: obo2cco.pl 2028 2010-04-17 08:18:16Z Erick Antezana $
#
# Script  : obo2cco.pl
#
# Purpose : Generates an OBO ontology that can be integrated in the Cell
#           Cycle Ontology (CCO). The terms from the input ontology will
#           be given a CCO-like ID. The original IDs will be added as
#           cross references. The subnamespace by default is 'Z'. It is 
#           possible to specify the root term from the subontology we are
#           interested in (from input_file.obo).
#
# Usage:
#           obo2cco.pl input_file.obo cco_z.ids Z MI:0190 > output_file.obo
#
# License : Copyright (c) 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
##############################################################################

use strict;
use Carp;

use OBO::Parser::OBOParser;
use OBO::CCO::CCO_ID_Term_Map;

##############################################################################

my $my_parser = OBO::Parser::OBOParser->new();

my $onto = $my_parser->work(shift @ARGV);                      # input file
my $cco_id_map = OBO::CCO::CCO_ID_Term_Map->new(shift @ARGV);  # IDs file
my $sns = shift @ARGV || 'Z';                                  # subnamespace
my $sub_ontology_root_id = shift @ARGV;                        # root term e.g. MI:0190

if ($sub_ontology_root_id) {
	my $term = $onto->get_term_by_id($sub_ontology_root_id);
	$onto = $onto->get_subontology_from($term);
}

my $ns = $onto->idspace_as_string("CCO", "http://www.cellcycle.org/ontology/CCO");
$onto->default_namespace("cellcycle_ontology");
$onto->remarks("A Cell-Cycle Sub-Ontology");

foreach my $entry (sort {$a->id() cmp $b->id()} @{$onto->get_terms()}){
	my $current_id = $entry->id();
	my $entry_name = $entry->name();

	my $cco_id = $cco_id_map->get_id_by_term($entry_name);
	# Has an ID been already associated to this term (repeated entry)?
	$cco_id = $cco_id_map->get_new_id($ns->local_idspace(), $sns, $entry_name) if (!defined $cco_id);

	$onto->set_term_id($entry, $cco_id);
	# xref's
	my $xref = OBO::Core::Dbxref->new();
	$xref->name($current_id);
	my $xref_set = $onto->get_term_by_id($entry->id())->xref_set();
	$xref_set->add($xref);
	# add the alt_id's as xref's
	foreach my $alt_id ($entry->alt_id()->get_set()){
		my $xref_alt_id = OBO::Core::Dbxref->new();
		$xref_alt_id->name($alt_id);
		$xref_set->add($xref_alt_id);
	}
	$entry->alt_id()->clear() if (defined $entry->alt_id()); # erase the alt_id(s) from this 'entry'
}
$cco_id_map->write_map(); 
$onto->export(\*STDOUT, 'obo');
select((select(STDOUT), $|=1)[0]);

exit 0;

__END__

=head1 NAME

obo2cco.pl - Converts an ontology into another one which could be integrated into CCO.

=head1 DESCRIPTION

Generates an OBO ontology that can be integrated in the Cell
Cycle Ontology (CCO). The terms from the input ontology will
be given a CCO-like ID. The original IDs will be added as
cross references. The subnamespace by default is 'Z'. It is 
possible to specify the root term from the subontology we are
interested in (from input_file.obo).

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut