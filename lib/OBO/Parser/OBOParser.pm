# $Id: OBOParser.pm 2010-11-29 Erick Antezana $
#
# Module  : OBOParser.pm
# Purpose : Parse OBO files.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
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

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use strict;
use warnings;
use Carp;
#use Date::Manip::Date; # TODO Consider to use this module to manipulate dates

use OBO::Core::Term;
use OBO::Core::Ontology;
use OBO::Core::Dbxref;
use OBO::Core::Relationship;
use OBO::Core::RelationshipType;
use OBO::Core::SubsetDef;
use OBO::Core::SynonymTypeDef;
use OBO::Util::IDspaceSet;
use OBO::Util::Set;

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
		my $subset_def_set = OBO::Util::SubsetDefSet->new();
		while ($chunks[0] =~ /(subsetdef:\s*(.*)\s+\"(.*)\")/) {
			my $line = $1;
			my $ssd  = OBO::Core::SubsetDef->new();
			$ssd->name($2);
			$ssd->description($3);
			$subset_def_set->add($ssd);
			$chunks[0] =~ s/$line//;
		}
		my $synonym_type_def_set = OBO::Util::SynonymTypeDefSet->new();
		while ($chunks[0] =~ /(synonymtypedef:\s*(.*)\s+\"(.*)\"(.*)?)/) {
			my $line = $1;
			my $std  = OBO::Core::SynonymTypeDef->new();
			$std->name($2);
			$std->description($3);
			my $sc = $4;
			$std->scope($sc) if (defined $sc && $sc =~s/\s//);
			$synonym_type_def_set->add($std);
			$chunks[0] =~ s/$line//;
		}
		my $idspaces = OBO::Util::IDspaceSet->new();
		while ($chunks[0] =~ /(idspace:\s*(.*)\s*(.*)\s+(\".*\")?)/) {
			my $line        = $1;
			my $new_idspace = OBO::Core::IDspace->new();
			$new_idspace->local_idspace($2);
			$new_idspace->uri($3);
			my $dc = $4;
			$new_idspace->description($dc) if (defined $dc);
			$idspaces->add($new_idspace);
			$chunks[0] =~ s/$line//;
		}
		my $default_namespace = $1 if ($chunks[0] =~ /default-namespace:\s*(.*)(\n)?/);
		my $remarks = OBO::Util::Set->new();
		while ($chunks[0] =~ /(remark:\s*(.*)(\n)?)/) {
			my $line = $1;
			$line =~ s/\$/\\\$/g;
			$remarks->add($2);
			$chunks[0] =~ s/$line//;
		}
	
		croak "The OBO file '", $self->{OBO_FILE},"' does not have a correct header, please verify it." if (!defined $format_version);
		
		$result->data_version($data_version) if ($data_version);
		$result->date($date) if ($date);
		$result->saved_by($saved_by) if ($saved_by);
		#$result->auto_generated_by($auto_generated_by) if ($auto_generated_by);
		$result->subset_def_set($subset_def_set->get_set());
		$result->imports($imports->get_set());
		$result->synonym_type_def_set($synonym_type_def_set->get_set());
		$result->idspaces($idspaces->get_set());
		$result->default_namespace($default_namespace) if ($default_namespace);
		$result->remarks($remarks->get_set());

		foreach my $chunk (@chunks) {
			my @entry = split (/\n/, $chunk);
			my $stanza = shift @entry;
					
			if ($stanza && $stanza =~ /\[Term\]/) { # treat [Term]'s
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
					} elsif ($line =~ /^is_anonymous:\s*(.*)/) {
						$term->is_anonymous(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^name:\s*(.*)/) {
						croak "The term with id '", $1, "' has a duplicated 'name' tag in the file '", $self->{OBO_FILE} if ($only_one_name_tag_per_entry);
						if (!defined $1) {
							warn "The term with id '", $term->id(), "' has no name in file '", $self->{OBO_FILE}, "'";
						} else {
							$term->name($1);
							$only_one_name_tag_per_entry = 1;
						}
					} elsif ($line =~ /^namespace:\s*(.*)/) {
						$term->namespace($1); # it is a Set
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
						my $ss = $1;
						my $found = 0; # check that the 'synonym type name' was defined in the header!
						foreach my $ssd ($result->subset_def_set()->get_set()) {
							if ($ssd->name() eq $ss) {
								$found = 1;
								$term->subset($ss); # it is a Set (i.e. added to a Set)
								last;
							}
						}
						croak "The subset '", $ss, "' is not defined in the header!" if (!$found);
					} elsif ($line =~ /^(exact|narrow|broad|related)_synonym:\s*\"(.*)\"\s+(\[.*\])\s*/) { # OBO spec 1.1
						$term->synonym_as_string($2, $3, uc($1));
					} elsif ($line =~ /^synonym:\s*\"(.*)\"(\s+(EXACT|BROAD|NARROW|RELATED))?(\s+([-\w]+))?\s+(\[.*\])\s*/) {
						my $scope = (defined $3)?$3:"RELATED";
						# As of OBO flat file spec v1.2, we use:
						# synonym: "endomitosis" EXACT []
						if (defined $5) {
							my $found = 0; # check that the 'synonym type name' was defined in the header!
							foreach my $st ($result->synonym_type_def_set()->get_set()) {
								# Adapt the scope if necessary to the one defined in the header!
								if ($st->name() eq $5) {
									$found = 1;
									my $default_scope = $st->scope();
									$scope = $default_scope if (defined $default_scope);
									last;
								}
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
						# TODO wait until the OBO spec 1.4 be released
					} elsif ($line =~ /^union_of:\s*(.*)/) {
						# TODO wait until the OBO spec 1.4 be released
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
					} elsif ($line =~ /^created_by:\s*(.*)/) {
						$term->created_by($1);
					} elsif ($line =~ /^creation_date:\s*(.*)/) {
						$term->creation_date($1); # TODO Check that the date follows the ISO 8601 format
					} elsif ($line =~ /^modified_by:\s*(.*)/) {
						$term->modified_by($1);
					} elsif ($line =~ /^modification_date:\s*(.*)/) {
						$term->modification_date($1); # TODO Check that the date follows the ISO 8601 format
					} elsif ($line =~ /^is_obsolete:\s*(.*)/) {
						$term->is_obsolete(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^replaced_by:\s*(.*)/) {
						$term->replaced_by($1);
					} elsif ($line =~ /^consider:\s*(.*)/) {
						$term->consider($1);
					} elsif ($line =~ /^builtin:\s*(.*)/) {
						$term->builtin(($1 eq "true")?1:0);
					} elsif ($line =~ /^property_value:\s*(.*)/) {
						#  TODO implement this once the OBO spec is more mature...
					} elsif ($line =~ /^!/) {
						# skip line
					} else {					
						warn "A format problem has been detected (and ignored) in line: ", $file_line_number, " (in file '", $self->{OBO_FILE}, "'):\n\t", $line, "\n";
					}
				}
				# Check for required fields: id
				if (defined $term && !defined $term->id()) {
					croak "There is no id for the term:\n", $chunk;
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
						} else {
							# TODO Check this 'else' scenario warn "This relationship is: $line ...";
						}
					} elsif ($line =~ /^is_anonymous:\s*(.*)/) {
						$type->is_anonymous(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^name:\s*(.*)/) {
						croak "The typedef with id '", $1, "' has a duplicated 'name' tag in the file '", $self->{OBO_FILE} if ($only_one_name_tag_per_entry);
						$type->name($1);
						$only_one_name_tag_per_entry = 1;
					} elsif ($line =~ /^namespace:\s*(.*)/) {
						$type->namespace($1); # it is a Set
					} elsif ($line =~ /^alt_id:\s*([:\w]+)/) {
						$type->alt_id($1);
					} elsif ($line =~ /^def:\s*\"(.*)\"\s*(\[.*\])/) { # fill the definition
						my $def = OBO::Core::Def->new();
						$def->text($1);
						$def->dbxref_set_as_string($2);
						$type->def($def);
					} elsif ($line =~ /^comment:\s*(.*)/) {
						$type->comment($1);
					} elsif ($line =~ /^subset:\s*(.*)/) {
						# TODO wait until the OBO spec 1.4 be officialy there, then check that the used subsets belong to the defined in the header
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
					} elsif ($line =~ /^is_a:\s*([:\w]+)\s*(\!\s*(.*))?/) { # intrinsic or not??? # The comment is ignored here but retrieved later internally
						my $r = $1;
						my $rel = OBO::Core::Relationship->new();
						$rel->id($type->id()."_"."is_a"."_".$r);
						$rel->type("is_a");
						my $target = $result->get_relationship_type_by_id($r); # does this relationship type is already in the ontology?
						if (!defined $target) {
							$target = OBO::Core::RelationshipType->new(); # if not, create a new relationship type
							$target->id($r);
							$result->add_relationship_type($target);
						}
						$rel->link($type, $target); # add a relationship between two relationship types
						$result->add_relationship($rel);
					} elsif ($line =~ /^is_metadata_tag:\s*(.*)/) {
						$type->is_metadata_tag(($1 =~ /true/)?1:0);
					} elsif ($line =~ /^(exact|narrow|broad|related)_synonym:\s*\"(.*)\"\s+(\[.*\])\s*/) {
						$type->synonym_as_string($2, $3, uc($1));
					} elsif ($line =~ /^synonym:\s*\"(.*)\"(\s+(EXACT|BROAD|NARROW|RELATED))?(\s+(\w+))?\s+(\[.*\])\s*/) {
						my $scope = (defined $3)?$3:"RELATED";
						# From OBO flat file spec v1.2, we use:
						# synonym: "endomitosis" EXACT []
						if (defined $5) {
							my $found = 0; # check that the 'synonym type name' was defined in the header!
							foreach my $st ($result->synonym_type_def_set()->get_set()) {
								# Adapt the scope if necessary to the one defined in the header!
								if ($st->name() eq $5) {
									$found = 1;
									my $default_scope = $st->scope();
									$scope = $default_scope if (defined $default_scope);
									last;
								}
							}
							croak "The synonym type name (", $5,") used in line ",  $file_line_number, " in the file '", $self->{OBO_FILE}, "' was not defined" if (!$found);
						}
						$type->synonym_as_string($1, $6, $scope, $5);
					} elsif ($line =~ /^xref:\s*(.*)/ || $line =~ /^xref_analog:\s*(.*)/ || $line =~ /^xref_unk:\s*(.*)/) {
						$type->xref_set_as_string($1);
					} elsif ($line =~ /^intersection_of:\s*(.*)/) {
						# TODO wait until the OBO spec 1.4 be released
						$type->intersection_of($1);
					} elsif ($line =~ /^union_of:\s*(.*)/) {
						# TODO wait until the OBO spec 1.4 be released
						# Distinguish between terms and relations?
						# Check there are at least 2 elements in the 'union_of' set
						$type->union_of($1);
					} elsif ($line =~ /^disjoint_from:\s*([:\w]+)\s*(\!\s*(.*))?/) {
						$type->disjoint_from($1); # We are assuming that the other relation type exists or will exist; otherwise , we have to create it like in the is_a section.
					} elsif ($line =~ /^inverse_of:\s*([:\w]+)\s*(\!\s*(.*))?/) { # e.g. inverse_of: has_participant ! has participant
						my $inv_id   = $1;
						my $inv_type = $result->get_relationship_type_by_id($inv_id); # does this INVERSE relationship type is already in the ontology?
						if (!defined $inv_type){
							$inv_type = OBO::Core::RelationshipType->new();  # if not, create a new type
							$inv_type->id($inv_id);
							#$inv_type->name($3) if ($3); # not necessary, this name could be wrong...
							$result->add_relationship_type($inv_type);       # add it to the ontology
						}
						$type->inverse_of($inv_type);
					} elsif ($line =~ /^transitive_over:\s*(.*)/) {
						$type->transitive_over($1);
					} elsif ($line =~ /^holds_over_chain:\s*([:\w]+)\s*([:\w]+)\s*(\!\s*(.*))?/) { # R <- R1.R2 
						my $r1_id   = $1;
						my $r2_id   = $2;
						my $r1_type = $result->get_relationship_type_by_id($r1_id); # does this relationship type is already in the ontology?
						if (!defined $r1_type){
							$r1_type = OBO::Core::RelationshipType->new();  # if not, create a new type
							$r1_type->id($r1_id);
							$result->add_relationship_type($r1_type);       # add it to the ontology
						}
						my $r2_type = $result->get_relationship_type_by_id($r2_id); # does this relationship type is already in the ontology?
						if (!defined $r2_type){
							$r2_type = OBO::Core::RelationshipType->new();  # if not, create a new type
							$r2_type->id($r2_id);
							$result->add_relationship_type($r2_type);       # add it to the ontology
						}
						$type->holds_over_chain($r1_type->id(), $r2_type->id());
					} elsif ($line =~ /^equivalent_to_chain:\s*(.*)/) {
						# TODO
					} elsif ($line =~ /^disjoint_over:\s*(.*)/) {
						# TODO
					} elsif ($line =~ /^functional:\s*(.*)/) {
						$type->functional(($1 eq "true")?1:0);
					} elsif ($line =~ /^inverse_functional:\s*(.*)/) {
						$type->inverse_functional(($1 eq "true")?1:0);
					} elsif ($line =~ /^created_by:\s*(.*)/) {
						$type->created_by($1);
					} elsif ($line =~ /^creation_date:\s*(.*)/) {
						$type->creation_date($1); # TODO Check that the date follows the ISO 8601 format
					} elsif ($line =~ /^modified_by:\s*(.*)/) {
						$type->modified_by($1);
					} elsif ($line =~ /^modification_date:\s*(.*)/) {
						$type->modification_date($1); # TODO Check that the date follows the ISO 8601 format
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
						warn "A format problem has been detected (and ignored) in the following entry:\n\n\t", $line, "\n\nfrom file '", $self->{OBO_FILE}, "'\n";
					}	
				}
				# Check for required fields: id and name
				if (!defined $type->id()) {
					croak "There is no id for the type:\n\n", $chunk, "\n\nfrom file '", $self->{OBO_FILE}, "'";
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