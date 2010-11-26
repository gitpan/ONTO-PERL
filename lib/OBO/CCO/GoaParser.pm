# $Id: GoaParser.pm 2159 2010-11-29 Erick Antezana $
#
# Module  : GoaParser.pm
# Purpose : Parse GOA files
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : erick.antezana@gmail.com
#

package OBO::CCO::GoaParser;

=head1 NAME

OBO::CCO::GoaParser - A GOA associations to OBO translator.

=head1 DESCRIPTION

Includes methods for adding information from GOA association files to ontologies
GOA associations files can be obtained from http://www.ebi.ac.uk/GOA/proteomes.html

The method 'parse' parses the GOA association file and returns a OBO::CCO::GoaAssociationSet object

The method 'work' incorporates OBJ_SRC, OBJ_ID, OBJ_SYMB, SYNONYM, DESCRIPTION into the input ontology, writes the ontology into an OBO file, writes map files.
This method assumes: 
1. the ontology contains already the term 'protein'
2. the ontology already contains all and only the necessary GO terms. 
3. the ontology already contains the relationship types 'is_a', 'participates_in', 'has_participant'
4. the input GOA association file contains entries for one species only and for GO terms present in the input ontology only

=head1 AUTHOR

Vladimir Mironov E<lt>vladimir.mironov@bio.ntnu.noE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use OBO::Parser::OBOParser;
use OBO::Core::Relationship;
use OBO::Core::Dbxref;
use OBO::Core::Term;
use OBO::CCO::GoaAssociation;
use OBO::CCO::CCO_ID_Term_Map;
use OBO::Util::DbxrefSet;
use OBO::CCO::GoaAssociationSet;

use strict;
use warnings;
use Carp;

sub new {
	my $class   = shift;
	my $self    = {}; 
	
	bless ($self, $class);
	return $self;
}

=head2 parse

  Usage    - $GoaParser->parse(GOA_association_file)
  Returns  - An OBO::CCO::GoaAssociationSet object
  Args     - GOA associations file
  Function - converts a GOA associations file into a OBO::CCO::GoaAssociationSet object
  
=cut

sub parse {
	my $self = shift;

	# Get the argument
	my $goaAssocFileName = shift;	
	
	my $goaAssocSet = OBO::CCO::GoaAssociationSet->new();
	
	# Open the assoc file
	open(FH, $goaAssocFileName) || die("Cannot open file '$goaAssocFileName': $!");
	
	# Populate the OBO::CCO::GoaAssociationSet class with objects
	while(<FH>){
		chomp;
		$_ =~ /^\w/ ? my $goaAssoc = OBO::CCO::GoaAssociation->new() : next;	
		@_ = split(/\t/);
		foreach(@_){
			$_ =~ s/^\s+//; 
			$_ =~ s/\s+$//;
		}
		$goaAssoc->assc_id($.);
		$goaAssoc->obj_src($_[0]);
        $goaAssoc->obj_id($_[1]);
        $goaAssoc->obj_symb($_[2]);
        $goaAssoc->qualifier($_[3]);
        $goaAssoc->go_id($_[4]); 
        $goaAssoc->refer($_[5]);
        $goaAssoc->evid_code($_[6]);
        $goaAssoc->sup_ref($_[7]);
        $goaAssoc->aspect($_[8]);
        $goaAssoc->description($_[9]);
        $goaAssoc->synonym($_[10]);
        $goaAssoc->type($_[11]);
        $goaAssoc->taxon($_[12]);
        $goaAssoc->date($_[13]);
        $goaAssoc->annot_src($_[14]);
		
		$goaAssocSet->add_unique($goaAssoc);
	}
	close FH;
	return $goaAssocSet;
}

=head2 work

  Usage    - $GoaParser->work($ref_file_names)
  Returns  - updated OBO::Core::Ontology object 
  Args     - reference to a list of filenames(input OBO file, output OBO file, GOA associations file, CCO_id/Uniprot_id map file one taxon only, CCO_id/Uniprot_id map file all taxa)
  Function - parses a GOA associations file, adds relevant information to the input  ontology, writes OBO and map files 
  
=cut

sub work {
	my $self = shift;

	# Get the arguments
	my ($old_OBO_file, $new_OBO_file, $goa_assoc_file, $short_map_file, $long_map_file, $up_map_file) = @{shift @_}; 
	
	# Initialize the OBO parser, load the OBO file, check the assumptions
	my $my_parser = OBO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBO_file);
	
	# rels
	my $is_a            = 'is_a';
	
	my $participates_in = 'participates_in';
	my $has_participant = 'has_participant';
	
	my $located_in      = 'located_in';
	my $location_of     = 'location_of';
	my $has_function	= 'has_function';
	
	# rel existency check
	foreach (($is_a, $participates_in, $has_participant, $located_in, $location_of, $has_function)){
		die "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$_});
	}
	
	#my $taxon = $ontology->get_term_by_name($taxon_name) || die "the term $taxon_name is not defined", $!;
	my $name_of_parent_of_the_new_proteins = 'core cell cycle protein';
	my $onto_protein = $ontology->get_term_by_name($name_of_parent_of_the_new_proteins) || confess "The term '", $name_of_parent_of_the_new_proteins, "' is not defined", $!;
	
	# Initialize CCO_ID_Map objects
	my $short_map = OBO::CCO::CCO_ID_Term_Map->new($short_map_file);
	my $long_map  = OBO::CCO::CCO_ID_Term_Map->new($long_map_file); # Set of Protein IDs	
	
	# Read UniProt map file (keys - accession numbers, values - protein IDs)
	open my $fh, '<', $up_map_file
	  or croak "Can't open file '$up_map_file' : $!";
	my %up_map;
	while (<$fh>) {
		my ( $acc, $name ) = split( /\t/, $_ );
		chomp $acc;
		chomp $name;
		$up_map{$acc} = $name;
	}
	close $fh;

	# parse the GOA associations file
	my $goa_parser = OBO::CCO::GoaParser->new();
	my $goa_assoc_set = $goa_parser->parse($goa_assoc_file); 
	foreach my $goaAssoc (@{$goa_assoc_set->{SET}}){
		my $db           = $goaAssoc->obj_src();
		my $acc          = $goaAssoc->obj_id();
		my $protein_name = $goaAssoc->obj_symb();
		my $up_prot_name = $up_map{$acc}; 
		my $protein      = $ontology->get_term_by_xref($db, $acc);
		
		# update protein name if necessary
		my $depric_prot_name;
		if ((defined $up_prot_name) && ($protein_name ne $up_prot_name)) {
			$depric_prot_name = $protein_name;
			$protein_name = $up_prot_name ;
			if (defined $depric_prot_name) {
				my $cco_id = $short_map->get_id_by_term($depric_prot_name);
				if (defined $cco_id) {
					$short_map->put( $cco_id, $up_prot_name );
					$long_map->put( $cco_id, $up_prot_name  );
				} else {
					#TODO warn "Term id not defined for '$depric_prot_name'";
				}
			} else {
				warn "Term name not defined...";
			}			
		}
#		defined $up_prot_name ? $protein_name = $up_prot_name : warn "the accession $acc not found in the UniProt map file $up_map_file\n";
		
		# create a new protein object
		if (!defined $protein) {
			$protein = OBO::Core::Term->new(); 
			$protein->name($protein_name); 
			$protein->xref_set_as_string("[$db:$acc]"); # cross-reference to UniProt

			# assign a CCO protein id
			if ($short_map->contains_value($protein_name)){
				$protein->id($short_map->get_id_by_term($protein_name));
			} else {
				my $new_protein_id = $long_map->get_new_id("CCO", "B", $protein_name);
				$protein->id($new_protein_id);
				$short_map->put($new_protein_id, $protein_name); # TRICK to add the IDs in the other file
			}
			
			$ontology->add_term($protein);
			
			# add: 'new protein' is_a 'protein'
			confess "The following protein is missing: '", $name_of_parent_of_the_new_proteins, "'" if (!defined $onto_protein);
			$ontology->create_rel($protein, $is_a, $onto_protein);
		}
		
		# add relatioships with GO terms 
		my $id = $goaAssoc->go_id();
		my $aspect = $goaAssoc->aspect();
		my $prefix = 'CCO:'.$aspect; 
		$id =~ s/GO:/$prefix/;
		my $cco_go_term = $ontology->get_term_by_id($id);
		
		if (!defined $cco_go_term){
			warn "The following term is missing: '", $id, "' in the ontology.";
			next;
		}
		
		if ($aspect eq 'P') {
			$ontology->create_rel($protein,     $participates_in, $cco_go_term);
			$ontology->create_rel($cco_go_term, $has_participant, $protein);  # inverse of 'participates_in'			
		} elsif ($aspect eq 'C') {
			$ontology->create_rel($protein,     $located_in,  $cco_go_term);
			$ontology->create_rel($cco_go_term, $location_of, $protein);      # inverse of 'located_in'
		} elsif ($aspect eq 'F') {
			$ontology->create_rel($protein,     $has_function, $cco_go_term);
		}
	}
	
	# Write the new ontology and map to disk
	open (FH, ">".$new_OBO_file) || die "Cannot write OBO file: ", $!;
	$ontology->export(\*FH);
	close FH;
	$short_map -> write_map(); 
	$long_map -> write_map(); 
	return $ontology;
}

=head2 work

 Usage    - $GoaParser->add_goa_assocs($ref_file_names)
 Returns  - updated OBO::Core::Ontology object
 Args     - reference to a list of filenames(input OBO file, output OBO file, GOA associations file, UniProt map file 'AC'\t'ID', 'go_id'\t'cco_id' map file)
 Function - parses a GOA associations file, adds new associations to the input  ontology, writes OBO

=cut

sub add_go_assocs {
   my $self = shift;
   # Get the arguments
   my (
   $in_obo_file,
   $out_obo_file,
   $goa_assoc_file, # filtered by the cco proteins (in practice C F aspects only)
   $up_map_file, # cco proteins: UniProt 'AC'\t'ID'
   $go_map_file, # 'go_id'\t'cco_id' (in practice C F terms only)
   ) = @{shift @_};

   # construct the maps
   my %up_map; # keys - UniProt ACs, values - UniProt IDs
   open my $FH, '<',  $up_map_file || croak "The file $up_map_file couldn't be opened";
   while (<$FH>) {
       chomp;
       my ($ac, $id) = split;
       $up_map{$ac} = $id;
   }
   close $FH;
   my %go_map; # keys - GO ids, values - CCO ids
   open $FH, '<',  $go_map_file || croak "The file $go_map_file couldn't be opened";
   while (<$FH>) {
       chomp;
       my ($go_id, $cco_id) = split;
       $go_map{$go_id} = $cco_id;
   }
   close $FH;

   # Initialize the OBO parser, load the input OBO file, check the assumptions
   my $obo_parser = OBO::Parser::OBOParser->new();
   my $ontology = $obo_parser->work($in_obo_file);
   my $is_a  = 'is_a';
   my $participates_in = 'participates_in';
   my $has_participant = 'has_participant';
   my $located_in      = 'located_in';
   my $location_of     = 'location_of';
   my $has_function    = 'has_function';
   foreach (($is_a, $participates_in, $has_participant, $located_in, $location_of, $has_function)){
       die "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$_});
   }

   my %protein_terms; # keys - UP ACs, values - Term.pm objects for cco proteins
   my %go_terms; # keys - GO ids, values - Term.pm objects for cco go terms

   # parse the GOA associations file
   my $goa_parser = OBO::CCO::GoaParser->new();
   my $goa_assoc_set = $goa_parser->parse($goa_assoc_file);
   foreach my $goaAssoc (@{$goa_assoc_set->{SET}}){

       # get protein term
       my $up_ac = $goaAssoc->obj_id();
       my $protein = $protein_terms{$up_ac};
       if (!$protein) {
           my $up_id = $up_map{$up_ac};
           if (!$up_id) {
               carp "No UniProt ID for $up_ac in $up_map_file";
               next;
           }
           $protein = $ontology->get_term_by_name($up_id);
           if (!$protein) {
               carp "No protein term in $in_obo_file for $up_ac|$up_id";
               next;
           }
           $protein_terms{$up_ac} = $protein;
       }
       # get GO term
       my $go_id = $goaAssoc->go_id();
       my  $go_term = $go_terms{$go_id};
       if (!$go_term) {
           my $cco_id = $go_map{$go_id};
           if (!$cco_id) {
               carp "No CCO id for $go_id in $go_map_file\n";
               next;
           }
           $go_term = $ontology->get_term_by_id($cco_id);
           if (!$go_term) {
               carp "No GO term in $in_obo_file for $cco_id\n";
               next;
           }
           $go_terms{$go_id} = $go_term;
       }

       # create relations
       my $aspect = $goaAssoc->aspect();
       if ($aspect eq 'F') {
           $ontology->create_rel($protein, $has_function, $go_term);
       }
       elsif ($aspect eq 'C') {
           $ontology->create_rel($protein,     $located_in,  $go_term);
           $ontology->create_rel($go_term, $location_of, $protein); # inverse of 'located_in'
       }
       elsif ($aspect eq 'P') {
           $ontology->create_rel($protein,     $participates_in, $go_term);
           $ontology->create_rel($go_term, $has_participant, $protein); # inverse of 'participates_in'
       }
       else {carp "An illigal aspect in the GOA file $goa_assoc_file\n"}
   }

   # Write the new ontology to disk
   open (FH, ">".$out_obo_file) || die "Cannot write OBO file: ", $!;
   $ontology->export(\*FH);
   select( ( select($FH), $| = 1 )[0] );
   close FH;
   return $ontology;
}

1;