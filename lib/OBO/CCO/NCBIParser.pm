# $Id: NCBIParser.pm 2113 2008-05-22 13:19:59Z Erick Antezana $
#
# Module  : NCBIParser.pm
# Purpose : Parse NCBI files: names and nodes
# License : Copyright (c) 2006, 2007, 2008 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package OBO::CCO::NCBIParser;

=head1 NAME

OBO::CCO::NCBIParser - A NCBI taxonomy to OBO translator.

=head1 DESCRIPTION

This parser converts chosen parts of the NCBI taxonomy-tree into an OBO file. 
Some taxa are given to the parser and the whole tree till the root is 
reconstructed in a given OBO ontology, using scientific names.

The dump files (nodes.dmp and names.dmp) should be obtained from: 

	ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

TODO: include ranks and disjoints only in correlating ranks.

=head1 AUTHOR

Mikel Egana Aranguren 

http://www.mikeleganaranguren.com

eganaarm@cs.man.ac.uk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use OBO::Parser::OBOParser;
use OBO::Core::Ontology;
use OBO::Core::Relationship;
use OBO::Core::RelationshipType;
use OBO::Core::Dbxref;
use OBO::Core::Term;

BEGIN {
push @INC, '..';
}
use OBO::CCO::CCO_ID_Term_Map;

use strict;
use warnings;
use Carp;

my %selected_nodes = (); # taxon id => parent id
my %selected_names = (); # taxon id => taxon name

sub new {
	my $class                   = shift;
	my $self                    = {}; 
	
	bless ($self, $class);
	return $self;
}

=head2 work

  Usage    - $NCBIParser->work()
  Returns  - the parsed OBO ontology
  Args     - old OBO file, new OBO file, cco ids file, nodes dump file, names dump file, taxon 1, taxon 2, ...
  Function - converts NCBI taxonomy into an OBO file
  
=cut


sub work {
	my $self = shift;

	# Get the arguments
	my $old_OBOfileName = shift;
	my $new_OBOfileName = shift;
	my $CCO_idsFileName = shift;
	my $NCBInodesFileName = shift;
	my $NCBInamesFileName = shift;
	my @allthetaxa = @_;

	# Create the hashes: 
	# %nodes=[child node id] - [parent node id] 
	# %names=[child node id] - [scientific name]
	# !!!TODO!!! %ranks=[child node id] - [rank]
	my %nodes = ();
	my %names = ();

	# Open and parse the nodes file (We want groups 1 and 2)
	open(NCBInodesFile, $NCBInodesFileName) || die("can't open file: $!");
	my @mynodelines =<NCBInodesFile>;
	foreach my $theline (@mynodelines){
		if ($theline =~ /(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|/){
			my $child = $1;
			my $parent = $2;
			$child =~ s/\s//g;
			$parent =~ s/\s//g;
			$nodes{$child} = $parent; 
		}
	}
	close(NCBInodesFile);

	# Open and parse names file (we want groups 1 and 2 only if group 4 is scientific name)
	open(NCBInamesFile, $NCBInamesFileName) || die("can't open file: $!");
	my @mynamelines = <NCBInamesFile>;
	foreach my $theline (@mynamelines){
		if ($theline =~ /(.+)\|(.+)\|(.+)\|(.+)\|/){
			my $childid = $1;
			my $childname = $2;
			my $nametype = $4;
			$childid =~ s/\s//g;
			$nametype =~ s/\s//g;
			if($nametype eq 'scientificname'){
				$childname =~ s/^\s+//;
				$childname =~ s/\s+$//;
				$names{$childid} = $childname;
			}
		}
	}
	close(NCBInamesFile);

	# Do the work: traverse both hashes and put the interesting taxa into the OBO ontology, with structure

	# Initialize the parser and load the OBO file
	my $my_parser = OBO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBOfileName);

	# Create new hashes for the only interesting terms
# 	my %selected_nodes=(); # taxon id=> parent id
# 	my %selected_names =(); # taxon id => taxon name

	# Get the interesting terms
	foreach my $thetaxon (@allthetaxa){
		&getParentsRecursively ($thetaxon,\%nodes,\%names,\%selected_nodes,\%selected_names);	
	}
	
	#
	# NCBI IDs vs. CCO IDs
	#
	my %ncbi_cco;

    # TODO find out automatically the file type: cco_x.ids , la 'x'
    my $cco_t_id_map = OBO::CCO::CCO_ID_Term_Map->new($CCO_idsFileName); # Set of [T]axa IDs
    
	# Put all the interesting term in the ontology without structure
	# if the term happens to be "root", add it as "organism"
	# For the rest of terms, add "organism" at the end of the name
	# so it is ontologically correct
	foreach my $el (keys %selected_nodes){
		my $selected_name = $selected_names{$el};

		my $OBO_taxon = OBO::Core::Term->new();
		
		if($selected_name eq "root"){
			$selected_name = "organism";
		} else {
			$selected_name .= " organism";
		}
		$OBO_taxon->name($selected_name);
		my $taxon_id = $cco_t_id_map->get_cco_id_by_term($selected_name);
		if (!defined $taxon_id) { # Does this term have an associated ID?
			$taxon_id = $cco_t_id_map->get_new_cco_id("CCO", "T", $selected_name);
		}
		
		$ncbi_cco{$el} = $taxon_id;
		$OBO_taxon->id($taxon_id);
		$OBO_taxon->xref_set_as_string("NCBI:".$el);
		
		my $biological_continuant = $ontology->get_term_by_id("CCO:U0000001");
		if (defined $biological_continuant && $OBO_taxon->name() eq "organism") { # If the ontology has the ULO and the term is 'organism'
			my $rel = OBO::Core::Relationship->new(); 
			$rel->type("is_a");
			$rel->OBO::Core::Relationship::link($OBO_taxon, $biological_continuant);
			$rel->id($OBO_taxon->id()."_is_a_".$biological_continuant->id());
			$ontology->add_relationship($rel); # add "organism is_a biological_continuant"
		}
		$ontology->add_term($OBO_taxon);
	}
	$cco_t_id_map->write_map();

	# Put the 'is_a' relationships to each term but not if the child is root (cyclic is_a)
	foreach my $el (keys %selected_nodes){
		my $OBO_taxon_term = $ontology->get_term_by_id($ncbi_cco{$el});
		croak "The term with id: '", $ncbi_cco{$el}, "' is not defined\n" if (!defined $OBO_taxon_term);
		my $OBO_taxon_parent = $ontology->get_term_by_id($ncbi_cco{$selected_nodes{$el}});
		croak "The parent term with id: '", $ncbi_cco{$selected_nodes{$el}}, "' is not defined\n" if (!defined $OBO_taxon_parent);
		if($el != 1){
			my $is_a_rel = OBO::Core::Relationship->new();
			$is_a_rel->type("is_a");
			$is_a_rel->link($OBO_taxon_term, $OBO_taxon_parent);
			$is_a_rel->id($OBO_taxon_term->id()."_is_a_".$OBO_taxon_parent->id());
			$ontology->add_relationship($is_a_rel); 
		}
	}

	# Write the new ontology to disk
	open (FH, ">".$new_OBOfileName) || die "Cannot write OBO file ", $!;
	$ontology->export(\*FH);
	close FH;
	return $ontology;
}

########################################################################
# Subroutines
########################################################################

sub getParentsRecursively (){
	my ($taxon, $nodes, $names, $selected_nodes, $selected_names) = @_;
	my $child_id = $taxon;
	my $parent_id = ${$nodes}{$taxon};
	my $child_name = ${$names}{$taxon};
	my $parent_name = ${$names}{$taxon};
	$selected_nodes{$child_id} = $parent_id;
	$selected_names{$child_id} = $child_name;
	&getParentsRecursively($parent_id, $nodes, $names, $selected_nodes, $selected_names) if($child_id !=1);
}

1;