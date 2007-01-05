# $Id: OBOParser.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : OBOParser.pm
# Purpose : Parse OBO files.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Parser::OBOParser;
use CCO::Core::Term;
use CCO::Core::Ontology;
use CCO::Core::Dbxref;
use CCO::Core::Relationship;
use CCO::Core::RelationshipType;
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

  Usage    - $OBOParser->work($obo_file_path)
  Returns  - the parsed OBO ontology
  Args     - the OBO file to be parsed
  Function - parses an OBO file
  
=cut
sub work {
	my $self = shift;
	$self->{OBO_FILE} = shift if (@_);
	my $result = CCO::Core::Ontology->new();
	
	#todo clean the extra newlines in the given file and separate each chunk by ONLY TWO "\n\n"
	
	open (OBO_FILE, $self->{OBO_FILE}) || croak "The OBO file cannot be opened: ", $!;
	
	# todo dos2unix
	#while (<OBO_FILE>) {
	#	s/\s//;
	#}
	#warn "\n.$chunks[$#chunks]."; # print the last chunk
	$/ = "\n\n";
	chomp(my @chunks = <OBO_FILE>);
	chomp(@chunks);
	close OBO_FILE;
	
	# treat OBO file header tags
	my @header = split (/\n/,$chunks[0]);
	my $format_version = $1 if ($chunks[0] =~ /format-version:\s*(.*)\n/); # required tag
	my $data_version = $1 if ($chunks[0] =~ /data-version:\s*(.*)\n/);
	my $date = $1 if ($chunks[0] =~ /date:\s*(.*)\n/);
	my $saved_by = $1 if ($chunks[0] =~ /saved-by:\s*(.*)\n/);
	my $auto_generated_by = $1 if ($chunks[0] =~ /auto-generated-by:\s*(.*\n)/);
	my $import = $1 if ($chunks[0] =~ /import:\s*(.*)\n/);
	my $subsetdef = $1 if ($chunks[0] =~ /subsetdef:\s*(.*)\n/);
	my $synonymtypedef = $1 if ($chunks[0] =~ /synonymtypedef:\s*(.*)\n/);
	my $default_namespace = $1 if ($chunks[0] =~ /default-namespace:\s*(.*)\n/);
	my $remark = $1 if ($chunks[0] =~ /remark:\s*(.*)/);
	
	croak "The OBO file does not have a correct header, please verify it." if (!defined $format_version);
	$result->data_version($data_version) if ($data_version);
	$result->date($date) if ($date);
	$result->saved_by($saved_by) if ($saved_by);
	#$result->auto_generated_by($auto_generated_by) if ($auto_generated_by);
	$result->namespace($default_namespace) if ($default_namespace);
	$result->remark($remark) if ($remark);
	# todo consider the rest of the header tags like 'import'
	
	foreach my $chunk (@chunks) {
		my @entry = split (/\n/, $chunk);
		my $stanza = shift @entry;
				
		if ($stanza =~ /\[Term\]/) { # treat [Term]
			my $term;
			
			foreach my $line (@entry) {
				#warn "line: ", $line;
				if ($line =~ /^id:\s*((.*):(.*))/) { # get the term id
					# todo check to have only one ID field per entry
					$term = $result->get_term_by_id($1); # does this term is already in the ontology?
					if (!defined $term){
						$term = CCO::Core::Term->new();  # if not, create a new term
						$term->id($1);
						$result->add_term($term);        # add it to the ontology
					} elsif (defined $term->def()->text() && $term->def()->text() ne "") {
						#warn "text: '", $term->def()->text(), "'";
						# the term is already in the ontology since it has a definition! (maybe empty?)
						croak "The term with id '", $1, "' is duplicated in the OBO file.";
					}
				} elsif ($line =~ /^name:\s*(.*)/) {
					# todo check to have only one NAME per entry
					if (!defined $1) {
						croak "The term with id '", $term->id(), "' has no name.";
					} else {
						$term->name($1);
					}
				} elsif ($line =~ /^namespace:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^is_anonymous:\s*(.*)/) {
					$term->is_anonymous(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^alt_id:\s*(.*)/) {
					$term->alt_id($1);
				} elsif ($line =~ /^def:\s*\"(.*)\"\s*\[(.*)\]/) { # fill the definition
					my $def = CCO::Core::Def->new();
					$def->text($1);
					# visit all the ref's
					my @refs = split(/,\s*/, $2);
					my $dbxref_set = CCO::Util::DbxrefSet->new();
					foreach my $r (@refs) {
						my $ref = CCO::Core::Dbxref->new();
						$ref->name($r); # e.g. GOC:mah
						$dbxref_set->add($ref);
					}
					$def->dbxref_set($dbxref_set);
					$term->def($def);
				} elsif ($line =~ /^comment:\s*(.*)/) {
					$term->comment($1);
				} elsif ($line =~ /^subset:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^(exact|narrow|broad|related)_synonym:\s*\"(.*)\"\s+(\[.*\])\s*/) {
					$term->synonym_as_string($2, $3, uc($1));
				} elsif ($line =~ /^synonym:\s*\"(.*)\"\s+(EXACT|BROAD|NARROW|RELATED)\s+(\[.*\])\s*/) {
					# OBO flat file spec: v1.2
					# synonym: "endomitosis" EXACT []
					$term->synonym_as_string($1, $3, $2);
				} elsif ($line =~ /^xref:\s*(.*)/ || $line =~ /^xref_analog:\s*(.*)/ || $line =~ /^xref_unk:\s*(.*)/) {
					$term->xref_set_as_string($1);
				} elsif ($line =~ /^is_a:\s*(\w+:[A-Z]?[0-9]{7})\s*(\!\s*(.*))?/) {
					my $rel = CCO::Core::Relationship->new();
					$rel->id($term->id()."_"."is_a"."_".$1);
					$rel->type("is_a");
					my $target = $result->get_term_by_id($1); # does this term is already in the ontology?
					if (!defined $target) {
						$target = CCO::Core::Term->new(); # if not, create a new term
						$target->id($1);
						$result->add_term($target);
					}
					$rel->link($term, $target);
					$result->add_relationship($rel);
				} elsif ($line =~ /^intersection_of:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^union_of:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^disjoint_from:\s*(\w+:[A-Z]?[0-9]{7})\s*(\!\s*(.*))?/) {
					$term->disjoint_from($1);
				} elsif ($line =~ /^relationship:\s*(\w+)\s*(\w+:[A-Z]?[0-9]{7})\s*(\!\s*(.*))?/) {
					my $rel = CCO::Core::Relationship->new();
					$rel->id($term->id()."_".$1."_".$2);
					$rel->type($1);
					my $target = $result->get_term_by_id($2); # does this term is already in the ontology?
					if (!defined $target) {
						$target = CCO::Core::Term->new(); # if not, create a new term
						$target->id($2);
						$result->add_term($target);
					}
					$rel->link($term, $target);
					$result->add_relationship($rel);
				} elsif ($line =~ /^is_obsolete:\s*(.*)/) {
					$term->is_obsolete(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^replaced_by:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^consider:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^builtin:\s*(.*)/) {
					$term->builtin(($1 eq "true")?1:0);
				} else {
					# todo unrecognized token
					warn "A format problem has been detected in: ", $line;
				}
			}
			# Check for required fields: id and name
			if (!defined $term->id()) {
				# todo create a test for getting this croak
				croak "There is no id for the term:", @entry;
			} elsif (!defined $term->name()) {
				croak "The term with id '", $term->id(), "' has no name.";
			}				
		} elsif ($stanza =~ /\[Typedef\]/) { # treat [Typedef]
			my $type;
			foreach my $line (@entry) {
				if ($line =~ /^id:\s*(.*)/) { # get the type id
					$type = $result->get_relationship_type_by_id($1); # does this relationship type is already in the ontology?
					if (!defined $type){
						$type = CCO::Core::RelationshipType->new();  # if not, create a new type
						$type->id($1);
						$result->add_relationship_type($type);        # add it to the ontology
					} elsif (defined $type->def()->text() && $type->def()->text() ne "") {
						# the type is already in the ontology since it has a definition! (maybe empty?)
						croak "The relationship type with id '", $1, "' is duplicated in the OBO file.";
					}
				} elsif ($line =~ /^name:\s*(.*)/) {
					# todo check to have only one NAME per entry
					$type->name($1);
				} elsif ($line =~ /^def:\s*\"(.*)\"\s*\[(.*)\]/) { # fill the definition
					my $def = CCO::Core::Def->new();
					$def->text($1);
					# visit all the ref's
					my @refs = split(/,\s*/, $2);
					my $dbxref_set = CCO::Util::DbxrefSet->new();
					foreach my $r (@refs) {
						my $ref = CCO::Core::Dbxref->new();
						$ref->name($r); # e.g. GOC:mah
						$dbxref_set->add($ref);
					}
					$def->dbxref_set($dbxref_set);
					$type->def($def);
				} elsif ($line =~ /^comment:\s*(.*)/) {
					$type->comment($1);
				} elsif ($line =~ /^domain:\s*(.*)/) {
					$type->domain($1);
				} elsif ($line =~ /^range:\s*(.*)/) {
					$type->range($1);
				} elsif ($line =~ /^inverse_of:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^transitive_over:\s*(.*)/) {
					# todo
				} elsif ($line =~ /^is_cyclic:\s*(.*)/) {
					$type->is_cyclic(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^is_reflexive:\s*(.*)/) {
					$type->is_reflexive(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^is_symmetric:\s*(.*)/) {
					$type->is_symmetric(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^is_anti_symmetric:\s*(.*)/) {
					$type->is_anti_symmetric(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^is_transitive:\s*(.*)/) {
					$type->is_transitive(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^is_metadata_tag:\s*(.*)/) {
					$type->is_metadata_tag(($1 =~ /true/)?1:0);
				} elsif ($line =~ /^(exact|narrow|broad|related)_synonym:\s*\"(.*)\"\s+(\[.*\])\s*/) {
					$type->synonym_as_string($2, $3, uc($1));
				} elsif ($line =~ /^synonym:\s*\"(.*)\"\s+(EXACT|BROAD|NARROW|RELATED)\s+(\[.*\])\s*/) {
					# OBO flat file spec: v1.2
					# synonym: "endomitosis" EXACT []
					$type->synonym_as_string($1, $3, $2);
				} elsif ($line =~ /^xref:\s*(.*)/ || $line =~ /^xref_analog:\s*(.*)/ || $line =~ /^xref_unk:\s*(.*)/) {
					$type->xref_set_as_string($1);
				} elsif ($line =~ /^is_a:\s*((\w+:[A-Z]?[0-9]{7})\s*(\!\s*(.*))?|([\w_]+))/) { # intrinsic or not???
					my $rel = CCO::Core::Relationship->new();
					$rel->id($type->id()."_"."is_a"."_".$1);
					$rel->type("is_a");
					my $target = $result->get_relationship_type_by_id($1); # does this relationship type is already in the ontology?
					if (!defined $target) {
						$target = CCO::Core::RelationshipType->new(); # if not, create a new relationship type
						$target->id($1);
						$result->add_relationship_type($target);
					}
					$rel->link($type, $target); # add a relationship between two relationship types
					$result->add_relationship($rel); 
				} elsif ($line =~ /^builtin:\s*(.*)/) {
					$type->builtin(($1 eq "true")?1:0);
				} else {
					# todo unrecognized token
					warn "A format problem has been detected in: ", $line;
				}	
			}
			# Check for required fields: id and name
			if (!defined $type->id()) {
				# todo create a test for getting this croak
				croak "There is no id for the type:", @entry;
			} elsif (!defined $type->name()) {
				croak "The type with id '", $type->id(), "' has no name.";
			}
		}
	}
	
	# Workaround for some ontologies like GO: Add 'is_a' if missing
	# todo Add an attribute: 'invisible/builtin' so that it is not printed while exporting
	if (!defined $result->get_relationship_type_by_id("is_a")) {
		my $type = CCO::Core::RelationshipType->new();  # if not, create a new type
		$type->id("is_a");
		$type->name("is_a");
		$result->add_relationship_type($type);
	}
	
	$/ = "\n";
	return $result;
}

1;

=head1 NAME
    CCO::Parser::OBOParser  - An OBO parser.
=head1 SYNOPSIS

use CCO::Parser::OBOParser;
use strict;

my $my_parser = CCO::Parser::OBOParser->new;

my $ontology = $my_parser->work("cco.obo");

$ontology->has_term($ontology->get_term_by_id("CCO:B9999993"));
$ontology->has_term($ontology->get_term_by_name("small molecule"));
$ontology->get_relationship_by_id("CCO:B9999998_is_a_CCO:B0000000")->type() eq "is_a";
$ontology->get_relationship_by_id("CCO:B9999996_part_of_CCO:B9999992")->type() eq "part_of"; 

my $ontology2 = $my_parser->work("cco.obo");

$ontology2->has_term($ontology2->get_term_by_id("CCO:B9999993"));
$ontology2->has_term($ontology2->get_term_by_name("cell cycle"));
$ontology2->get_relationship_by_id("CCO:P0000274_is_a_CCO:P0000262")->type() eq "is_a";
$ontology2->get_relationship_by_id("CCO:P0000274_part_of_CCO:P0000271")->type() eq "part_of"; 

=head1 DESCRIPTION
An OBOParser object works on parsing an OBO file.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
   