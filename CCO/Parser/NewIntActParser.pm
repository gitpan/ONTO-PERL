# $Id: NewIntActParser.pm 1441 2007-08-21 11:58:25Z erant $
#
# Module  : NewIntActParser.pm
# Purpose : Parse IntAct files
# License : Copyright (c) 2006 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#

package CCO::Parser::NewIntActParser;

=head1 NAME

CCO::Parser::IntActParser  - An IntAct to OBO parser/filter.

=head1 DESCRIPTION

A new parser for IntAct to OBO conversion. The conversion is filtered 
according to the proteins already existing in the OBO file and the 
roles this proteins have in the interactions (prey, bait, neutral 
component). It deletes any interaction in OBO that it is not present 
in IntAct, for sync.

=head1 AUTHOR

Vladimir Mironov
vlmir@psb.ugent.be

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use CCO::Parser::OBOParser;
use CCO::Core::Relationship;
use CCO::Core::Dbxref;
use CCO::Core::Term;
use CCO::Util::CCO_ID_Term_Map;
use CCO::Util::DbxrefSet;
use CCO::Util::Set;

use Data::Dumper;
use strict;
use warnings;
use Carp;

sub new {
	my $class = shift;
	my $self  = {};

	bless( $self, $class );
	return $self;
}

=head2 work

  Usage    - 
  Returns  - 
  Args     - 
  Function - 
  
=cut

sub work {
	my $self = shift;

	# Get the arguments
	my (
		$old_OBO_file, $new_OBO_file,   
		$short_b_file, $long_b_file,    $short_i_file,
		$long_i_file,  $up_cc_map_file, $up_map_file, @intact_files,
	) = @{ shift @_ };

	# Initialize the OBO parser, load the OBO file, check the assumptions
	my $obo_parser = CCO::Parser::OBOParser->new();
	my $ontology   = $obo_parser->work($old_OBO_file);
	my @rel_types = ( 'is_a', 'participates_in', 'located_in', 'belongs_to' );
	foreach (@rel_types) {
		confess "Not a valid relationship type"
		  unless ( $ontology->{RELATIONSHIP_TYPES}->{$_} );
	}
	my $onto_protein = $ontology->get_term_by_name("protein")
	  || confess "the term 'protein' is not defined", $!;

	# Initialize CCO_ID_Map objects
	my $short_b_map =
	  CCO::Util::CCO_ID_Term_Map->new($short_b_file);    # Taxon specific
	my $long_b_map =
	  CCO::Util::CCO_ID_Term_Map->new($long_b_file);     # Set of protein IDs
	my $short_i_map =
	  CCO::Util::CCO_ID_Term_Map->new($short_i_file);    # Taxon specific
	my $long_i_map =
	  CCO::Util::CCO_ID_Term_Map->new($long_i_file);     # Set of interaction IDs

	# Read UniProt maps (keys - accession numbers, values - protein IDs)
	open my $fh, '<', $up_cc_map_file or croak "Can't open file $up_cc_map_file : $!";
	my %up_cc_map;
	while (<$fh>) {
		my ( $acc, $name ) = split( /\t/, $_ );
		chomp $acc;
		chomp $name;
		$up_cc_map{$acc} = $name;
	}
	close $fh;
	my $up_cc_map = \%up_cc_map;

	open $fh, '<', $up_map_file or croak "Can't open file $up_cc_map_file : $!";
	my %up_map;
	while (<$fh>) {
		my ( $acc, $name ) = split( /\t/, $_ );
		chomp $acc;
		chomp $name;
		$up_map{$acc} = $name;
	}
	close $fh;
	my $up_map = \%up_map;
	
	foreach my $intact_file (@intact_files) {
	# parse the IntAct file
		require XML::XPath;
		my $xpath = XML::XPath->new( filename => $intact_file );
		my $int_set = $xpath->find("/entrySet/entry/interactionList/interaction");
		foreach my $interaction ( $int_set->get_nodelist() ) {
			my $int_id = $interaction->find( "\@id", $interaction );
			$int_id = $int_id->string_value();		
			my $int_name =
			  $interaction->find( "names/shortLabel/text()", $interaction );
			$int_name = $int_name->string_value();    # interaction name
			my $int_comment =
			  $interaction->find( "names/fullName/text()", $interaction );
			$int_comment = $int_comment->string_value();    # interaction full name
			my $int_type =
			  $interaction->find( "interactionType/names/shortLabel/text()",
				$interaction );# $int_type is an object XML::XPath::NodeSet
			$int_type = $int_type->string_value(); # interaction type
			my $ref = $interaction->find( "xref/primaryRef/\@id", $interaction );
			$ref = $ref->string_value();
			my $participants =
			  $xpath->find("/entrySet/entry/interactionList/interaction[\@id = $int_id]/participantList/participant");
			my %exp_roles;
			my %cc_interactors;
			my %accs;
			foreach my $participant ( $participants->get_nodelist() ) {
				my $part_id = $participant->find("\@id");
				$part_id = $part_id->string_value();    # participant id
				my $int_ref =
				  $participant->find( "interactorRef/text()", $participant );
				$int_ref =  $int_ref->string_value();  # ref for the interactor    
				my $acc =
				  $xpath->find("/entrySet/entry/interactorList/interactor[\@id = $int_ref]/xref/primaryRef/\@id");
				$acc = $acc->string_value();
				my $role = $participant->find("experimentalRoleList/experimentalRole/names/shortLabel/text()", $participant);
				$role = $role->string_value();#print Dumper($role);
				if ( contains_key( $up_map, $acc ) ) {    # only homologous proteins are accepted
					$exp_roles{$part_id} = $role;
					$accs{$part_id}      = $acc;
					if ( contains_key( $up_cc_map, $acc ) )
					{    # the interactor is a core cell cycle protein
						$cc_interactors{$part_id} = 1;
					} else {
						$cc_interactors{$part_id} = 0;
					}
				} else {
					#warn "$acc is either a heterologous protein or not a protein at all";
				}
			}
	
			# filtering interactions
			next unless contains_value( \%cc_interactors, 1 );  # only interactions containing at least one core cell cycle protein
			next unless scalar keys %cc_interactors >  1;    # at least 2 proteins left in the interaction after filtering
			my $neutral_comp = contains_value( \%exp_roles, 'neutral component' );
			my $bait         = contains_value( \%exp_roles, 'bait' );
			next unless ( $bait or $neutral_comp );     # excludes interactions that lost the bait during filtering
			
			# creating interaction terms
			my $int_term = CCO::Core::Term->new();
			$int_term->name("$int_name $int_type");
			$int_comment =~ s/\n+//g; # cleaning the comment lines
			$int_comment =~ s/\t+//g;
			$int_comment =~ s/\r+//g;
			$int_term->comment("$int_comment");
			$int_term->xref_set_as_string("[IntAct:$ref]");
			my ($int_cco_id) =  set_cco_id( $short_i_map, $long_i_map, "$int_name $int_type", 'I' );
			$int_term->id($int_cco_id);
			$ontology->add_term($int_term);
					
			my $mi_type = $ontology->get_term_by_name_or_synonym($int_type);# TODO get_term_by_name_or_synonym
			# the function string_value() returns the string-value of the first node in the list
			# in this case there is only one node
			
			confess "int_term is not defined" if (!$int_term);
			confess "mi_type is not defined" if (!$mi_type);
			$ontology->create_rel( $int_term, 'is_a', $mi_type );
	
			# creating participant terms
			if ($neutral_comp) {# the interaction involves neutral components
	
				foreach ( keys %accs ) {
					$ontology = add_participant( $ontology, $int_term, $short_b_map,
						$long_b_map, \%up_map, \%accs );
				}
			} elsif ($bait) {# the interaction contains a bait
				my $bait_key;
				foreach ( keys %exp_roles ) {
					if ( $exp_roles{$_} eq 'bait' ) {
						$bait_key = $_;
						last;
					}
				}
				if ( $cc_interactors{$bait_key} ) {# the bait is a core cell cycle protein
					foreach ( keys %accs ) {
						$ontology =
						  add_participant( $ontology, $int_term, $short_b_map,
							$long_b_map, \%up_map, \%accs );
					}
				} else {
					foreach ( keys %accs ) {
						# the protein is either a cell cycle protein or a bait
						if ( $cc_interactors{$_} or ( $exp_roles{$_} eq 'bait' ) )
						{    
							$ontology =
							  add_participant( $ontology, $int_term, $short_b_map,
								$long_b_map, \%up_map, \%accs );
						}
					}
				}
			}
		}	
	}

	
	# Write the new ontology and map to disk
	open( FH, ">" . $new_OBO_file ) || die "Cannot write OBO file: ", $!;
	$ontology->export( \*FH );
	close FH;
	$short_b_map->write_map();
	$long_b_map->write_map();
	$short_i_map->write_map();
	$long_i_map->write_map();

	return $ontology;
}

sub contains_key {
	my ( $hash, $key ) = @_;
	return ( defined $hash->{$key} ) ? 1 : 0;
}

sub contains_value {
	my ( $hash, $value ) = @_;

	select( ( select(STDOUT), $| = 1 )[0] );    # flushing the buffer

	foreach ( keys %{$hash} ) {
		if ( "$hash->{$_}" eq $value ) {
			return 1;
		}
	}
	return 0;
}

sub set_cco_id {
	my ( $short_map, $long_map, $term_name, $type ) = @_;

	my $int_cco_id;
	if ( $short_map->contains_value($term_name) ) {
		$int_cco_id = $short_map->get_cco_id_by_term($term_name);
	} else {
		$int_cco_id = $long_map->get_new_cco_id( "CCO", $type, $term_name );
		$short_map->put( $int_cco_id, $term_name );    #updates the taxon specific maps
	}

	return ($int_cco_id);
}

sub add_participant {
	my ( $ontology, $int_term, $short_b_map, $long_b_map, $up_map, $accs ) = @_;
	my $prot_acc = $accs->{$_};

	my $prot_name = $up_map->{$prot_acc};
	my $protein = $ontology->get_term_by_name($prot_name);

	if ( !defined $protein ) {
		$protein = CCO::Core::Term->new();
		$protein->xref_set_as_string("[UniProt:$prot_acc]");
		my $prot_id = set_cco_id( $short_b_map, $long_b_map, $prot_name, 'B' );

		$protein->id($prot_id);
		$ontology->add_term($protein);
	}
	$protein->name($prot_name);
	$ontology->create_rel( $protein, 'participates_in', $int_term );
	return ($ontology);
}

1;