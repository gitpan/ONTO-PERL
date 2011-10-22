package OBO::APO::NCBIToRDF; 

=head1 NAME

OBO::APO::NCBIToRDF - A NCBI taxonomy dump to RDF converter.

=head1 DESCRIPTION

Converts NCBI taxonomy dump files (names and nodes) to a RDF graph. 

NCBI taxonomy dump files files can be obtained from ftp://ftp.ncbi.nih.gov/pub/taxonomy/

The method 'work' gets the nodes file, the names file, and file handler for the RDF graph. 

=head1 AUTHOR

Mikel Egana Aranguren
mikel.egana.aranguren@gmail.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

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

  Usage    - $NCBIToRDF->work($NCBINodesFilePath,$NCBINamesFilePath,$RDF_file_handler)
  Returns  - RDF file handler
  Args     - The paths to the NCBI nodes and names files and a file handler for the new RDF file
  Function - Converts NCBI nodes and NCBI names to an RDF graph.
  
=cut

sub work {
	my $self = shift;

	# Get the arguments
	my ($NCBInodesFileName,$NCBInamesFileName,$file_handle) = @_;
	
	# For the ID
# 	$path_to_assoc_file =~ /.*\/(.*)/; # get what is after the slash in the path...
# 	my $f_name = $1;
# 	(my $prefix_id = $f_name) =~ s/\.goa//;
# 	$prefix_id =~ s/\./_/g;

	# TODO Set all the NS and URI via arguments
	my $default_URL = "http://www.semantic-systems-biology.org/ontology/rdf/"; 

	my $NS = "NCBI";
	my $ns = lc ($NS);
	my $rdf_subnamespace = "taxon";
	
	my $obo_ns     = $default_URL."OBO#";
	my $ncbi_ns    = $default_URL."NCBI#";

	# Preamble of RDF file
	print $file_handle "<?xml version=\"1.0\"?>\n";
	print $file_handle "<rdf:RDF\n";
	print $file_handle "\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n";
	print $file_handle "\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n";
	print $file_handle "\txmlns:".$ns."=\"".$ncbi_ns."\"\n";
	print $file_handle "\txmlns:obo=\"".$obo_ns."\">\n";

	my %nodes = ();
	my %names = ();

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
			print $file_handle "\t<",$ns,":".$rdf_subnamespace." rdf:about=\"#"."NCBI"."_".$child."\">\n";
			print $file_handle "\t\t<rdfs:label xml:lang=\"en\">".&char_hex_http($names{$child})."</rdfs:label>\n";
			
			unless ($child eq "1"){
				print $file_handle "\t\t<obo:is_a rdf:resource=\"#"."NCBI"."_".$parent."\"/>\n";
			}

			print $file_handle "\t</",$ns,":".$rdf_subnamespace.">\n";
		}
	}
	close(NCBInodesFile);

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
	$_[0] =~ s/:/%3A/g;
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
