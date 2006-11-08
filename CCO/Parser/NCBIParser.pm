package CCO::Parser::NCBIParser;
use CCO::Parser::OBOParser;
use CCO::Core::Ontology;
use CCO::Core::Relationship;
use CCO::Core::RelationshipType;
use CCO::Core::Dbxref;
use CCO::Core::Term;

use strict;
use warnings;
use Carp;

my %selected_nodes = (); # taxon id=> parent id
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
  Args     - old OBO file, new OBO file, nodes dump file, names dump file, taxon 1, taxon 2, ...
  Function - converts NCBI taxonomy into an OBO file
  
=cut


sub work {
	my $self = shift;

	# Get the arguments
	my $old_OBOfileName = shift;
	my $new_OBOfileName = shift;
	my $NCBInodesFileName = shift;
	my $NCBInamesFileName = shift;
	my @allthetaxa = @_;

	# Create the hashes: 
	# %nodes=[child node id] - [parent node id] 
	# %names=[child node id] - [scientific name]
	# !!!TODO!!! %ranks=[child node id] - [rank]
	my %nodes=();
	my %names=();

	# Open and parse the nodes file (We want groups 1 and 2)
	open(NCBInodesFile, $NCBInodesFileName) || die("can't open file: $!");
	my @mynodelines =<NCBInodesFile>;
	foreach my $theline (@mynodelines){
		if ($theline =~ /(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|/){
			my $child=$1;
			my $parent=$2;
			$child=~ s/\s//g;
			$parent=~ s/\s//g;
			$nodes{$child} = $parent; 
		}
	}
	close(NCBInodesFile);

	# Open and parse names file (we want groups 1 and 2 only if group 4 is scientific name)
	open(NCBInamesFile, $NCBInamesFileName) || die("can't open file: $!");
	my @mynamelines =<NCBInamesFile>;
	foreach my $theline (@mynamelines){
		if ($theline =~ /(.+)\|(.+)\|(.+)\|(.+)\|/){
			my $childid=$1;
			my $childname=$2;
			my $nametype=$4;
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
	my $my_parser = CCO::Parser::OBOParser->new;
	my $ontology = $my_parser->work($old_OBOfileName);

	# Create new hashes for the only interesting terms
# 	my %selected_nodes=(); # taxon id=> parent id
# 	my %selected_names =(); # taxon id => taxon name

	# Get the interesting terms
	foreach my $thetaxon (@allthetaxa){
		&getParentsRecursively ($thetaxon,\%nodes,\%names,\%selected_nodes,\%selected_names);	
	}

	# Put all the interesting term in the ontology without structure
	# if the term happens to be "root", add it as "organism"
	foreach my $el (keys %selected_nodes){
		#print $el, "-", $selected_nodes{$el},"-",$selected_names{$el},"\n";
		my $OBO_taxon=CCO::Core::Term->new();
		my $name=$selected_names{$el};
		if($name eq "root"){
			$OBO_taxon->name("organism");
		}
		else{
			$OBO_taxon->name($selected_names{$el});
		}
		$OBO_taxon->id(&convertToCCO($el));
		$OBO_taxon->xref_set_as_string("NCBI:".$el);
		$ontology->add_term($OBO_taxon);
	}

	# add "organism is_a continuant"
	my $OBO_cellular_organisms=$ontology->get_term_by_name("organism");
	my $OBO_continuant=$ontology->get_term_by_name("continuant");
	my $is_a_rel = CCO::Core::Relationship->new();
	$is_a_rel->type("is_a");
	$is_a_rel->link($OBO_cellular_organisms,$OBO_continuant);
	my $rel_id=$OBO_cellular_organisms->id()."_is_a_".$OBO_continuant->id();
	$is_a_rel->id($rel_id);
	$ontology->add_relationship($is_a_rel); 

	# Put the is_a relationships to each term but not if the child is root (cyclic is_a)
	foreach my $el (keys %selected_nodes){
		#print "ELEMENT ID: ",$el,"\n";
		my $OBO_taxon_term=$ontology->get_term_by_id(&convertToCCO($el));
		my $OBO_taxon_parent=$ontology->get_term_by_id(&convertToCCO($selected_nodes{$el}));
		#print "CHILD: ", $OBO_taxon_term->name(), " - ", "PARENT: ", $OBO_taxon_parent->name(),"\n";
		#print "CHILD: ", $OBO_taxon_term->id(), " - ", "PARENT: ", $OBO_taxon_parent->id(),"\n";
		if($el!=1){
			my $is_a_rel = CCO::Core::Relationship->new();
			$is_a_rel->type("is_a");
			$is_a_rel->link($OBO_taxon_term,$OBO_taxon_parent);
			my $rel_id=$OBO_taxon_term->id()."_is_a_".$OBO_taxon_parent->id();
			#print $rel_id,"\n";
			$is_a_rel->id($rel_id);
			$ontology->add_relationship($is_a_rel); 
		}
	}

	# Write the new ontology to disk
	open (FH, ">".$new_OBOfileName) || die "Cannot write OBO file ", $!;
	$ontology->export(\*FH);
	close FH;
	#my $OBO_taxon=CCO::Core::Term->new();
	#$OBO_taxon->name("Eryc");
	#$OBO_taxon->id("CCO:Eryc");
	#$OBO_taxon->xref("NCBI:Eryc");
	#$ontology->add_term($OBO_taxon);	
	return $ontology;
}

########################################################################
# Subroutines
########################################################################

sub getParentsRecursively (){
	my ($taxon,$nodes,$names,$selected_nodes,$selected_names)=@_;
	my $child_id=$taxon;
	my $parent_id=${$nodes}{$taxon};
	my $child_name=${$names}{$taxon};
	my $parent_name=${$names}{$taxon};
	$selected_nodes{$child_id}=$parent_id;
	$selected_names{$child_id}=$child_name;
	if($child_id!=1){
		&getParentsRecursively($parent_id,$nodes,$names,$selected_nodes,$selected_names);
	}
}

# Convert a taxon id to a CCO id (27->CCO:T0000027)
sub convertToCCO (){
	my ($taxonName)=@_;
	my $CCObase="CCO:T";
	my $zero="0";
	my $amount_zeros=7-length($taxonName);
	for(my $ind=0;$ind<$amount_zeros;$ind++){
		$CCObase=$CCObase.$zero;
	}
	return $CCObase.$taxonName;
}

1;

=head1 NAME


    CCO::Parser::NCBIParser - A NCBI taxonomy to OBO translator.


=head1 DESCRIPTION


This parser converts chosen parts of the NCBI taxonomy-tree into an OBO file. 
Some taxa are given to the parser and the whole tree till the root is 
reconstructed in a given OBO ontology, using scientific names.

The dump files (nodes.dmp and names.dmp) should be obtained from: 

	ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

The parser assumes that there is an already existing OBO term in the ontology 
called "continuant".

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
