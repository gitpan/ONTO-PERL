# $Id: GoaToRDF.pm 2165 2010-09-29 Erick Antezana $
#
# Module  : GoaToRDF.pm
# Purpose : A GOA associations to RDF converter
# License : Copyright (c) 2008 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package OBO::CCO::GoaToRDF; 

=head1 NAME

OBO::CCO::GoaToRDF - A GOA associations to RDF converter.

=head1 DESCRIPTION

Converts a GOA association file to a RDF graph. The RDF graph is very simple, 
containing a node for each line from the association file (called GOA_ASSOC_n), 
and several triples for the fields (e.g. obj_symb).

GOA associations files can be obtained from http://www.ebi.ac.uk/GOA/proteomes.html

The method 'work' gets an assoc file path and a file handler for the RDF graph. 

=head1 AUTHOR

Mikel Egana Aranguren
mikel.egana.aranguren@gmail.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use OBO::CCO::GoaParser;
use strict;
use warnings;
use Carp;

sub new {
	my $class                   = shift;
	my $self                    = {}; 
	
	bless ($self, $class);
	return $self;
}

=head2 work

  Usage    - $GoaToRDF->work($RDF_file_handler,$path_to_assoc_file)
  Returns  - RDF file handler
  Args     - a file handler for the new RDF file and the path to the assoc. file.
  Function - converts an assoc. file to an RDF graph
  
=cut

sub work {
	my $self = shift;

	# Get the arguments
	my ($file_handle, $path_to_assoc_file) = @_;
	
	#
	# Hard-coded evidence codes
	#
	my %evidence_code_by_id = (
	'IEA'	 => 'ECO_00000067',
	'ND'	 => 'ECO_0000035',
	'IDA'	 => 'ECO_0000002',
	'IPI'	 => 'ECO_0000021',
	'TAS'	 => 'ECO_0000033',
	'NAS'	 => 'ECO_0000034',
	'ISS'	 => 'ECO_0000041',
	'IMP'	 => 'ECO_0000015',
	'IC'	 => 'ECO_0000001',
	'IGI'	 => 'ECO_0000011',
	'IEP'	 => 'ECO_0000008',
	'RCA'	 => 'ECO_0000053',
	'IGC'	 => 'ECO_0000177',
	'EXP'	 => 'ECO_0000006'
	);
	
	#
	# Aspects
	#
	my %aspect = (
	'P'	 => 'participates_in',
	'C'	 => 'located_in',
	'F'	 => 'has_function'
	);
	
	# For the ID
	$path_to_assoc_file =~ /.*\/(.*)/; # get what is after the slash in the path...
	my $f_name = $1;
	(my $prefix_id = $f_name) =~ s/\.goa//;
	$prefix_id =~ s/\./_/g;

	# TODO: set all the NS and URI via arguments
	my $default_URL = "http://www.semantic-systems-biology.org/ontology/rdf/"; 

	my $NS = "GOA";
	my $ns = lc ($NS);
	my $rdf_subnamespace = "assoc";

	# Preamble of RDF file
	print $file_handle "<?xml version=\"1.0\"?>\n";
	print $file_handle "<rdf:RDF\n";
	print $file_handle "\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n";
	print $file_handle "\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n";
	print $file_handle "\txmlns:".$ns."=\"".$default_URL.$NS."#\"\n"; # Change this URL according to your needs
	my $goa_ns     = $default_URL."GOA#";
	my $obo_ns     = $default_URL."OBO#";
	my $uniprot_ns = $default_URL."UNIPROT#";
	my $ncbi_ns    = $default_URL."NCBI#";
	print $file_handle "\txmlns:obo=\"".$obo_ns."\"\n";
	print $file_handle "\txmlns:uniprot=\"".$uniprot_ns."\"\n";
	print $file_handle "\txmlns:ncbi=\"".$ncbi_ns."\">\n";
	
	my $GoaParser = OBO::CCO::GoaParser->new;
	my $goaAssocSet = $GoaParser->parse($path_to_assoc_file);
	
	my %prot_duplicated; # to add only one copy of the protein
	
	# Chunk of RDF file	
	foreach ($goaAssocSet->get_set()) {
		my %assoc = %{$_};
		
		#
		# the protein: (this should come from uniprot.rdf)
		#
		#print $file_handle "\t<",$ns,":".$prot_space." rdf:about=\"#".$prefix_id."_".$assoc{ASSC_ID}."\">\n";
		if (!$prot_duplicated{$assoc{OBJ_ID}}) {
			my $prot_space = "prot";
			print $file_handle "\t<".$ns.":".$prot_space." rdf:about=\"".$uniprot_ns.$assoc{OBJ_ID}."\">\n";
			print $file_handle "\t\t<rdfs:label xml:lang=\"en\">".&char_hex_http($assoc{OBJ_SYMB})."</rdfs:label>\n";
			print $file_handle "\t\t<".$ns.":annot_src>".&char_hex_http($assoc{ANNOT_SRC})."</".$ns.":annot_src>\n";
			my $t = $assoc{TAXON};
			$t =~ s/taxon:/NCBI_/; # clean it
			print $file_handle "\t\t<".$ns.":taxon>".$t."</".$ns.":taxon>\n";
			print $file_handle "\t\t<obo:has_source rdf:resource=\"".$ncbi_ns.$t."\"/>\n";
			print $file_handle "\t\t<".$ns.":type>".&char_hex_http($assoc{TYPE})."</".$ns.":type>\n";
			print $file_handle "\t\t<".$ns.":description>".&char_hex_http($assoc{DESCRIPTION})."</".$ns.":description>\n";
			print $file_handle "\t\t<".$ns.":obj_src>".&char_hex_http($assoc{OBJ_SRC})."</".$ns.":obj_src>\n";
			print $file_handle "\t</".$ns.":".$prot_space.">\n";
			$prot_duplicated{$assoc{OBJ_ID}} = 1;
		}
		
		my $triple_prefix_id_assoc_id = $goa_ns."triple_".$prefix_id."_".$assoc{ASSC_ID};
		my $goa_ns_prefix_id_assoc_id = $goa_ns."GOA_".$prefix_id."_".$assoc{ASSC_ID};
		#
		# ASSOC:
		#
		print $file_handle "\t<",$ns,":".$rdf_subnamespace." rdf:about=\"".$goa_ns_prefix_id_assoc_id."\">\n";
		print $file_handle "\t\t<".$ns.":date>".$assoc{DATE}."</".$ns.":date>\n";
		print $file_handle "\t\t<".$ns.":refer>".&char_hex_http($assoc{REFER})."</".$ns.":refer>\n";
		print $file_handle "\t\t<".$ns.":sup_ref>".&char_hex_http($assoc{SUP_REF})."</".$ns.":sup_ref>\n";
		print $file_handle "\t\t<obo:has_evidence rdf:resource=\"".$obo_ns.$evidence_code_by_id{$assoc{"EVID_CODE"}}."\"/>\n";
		print $file_handle "\t</".$ns.":".$rdf_subnamespace.">\n";
		
		#
		# TRIPLE:
		#
		print $file_handle "\t<rdf:Statement rdf:about=\"".$triple_prefix_id_assoc_id."\">\n";
		print $file_handle "\t\t<rdf:subject rdf:resource=\"".$uniprot_ns.$assoc{OBJ_ID}."\"/>\n";
		print $file_handle "\t\t<rdf:predicate rdf:resource=\"".$obo_ns.$aspect{$assoc{ASPECT}}."\"/>\n";
		print $file_handle "\t\t<rdf:object rdf:resource=\"".$obo_ns.&char_hex_http($assoc{"GO_ID"})."\"/>\n\n";

		print $file_handle "\t\t<goa:supported_by rdf:resource=\"".$goa_ns_prefix_id_assoc_id."\"/>\n";
		print $file_handle "\t</rdf:Statement>\n";
	}

	print $file_handle "</rdf:RDF>\n\n";
	print $file_handle "<!--\nGenerated with ONTO-PERL: ".$0.", ".__date()."\n-->";

	return $file_handle;
}

sub __date {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $result = sprintf "%02d:%02d:%4d %02d:%02d", $mday,$mon+1,$year+1900,$hour,$min; # e.g. 11:05:2008 12:52
}

=head2 char_hex_http

  Usage    - $ontology->char_hex_http($seq)
  Returns  - the sequence with the hexadecimal representation for the http special characters
  Args     - the sequence of characters
  Function - Transforms a http character to its equivalent one in hexadecimal. E.g. : -> %3A
  
=cut


sub char_hex_http { 
	$_[0] =~ s/:/_/g; # originally:  $_[0] =~ s/:/%3A/g; but changed to get eh GO IDs properly: GO_0000001
	$_[0] =~ s/;/%3B/g;
	$_[0] =~ s/</%3C/g;
	$_[0] =~ s/=/%3D/g;
	$_[0] =~ s/>/%3E/g;
	$_[0] =~ s/\?/%3F/g;
	
#number sign                    #     23   &#035; --> #   &num;      --> &num;
#dollar sign                    $     24   &#036; --> $   &dollar;   --> &dollar;
#percent sign                   %     25   &#037; --> %   &percnt;   --> &percnt;

	$_[0] =~ s/\//%2F/g;
	$_[0] =~ s/&/%26/g;

	return $_[0];
}
1;
