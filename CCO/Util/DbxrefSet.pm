# $Id: DbxrefSet.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : DbxrefSet.pm
# Purpose : Reference structure set.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Util::DbxrefSet;
our @ISA = qw(CCO::Util::Set);
use CCO::Util::Set;
use strict;
use warnings;
use Carp;




=head2 add

  Usage    - $set->add($dbxref)
  Returns  - true if the element was successfully added
  Args     - the element (CCO::Core::Dbxref) to be added
  Function - adds an element to this set
  
=cut
sub add {
	my $self = shift;
	my $result = 0; # nothing added
	if (@_) {	
		my $ele = shift;
		croak "The element to be added must be a CCO::Core::Dbxref object" if (!UNIVERSAL::isa($ele, 'CCO::Core::Dbxref'));
		if ( !$self -> contains($ele) ) {
			push @{$self->{SET}}, $ele;
			$result = 1; # successfully added
		}
	}
	return $result;
}

=head2 remove

  Usage    - $set->remove($element)
  Returns  - the removed element (CCO::Core::Dbxref)
  Args     - the element to be removed (CCO::Core::Dbxref)
  Function - removes an element from this set
  
=cut
sub remove {
	my $self = shift;
	my $result = undef;
	if (@_) {	
		my $ele = shift;
		croak "The element to be removed must be a CCO::Core::Dbxref object" if (!UNIVERSAL::isa($ele, 'CCO::Core::Dbxref'));
		if ($self->size() > 0) {
			for (my $i = 0; $i < scalar(@{$self->{SET}}); $i++){
				my $e = ${$self->{SET}}[$i];
				if ($ele->equals($e)) {
					if ($self->size() > 1) {
						my $first_elem = shift (@{$self->{SET}});
						${$self->{SET}}[$i-1] = $first_elem;
					} elsif ($self->size() == 1) {
						shift (@{$self->{SET}});
					}
					$result = $ele;
					last;
				}
			}
		}
	}
	return $result;
}



=head2 contains

  Usage    - $set->contains($dbxref)
  Returns  - either 1(true) or 0 (false)
  Args     - the element (CCO::Core::Dbxref) to be checked
  Function - checks if this set constains the given element
  
=cut
sub contains {
	my $self = shift;
	my $result = 0;
	if (@_){
		my $target = shift;
		
		croak "The element to be tested must be a CCO::Core::Dbxref object" if (!UNIVERSAL::isa($target, 'CCO::Core::Dbxref'));
		
		foreach my $ele (@{$self->{SET}}){
			if ($target->equals($ele)) {
				$result = 1;
				last;
			}
		} 
	}
	return $result;
}


=head2 equals

  Usage    - $set->equals($another_dbxref_set)
  Returns  - either 1 (true) or 0 (false)
  Args     - the set (CCO::Util::DbxrefSet) to compare with
  Function - tells whether this set is equal to the given one
  
=cut
sub equals {
	my $self = shift;
	my $result = 0; # I guess they'are NOT identical
	
	if (@_) {
		my $other_set = shift;
		croak "The element to be tested must be a CCO::Util::DbxrefSet object" if (!UNIVERSAL::isa($other_set, 'CCO::Util::DbxrefSet'));
		
		my %count = ();
		
		my @this = @{$self->{SET}};
		my @that = $other_set->get_set();

		if ($#this == $#that) {
			if ($#this != -1) {
				foreach (@this, @that) {
					$count{$_->name().$_->description().$_->modifier()}++;
				}
				foreach my $count (values %count) {
					if ($count != 2) {
						$result = 0;
						last;
					} else {
						$result = 1;
					}
				}
			} else {
				$result = 1; # they are equal: empty arrays
			}
		}
	}
	return $result;
}

1;

=head1 NAME
    CCO::Util::DbxrefSet  - a DbxrefSet implementation
=head1 SYNOPSIS

use CCO::Util::DbxrefSet;
use CCO::Core::Dbxref;
use strict;

my $my_set = CCO::Util::DbxrefSet->new;

# three new dbxref's
my $ref1 = CCO::Core::Dbxref->new;
my $ref2 = CCO::Core::Dbxref->new;
my $ref3 = CCO::Core::Dbxref->new;

$ref1->name("CCO:vm");
$ref2->name("CCO:ls");
$ref3->name("CCO:ea");

# remove from my_set
$my_set->remove($ref1);
$my_set->add($ref1);
$my_set->remove($ref1);

### set versions ###
$my_set->add($ref1);
$my_set->add($ref2);
$my_set->add($ref3);

my $ref4 = CCO::Core::Dbxref->new;
my $ref5 = CCO::Core::Dbxref->new;
my $ref6 = CCO::Core::Dbxref->new;

$ref4->name("CCO:ef");
$ref5->name("CCO:sz");
$ref6->name("CCO:qa");

$my_set->add_all($ref4, $ref5, $ref6);

$my_set->add_all($ref4, $ref5, $ref6);

# remove from my_set
$my_set->remove($ref4);

my $ref7 = $ref4;
my $ref8 = $ref5;
my $ref9 = $ref6;

my $my_set2 = CCO::Util::DbxrefSet->new;

$my_set->add_all($ref4, $ref5, $ref6);
$my_set2->add_all($ref7, $ref8, $ref9, $ref1, $ref2, $ref3);

$my_set2->clear();

=head1 DESCRIPTION
A set of dbxref elements.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut    