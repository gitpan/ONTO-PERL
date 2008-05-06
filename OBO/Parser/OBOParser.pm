# $Id: OBOParser.pm 2054 2008-04-27 14:17:31Z Erick Antezana $
#
# Module  : OBOParser.pm
# Purpose : Parse OBO files.
# License : Copyright (c) 2006, 2007, 2008 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package OBO::Parser::OBOParser;

=head1 NAME

OBO::Parser::OBOParser  - An OBO (Open Biomedical Ontologies) file parser.
    
=head1 SYNOPSIS

use OBO::Parser::OBOParser;

use strict;

my $my_parser = OBO::Parser::OBOParser->new;

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

Copyright (C) 2006, 2007, 2008 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use OBO::Core::Term;
use OBO::Core::Ontology;
use OBO::Core::Dbxref;
use OBO::Core::Relationship;
use OBO::Core::RelationshipType;
use OBO::Core::SynonymTypeDef;
use OBO::Util::Set;
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
	my $result = OBO::Core::Ontology->new();
	
	open (OBO_FILE, $self->{OBO_FILE}) || confess "The OBO file cannot be opened: ", $!;
	$/ = "\n\n";
	chomp(my @chunks = <OBO_FILE>);
	chomp(@chunks);
	close OBO_FILE;
	
	my $file_line_number = 0;
	
	# treat OBO file header tags
	if (defined $chunks[0] && $chunks[0] =~ /^format-version:\s*(.*)/) {
		my @header = split (/\n/,$chunks[0]);
		$file_line_number = $#header + 2; # amount of lines in the header
		my $format_version = $1 if ($chunks[0] =~ /format-version:\s*(.*)\n/); # required tag
		my $data_version = $1 if ($chunks[0] =~ /data-version:\s*(.*)\n/);
		my $date = $1 if ($chunks[0] =~ /date:\s*(.*)\n/);
		my $saved_by = $1 if ($chunks[0] =~ /saved-by:\s*(.*)\n/);
		my $auto_generated_by = $1 if ($chunks[0] =~ /auto-generated-by:\s*(.*\n)/);
		my $imports = OBO::Util::Set->new();
		while ($chunks[0] =~ /(import:\s*(.*)\n)/) {
			$imports->add($2);
			$chunks[0] =~ s/$1//;
		}
		my $subsetdef = OBO::Util::Set->new();
		while ($chunks[0] =~ /(subsetdef:\s*(.*)\n)/) {
			$subsetdef->add($2);
			$chunks[0] =~ s/$1//;
		}
		my $synonym_type_def_set = OBO::Util::SynonymTypeDefSet->new();
		while ($chunks[0] =~ /(synonymtypedef:\s*(.*)\s+\"(.*)\"(.*)?)/) {
			my $line = $1;
			my $std = OBO::Core::SynonymTypeDef->new();
			$std->synonym_type_name($2);
			$std->description($3);
			my $sc = $4;
			$std->scope($sc) if (defined $sc && $sc =~s/\s//);
			$synonym_type_def_set->add($std);
			$chunks[0] =~ s/$line//;
		}
		my $idspace = $1 if ($chunks[0] =~ /idspace:\s*(.*)\n/);
		my $default_namespace = $1 if ($chunks[0] =~ /default-namespace:\s*(.*)\n/);
		my $remark = $1 if ($chunks[0] =~ /remark:\s*(.*)/);
	
		croak "The OBO file '", $self->{OBO_FILE},"' does not have a correct header, please verify it." if (!defined $format_version);
		
		$result->imports($imports->get_set());
		$result->subsets($subsetdef->get_set());
		$result->synonym_type_def_set($synonym_type_def_set->get_set());
		my $local_idspace = $1, my $uri = $2, my $desc = $4 if ($idspace && $idspace =~ /(\S+)\s+(\S+)\s+(\"(.*)\")?/);
		$result->idspace_as_string($local_idspace, $uri, $desc) if (defined $local_idspace && defined $uri);
		$result->data_version($data_version) if ($data_version);
		$result->date($date) if ($date);
		$result->saved_by($saved_by) if ($saved_by);
		#$result->auto_generated_by($auto_generated_by) if ($auto_generated_by);
		$result->default_namespace($default_namespace) if ($default_namespace);
		$result->remark($remark) if ($remark);
		
		foreach my $chunk (@chunks) {
			my @entry = split (/\n/, $chunk);
			my $stanza = shift @entry;
					
			if ($stanza && $stanza =~ /\[Term\]/) { # treat [Term]
				my $term;
				$file_line_number++;
				my $only_one_id_tag_per_entry   = 0;
				my $only_one_name_tag_per_entry = 0;
				foreach my $line (@entry) {
					$file_line_number++;
					if ($line =~ /^id:\s*(\w+:\w+)/) { # get the term id
						croak "The term with id '", $1, "' has a duplicated 'id' tag in the file '", $self->{OBO_FILE} if ($only_one_id_tag_per_entry);
						$term = $result->get_term_by_id($1); # does this term is already in the ontology?
						if (!defined $term){
							$term = OBO::Core::Term->new();  # if not, create a new term
							$term->id($1);
							$result->add_term($term);        # add it to the ontology
							$only_one_id_tag_per_entry = 1;
						} elsif (defined $term->def()->text() && $term->def()->text() ne "") {
							# The term is already in the ontology since it has a definition! (maybe empty?)
							croak "The term with id '", $1, "' is duplicated in the OBO file.";
						}
					} elsif ($line =~ /^name:\s*(.*)/) {
						croak "The term with id '", $1, "' has a duplicated 'name' tag in the file '", $self->{OBO_FILE} if ($only_one_name_tag_per_entry);
						if (!defined $1) {
							croak "The term with id '", $term->id(), "' has no name in file '", $self->{OBO_FILE}, "'";
						} else {
							$term->name($1);
							$only_one_name_tag_per_entry = 1;
						}
					} elsif ($line =~ /^namespace:\s*(.*)/) {
						$term->namespace($1); # it is a Set
					} elsif ($line =~ /^is_anonymous:\s*(.*)/) {
						$term->is_anonymous(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^alt_id:\s*(\w+:\w+)/) {
						$term->alt_id($1);
					} elsif ($line =~ /^def:\s*\"(.*)\"\s*(\[.*\])/) { # fill the definition
						my $def = OBO::Core::Def->new();
						$def->text($1);
						$def->dbxref_set_as_string($2);
						$term->def($def);
					} elsif ($line =~ /^comment:\s*(.*)/) {
						$term->comment($1);
					} elsif ($line =~ /^subset:\s*(.*)/) {
						# TODO wait until the OBO spec 1.3 is there, then check that the used subsets belong to the defined in the header
						$term->subset($1);
					} elsif ($line =~ /^(exact|narrow|broad|related)_synonym:\s*\"(.*)\"\s+(\[.*\])\s*/) { # OBO spec 1.1
						$term->synonym_as_string($2, $3, uc($1));
					} elsif ($line =~ /^synonym:\s*\"(.*)\"(\s+(EXACT|BROAD|NARROW|RELATED))?(\s+([-\w]+))?\s+(\[.*\])\s*/) {
						my $scope = (defined $3)?$3:"RELATED";
						# OBO flat file spec: v1.2
						# synonym: "endomitosis" EXACT []
						if (defined $5) {
							my $found = 0; # check that the 'synonym type name' was defined in the header!
							foreach my $st ($result->synonym_type_def_set()->get_set()) {
								# Adapt the scope if necessary to the one defined in the header!
								$found = 1, $scope = $st->scope(), last if ($st->synonym_type_name() eq $5);
							}
							croak "The synonym type name (", $5,") used in line ",  $file_line_number, " in the file '", $self->{OBO_FILE}, "' was not defined" if (!$found);
						}
						$term->synonym_as_string($1, $6, $scope, $5);
					} elsif ($line =~ /^xref:\s*(.*)/ || $line =~ /^xref_analog:\s*(.*)/ || $line =~ /^xref_unknown:\s*(.*)/) {
						$term->xref_set_as_string($1);
					} elsif ($line =~ /^is_a:\s*(\w+:\w+)\s*(\!\s*(.*))?/) { # The comment is ignored here but retrieved later internally
						my $rel = OBO::Core::Relationship->new();
						$rel->id($term->id()."_"."is_a"."_".$1);
						$rel->type("is_a");
						my $target = $result->get_term_by_id($1); # does this term is already in the ontology?
						if (!defined $target) {
							$target = OBO::Core::Term->new(); # if not, create a new term
							$target->id($1);
							$result->add_term($target);
						}
						$rel->link($term, $target);
						$result->add_relationship($rel);
					} elsif ($line =~ /^intersection_of:\s*(.*)/) {
						# TODO wait until the OBO spec 1.3 is there
					} elsif ($line =~ /^union_of:\s*(.*)/) {
						# TODO wait until the OBO spec 1.3 is there
						# Distinguish between terms and relations?
						# Check there are at least 2 elements in the 'union_of' set
						$term->union_of($1);
					} elsif ($line =~ /^disjoint_from:\s*(\w+:\w+)\s*(\!\s*(.*))?/) {
						$term->disjoint_from($1); # We are assuming that the other term exists or will exist; otherwise , we have to create it like in the is_a section.
					} elsif ($line =~ /^relationship:\s*([\w\/]+)\s*(\w+:\w+)\s*(\!\s*(.*))?/) {
						my $rel = OBO::Core::Relationship->new();
						my $id = $term->id()."_".$1."_".$2; 
						$id =~ s/\s+/_/g;
						$rel->id($id);
						$rel->type($1);
						my $target = $result->get_term_by_id($2); # does this term is already in the ontology?
						if (!defined $target) {
							$target = OBO::Core::Term->new(); # if not, create a new term
							$target->id($2);
							$result->add_term($target);
						}
						$rel->link($term, $target);
						$result->add_relationship($rel);
					} elsif ($line =~ /^is_obsolete:\s*(.*)/) {
						$term->is_obsolete(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^replaced_by:\s*(.*)/) {
						$term->replaced_by($1);
					} elsif ($line =~ /^consider:\s*(.*)/) {
						$term->consider($1);
					} elsif ($line =~ /^builtin:\s*(.*)/) {
						$term->builtin(($1 eq "true")?1:0);
					} elsif ($line =~ /^property_value:\s*(.*)/) {
						# do nothing for the moment...TODO: implement this once the OBO spec is more mature...
					} elsif ($line =~ /^!/) {
						# skip line
					} else {					
						warn "A format problem has been detected (and ignored) in: '", $line, "' in the line: ", $file_line_number, " in the file: ", $self->{OBO_FILE};
					}
				}
				# Check for required fields: id and name
				if (defined $term && !defined $term->id()) {
					croak "There is no id for the term:\n", $chunk;
				} elsif (!defined $term->name()) {
					croak "The term with id '", $term->id(), "' has no name in the entry:\n\n", $chunk, "\n\nfrom file '", $self->{OBO_FILE}, "'";
				}
				$file_line_number ++;				
			} elsif ($stanza && $stanza =~ /\[Typedef\]/) { # treat [Typedef]
				my $type;
				my $only_one_name_tag_per_entry = 0;
				foreach my $line (@entry) {
					if ($line =~ /^id:\s*(.*)/) { # get the type id
						$type = $result->get_relationship_type_by_id($1); # does this relationship type is already in the ontology?
						if (!defined $type){
							$type = OBO::Core::RelationshipType->new();  # if not, create a new type
							$type->id($1);
							$result->add_relationship_type($type);        # add it to the ontology
						} elsif (defined $type->def()->text() && $type->def()->text() ne "") {
							# the type is already in the ontology since it has a definition! (maybe empty?)
							croak "The relationship type with id '", $1, "' is duplicated in the OBO file.";
						}
					} elsif ($line =~ /^name:\s*(.*)/) {
						croak "The typedef with id '", $1, "' has a duplicated 'name' tag in the file '", $self->{OBO_FILE} if ($only_one_name_tag_per_entry);
						$type->name($1);
						$only_one_name_tag_per_entry = 1;
					} elsif ($line =~ /^namespace:\s*(.*)/) {
						$type->namespace($1); # it is a Set
					} elsif ($line =~ /^alt_id:\s*(\w+)/) {
						$type->alt_id($1);
					} elsif ($line =~ /^def:\s*\"(.*)\"\s*(\[.*\])/) { # fill the definition
						my $def = OBO::Core::Def->new();
						$def->text($1);
						$def->dbxref_set_as_string($2);
						$type->def($def);
					} elsif ($line =~ /^comment:\s*(.*)/) {
						$type->comment($1);
					} elsif ($line =~ /^subset:\s*(.*)/) {
						# TODO wait until the OBO spec 1.3 is there, then check that the used subsets belong to the defined in the header
						$type->subset($1);
					} elsif ($line =~ /^domain:\s*(.*)/) {
						$type->domain($1);
					} elsif ($line =~ /^range:\s*(.*)/) {
						$type->range($1);
					} elsif ($line =~ /^is_anti_symmetric:\s*(.*)/) {
						$type->is_anti_symmetric(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^is_cyclic:\s*(.*)/) {
						$type->is_cyclic(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^is_reflexive:\s*(.*)/) {
						$type->is_reflexive(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^is_symmetric:\s*(.*)/) {
						$type->is_symmetric(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^is_transitive:\s*(.*)/) {
						$type->is_transitive(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^is_metadata_tag:\s*(.*)/) {
						$type->is_metadata_tag(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^(exact|narrow|broad|related)_synonym:\s*\"(.*)\"\s+(\[.*\])\s*/) {
						$type->synonym_as_string($2, $3, uc($1));
					} elsif ($line =~ /^synonym:\s*\"(.*)\"(\s+(EXACT|BROAD|NARROW|RELATED))?(\s+(\w+))?\s+(\[.*\])\s*/) {
						my $scope = (defined $3)?$3:"RELATED";
						# OBO flat file spec: v1.2
						# synonym: "endomitosis" EXACT []
						if (defined $5) {
							my $found = 0; # check that the 'synonym type name' was defined in the header!
							foreach my $st ($result->synonym_type_def_set()->get_set()) {
								# Adapt the scope if necessary to the one defined in the header!
								$found = 1, $scope = $st->scope(), last if ($st->synonym_type_name() eq $5);
							}
							croak "The synonym type name (", $5,") used in line ",  $file_line_number, " in the file '", $self->{OBO_FILE}, "' was not defined" if (!$found);
						}
						$type->synonym_as_string($1, $6, $scope, $5);
					} elsif ($line =~ /^xref:\s*(.*)/ || $line =~ /^xref_analog:\s*(.*)/ || $line =~ /^xref_unk:\s*(.*)/) {
						$type->xref_set_as_string($1);
					} elsif ($line =~ /^is_a:\s*(\w+)\s*(\!\s*(.*))?/) { # intrinsic or not??? # The comment is ignored here but retrieved later internally
						my $rel = OBO::Core::Relationship->new();
						$rel->id($type->id()."_"."is_a"."_".$1);
						$rel->type("is_a");
						my $target = $result->get_relationship_type_by_id($1); # does this relationship type is already in the ontology?
						if (!defined $target) {
							$target = OBO::Core::RelationshipType->new(); # if not, create a new relationship type
							$target->id($1);
							$result->add_relationship_type($target);
						}
						$rel->link($type, $target); # add a relationship between two relationship types
						$result->add_relationship($rel);
					} elsif ($line =~ /^inverse_of:\s*(.*)/) {
						# TODO wait until the OBO spec 1.3 is there, then implement it in RelationshipType
						#$type->inverse_of($1);
					} elsif ($line =~ /^transitive_over:\s*(.*)/) {
						$type->transitive_over($1);
					} elsif ($line =~ /^is_obsolete:\s*(.*)/) {
						$type->is_obsolete(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^replaced_by:\s*(.*)/) {
						$type->replaced_by($1);
					} elsif ($line =~ /^consider:\s*(.*)/) {
						$type->consider($1);
					} elsif ($line =~ /^builtin:\s*(.*)/) {
						$type->builtin(($1 eq "true")?1:0);
					} elsif ($line =~ /^!/) {
						# skip line
					} else {
						warn "A format problem has been detected (and ignored) in: ", $line, "\n\nfrom file '", $self->{OBO_FILE}, "'";
					}	
				}
				# Check for required fields: id and name
				if (!defined $type->id()) {
					croak "There is no id for the type:\n\n", $chunk, "\n\nfrom file '", $self->{OBO_FILE}, "'";
				} elsif (!defined $type->name()) {
					croak "The type with id '", $type->id(), "' has no name in file '", $self->{OBO_FILE}, "'";
				}
				$file_line_number++;
			}
		}
		
		# Workaround for some ontologies like GO: Add 'is_a' if missing
		if (!$result->has_relationship_type_id("is_a")){
			my $type = OBO::Core::RelationshipType->new();  # if not, create a new type
			$type->id("is_a");
			$type->name("is_a");
			$result->add_relationship_type($type);
		}
		
		$/ = "\n";
		
	} else { # if no header (chunk[0])
		croak "The OBO file '", $self->{OBO_FILE},"' does not have a correct header, please verify it.";
	}
	return $result;
}

1;