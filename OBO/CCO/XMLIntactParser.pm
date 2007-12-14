# $Id: XMLIntactParser.pm 1704 2007-12-06 17:33:49Z erant $
#
# Module  : XMLIntactParser.pm
# Purpose : An XML Parser.
# License : Copyright (c) 2007 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package OBO::CCO::XMLIntactParser;

=head1 NAME

OBO::CCO::XMLIntactParser - An IntAct XML parser
    
=head1 SYNOPSIS

my $XMLIntactParser = XMLIntactParser->new;
$XMLIntactParser->work($intact_xml_file);
my @xml_interactors = @{$XMLIntactParser->interactors()};
my @xml_interactions = @{$XMLIntactParser->interactions()};

=head1 DESCRIPTION

A parser for XML Intact files. It produces two arrays of interactor and interaction objects.

=head1 AUTHOR

Mikel Egana Aranguren, mikel.eganaaranguren@cs.man.ac.uk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use XML::Simple;
use OBO::CCO::Interactor;
use OBO::CCO::Interaction;


use strict;
use warnings;
use Carp;


sub new {
	my $class = shift;
	my $self = {}; 
	$self->{interactors} = [];
	$self->{interactions} = [];
	bless ($self, $class);
	return $self;
}

=head2 work

  Usage    - $XMLIntactParser->work($intact_xml_file)
  Returns  - Nothing
  Args     - An IntAct XML file
  Function - Reads an IntAct XML file and generates two arrays of interactor and interaction objects, to be obtained with the interactors and interactions methods
  
=cut

sub work {
	my $self = shift;
	my $xml_file_name= shift;
	my $xml = XMLin($xml_file_name);
	&read ($self,$xml); 
	# It should be recursive but it gave me problems with 
	# the ref to $self, even passing it at each round
}

=head2 interactors

  Usage    - $XMLIntactParser->interactors()
  Returns  - Array of interactor objects
  Args     - None
  Function - Get interactor objects
  
=cut

sub interactors{
	my $self = shift;
	if (@_) { $self->{interactors} = shift }
	my @interactors = @{$self->{interactors}};
	return \@interactors;
}

=head2 interactions

  Usage    - $XMLIntactParser->interactions()
  Returns  - Array of interaction objects
  Args     - None
  Function - Get interaction objects
  
=cut

sub interactions{
	my $self = shift;
	if (@_) { $self->{interactions} = shift }
	my @interactions = @{$self->{interactions}};
	return \@interactions;
}

sub read{
	my $self = shift;
	my $entries = shift;
	my @new_interactors = ();
	my @new_interactions = ();
	while ( my ($key, $value) = each(%{$entries}) ) {
		
		if($key eq "entry"){
			while ( my ($key1, $value1) = each(%{$value}) ){
				if($key1 eq "interactionList"){
					my %interactions=%{$value1->{'interaction'}};
					
					while (my($key_a, $value_a) = each(%interactions)){
						my $interaction = OBO::CCO::Interaction->new;
						while (my($key_3, $value_3) = each(%{$value_a})){
							if($key_3 eq "names"){
								my %names_proper = %{$value_3};
								while(my($key_name, $value_name) = each(%names_proper)){
									if($key_name eq "shortLabel"){
										$interaction->shortLabel($value_name);
									}
									# Some interactions don't have full name
									if($key_name eq "fullName"){
										$interaction->fullName($value_name);
									}
								}
							}
							if($key_3 eq "xref"){
								my %primaryRef = %{$value_3->{"primaryRef"}};
								while(my($key_name, $value_name) = each(%primaryRef)){
									if ($key_name eq "id"){
										$interaction->primaryRef($value_name);
									}
								}
							}
							if($key_3 eq "interactionType"){
								my %types = %{$value_3->{"names"}};
								my $interactionType = "";
								while(my($key_name, $value_name) = each(%types)){
									if($key_name eq "shortLabel"){
										$interactionType = $value_name;
									}
								}
								$interaction->interactionType($interactionType);
							}
							
							if($key_3 eq "participantList"){
								my @interactor_ids = ();
								my %participant = %{$value_3->{"participant"}};
								my %interactorRefRole = ();
								
								while(my($key_name, $value_name) = each(%participant)){
									if($key_name =~ m/\d+/){
										my $interactorRef = $value_name->{"interactorRef"};
										push(@interactor_ids,$interactorRef);
										my %possibleRoles = %{$value_name->{"experimentalRoleList"}};
										my $interactorRole = $possibleRoles{"experimentalRole"}{"names"}{"shortLabel"};
										$interactorRefRole{$interactorRef}=$interactorRole;
									}
								}
								$interaction->interactorRef(\@interactor_ids);
								$interaction->interactorRefRoles(\%interactorRefRole);
							}
						}
						push(@new_interactions,$interaction);
					}
				}
				if($key1 eq "interactorList"){
					my %interactors=%{$value1};
					while (my($key_interactor, $value_interactor) = each(%interactors)){
						while(my($key_in, $value_in) = each(%{$value_interactor})){
							my $interactor = OBO::CCO::Interactor->new;
							$interactor->id($key_in);
							my %interactor_info = %{$value_in};
							while (my($key_int, $value_int) = each(%interactor_info)){
								if($key_int eq "names"){
									my %interactor_names = %{$value_int};
									while(my($key_name, $value_name) = each(%interactor_names)){
										my @aliases = ();
										if($key_name eq "alias" && $value_name =~ m/HASH/){
											while(my($k_alias, $v_alias) = each(%{$value_name})){
												if($k_alias eq "content"){
													push(@aliases,$v_alias);
												}
											}
										}
										if($key_name eq "alias" && $value_name =~ m/ARRAY/){
											for my $alias_names (@{$value_name}){
												while(my($k_alias, $v_alias) = each(%{$alias_names})){
													if($k_alias eq "content"){
														push(@aliases,$v_alias);
													}
												}
											}
										}
										$interactor->alias(\@aliases);
										if($key_name eq "shortLabel"){
											$interactor->shortLabel($value_name);
										}
										if($key_name eq "fullName"){
											$interactor->fullName($value_name);	
										}	
									}
								}
								if($key_int eq "organism"){
									my %organism_names = %{$value_int};
									while(my($key_name, $value_name) = each(%organism_names)){
										if($key_name eq "ncbiTaxId" && $value_name !~ m/HASH/){
											$interactor->ncbiTaxId($value_name);
										} 
									}
								}
								if($key_int eq "xref"){
									my $ebi_id_for_no_sec_ref = undef;
										
									my %primaryInteractorRefs = %{$value_int->{'primaryRef'}};
									while(my($key_name, $value_name) = each(%primaryInteractorRefs)){
# 										print $key_name,"--------",$value_name,"\n";
										if($key_name eq "id"){
											$interactor->uniprot($value_name);
											$ebi_id_for_no_sec_ref = $value_name;
											if($value_name =~ m/UPI0000/){
												$interactor->uniprot_secondary($value_name);
											}
										}
										if($key_name eq "secondary"){
											$interactor->uniprot_secondary($value_name);
										}
									}
									
									if(!defined $value_int->{'secondaryRef'}){
										$interactor->ebi_id($ebi_id_for_no_sec_ref);
									}
									else{
										my %secondaryInteractorRefs = %{$value_int->{'secondaryRef'}};
										while(my($key_name, $value_name) = each(%secondaryInteractorRefs)){
											if($key_name =~ m/EBI/){
												$interactor->ebi_id($key_name);
											}
											if($value_name =~ m/EBI/){
												$interactor->ebi_id($value_name);
											}
										}
									}
								}
							}
							push(@new_interactors,$interactor);
						}
					}
				}
			}
		}
	}
	$self->interactors(\@new_interactors);
	$self->interactions(\@new_interactions);
}

1;