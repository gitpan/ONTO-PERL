# $Id: XMLIntactParser.pm 1 2006-06-01 16:21:45Z erant $
#
# Module  : XMLIntactParser.pm
# Purpose : An XML Parser.
# License : Copyright (c) 2007 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package CCO::Util::XMLIntactParser;

use XML::Simple;
use CCO::Core::Interactor;
use CCO::Core::Interaction;

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

sub work {
	my $self = shift;
	my $xml_file_name= shift;
	my $xml = XMLin($xml_file_name);
	&read ($self,$xml); # It should be recursive but it gave me problems with the ref to $self, even passing it at eahc round
}

sub interactors{
	my $self = shift;
	if (@_) { $self->{interactors} = shift }
	my @interactors = @{$self->{interactors}};
	return \@interactors;
}

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
# 				print $key1,"-",$value1,"\n";
				if($key1 eq "interactionList"){
					my %interactions=%{$value1->{'interaction'}};
					
					while (my($key_a, $value_a) = each(%interactions)){
# 						print $key_a,"--",$value_a,"\n";
						my $interaction = CCO::Core::Interaction->new;
						while (my($key_3, $value_3) = each(%{$value_a})){
# 							print $key_3,"---",$value_3,"\n";
							if($key_3 eq "names"){
								my %names_proper = %{$value_3};
								while(my($key_name, $value_name) = each(%names_proper)){
									if($key_name eq "shortLabel"){
# 										print "SHORTLABEL:",$value_name,"!\n";	
										$interaction->shortLabel($value_name);
									}
									# Some interactions don't have full name
									if($key_name eq "fullName"){
# 										print "FULLNAME:",$value_name,"!\n";	
										$interaction->fullName($value_name);
									}
								}
							}
							if($key_3 eq "xref"){
								my %primaryRef = %{$value_3->{"primaryRef"}};
								while(my($key_name, $value_name) = each(%primaryRef)){
									if ($key_name eq "id"){
# 										print "XREF:",$value_name,"!\n";
										$interaction->primaryRef($value_name);
									}
								}
							}
							if($key_3 eq "interactionType"){
								my %types = %{$value_3->{"names"}};
								my $interactionType = "";
								while(my($key_name, $value_name) = each(%types)){
# 									print $key_name," ----- ",$value_name,"\n";
									if($key_name eq "shortLabel"){
										$interactionType = $interactionType.$value_name;
									}
									if($key_name eq "alias"){
										$interactionType = $interactionType.":".$value_name;
									}
								}
# 								print $interactionType,"\n";
								$interaction->interactionType($interactionType);
							}
							
							if($key_3 eq "participantList"){
								my @interactor_ids = ();
								my %participant = %{$value_3->{"participant"}};
								while(my($key_name, $value_name) = each(%participant)){
									if($key_name =~ m/\d+/){
# 										print $key_name,"\n";
# 										print "PARTICIPATN INTERACTOR ID:", $value_name->{"interactorRef"},"!\n";
										push(@interactor_ids,$value_name->{"interactorRef"});
									}
								}
								$interaction->interactorRef(\@interactor_ids);
							}
						}
						push(@new_interactions,$interaction);
					}
				}
				if($key1 eq "interactorList"){
					my %interactors=%{$value1};
					while (my($key_interactor, $value_interactor) = each(%interactors)){
						while(my($key_in, $value_in) = each(%{$value_interactor})){
							my $interactor = CCO::Core::Interactor->new;
# 							print "interactorlist INTERACTOR ID:",$key_in,":\n";
							$interactor->id($key_in);
							my %interactor_info = %{$value_in};
# 							print "INTERACTOR :::::::::::::::\n";
							while (my($key_int, $value_int) = each(%interactor_info)){
								if($key_int eq "names"){
									my %interactor_names = %{$value_int};
									while(my($key_name, $value_name) = each(%interactor_names)){
										my @aliases = ();
										if($key_name eq "alias" && $value_name =~ m/HASH/){
											while(my($k_alias, $v_alias) = each(%{$value_name})){
												if($k_alias eq "content"){
# 													print "ALIAS HASH:",$v_alias,"\n";
													push(@aliases,$v_alias);
												}
											}
										}
										if($key_name eq "alias" && $value_name =~ m/ARRAY/){
											for my $alias_names (@{$value_name}){
												while(my($k_alias, $v_alias) = each(%{$alias_names})){
													if($k_alias eq "content"){
# 														print "ALIAS ARRAY:",$v_alias,"\n";
														push(@aliases,$v_alias);
													}
												}
											}
										}
										$interactor->alias(\@aliases);
										if($key_name eq "shortLabel"){
# 											print "SHORTLABEL:",$value_name,"\n";	
											$interactor->shortLabel($value_name);
										}
										if($key_name eq "fullName"){
# 											print "FULLNAME:",$value_name,"\n";
											$interactor->fullName($value_name);	
										}	
									}
								}
								if($key_int eq "organism"){
									my %organism_names = %{$value_int};
									while(my($key_name, $value_name) = each(%organism_names)){
										if($key_name eq "ncbiTaxId" && $value_name !~ m/HASH/){
# 											print "ORGANISM:",$value_name,"\n";
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
# 										print $interactor->id,"!?\n";
# 										print $value_int,"\n";
# 										my %value_hash = %{$value_int};
# 										for my $f_key (keys %value_hash){
# 											print %value_hash->{$f_key},"\n";
# 											my %hash_again = %{%value_hash->{$f_key}};
# 											for my $FF_key (keys %hash_again){
# 												print %hash_again->{$FF_key},"\n";
# 											}
# 										}
									}
									else{
	# 									print $value_int->{'secondaryRef'},"\n";
										my %secondaryInteractorRefs = %{$value_int->{'secondaryRef'}};
										while(my($key_name, $value_name) = each(%secondaryInteractorRefs)){
# 											print "----",$key_name,"-----",$value_name,"\n";
											if($key_name =~ m/EBI/){
	# 											print "INTERACTOR EBI ID:",$key_name,"\n";
												$interactor->ebi_id($key_name);
											}
											if($value_name =~ m/EBI/){
	# 											print "INTERACTOR EBI ID:",$value_name,"\n";
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
