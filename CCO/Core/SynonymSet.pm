# $Id: SynonymSet.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : SynonymSet.pm
# Purpose : Synonym set.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::SynonymSet;
use strict;
use warnings;
use Carp;

sub new {
        my $class                   = shift;
        my $self                    = {};
        
        # todo pensar en usar un mapa para acceder rapidamente a los elementos en remove por ej.
        $self->{SET}	                = (); # the set
        
        bless ($self, $class);
        return $self;
}


=head2 add

  Usage    - $set->add()
  Returns  - true if the element was successfully added
  Args     - the element to be added
  Function - adds an element to this set
  
=cut
sub add {
	my $self = shift;
	my $result = 0; # nothing added
	if (@_) {	
		my $ele = shift;
		croak "The element to be added must be a CCO::Core::Synonym object" if (!UNIVERSAL::isa($ele, 'CCO::Core::Synonym'));
		if ( !$self -> contains($ele) ) {
			push @{$self->{SET}}, $ele;
			$result = 1; # successfully added
		}
	}
	return $result;
}

=head2 remove

  Usage    - $set->remove($element)
  Returns  - the removed element
  Args     - the element to be removed
  Function - removes an element from this set
  
=cut
sub remove {
	my $self = shift;
	my $result = undef;
	if (@_) {	
		my $ele = shift;
		croak "The element to be removed must be a CCO::Core::Synonym object" if (!UNIVERSAL::isa($ele, 'CCO::Core::Synonym'));
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

=head2 add_all

  Usage    - $set->add_all()
  Returns  - true if the elements were successfully added
  Args     - the elements to be added
  Function - adds the given elements to this set
  
=cut
sub add_all {
	my $self = shift;
	my $result = 1; # nothing added
	foreach (@_) {
		$result *= $self->add ($_);
	}
	return $result;
}

=head2 get_set

  Usage    - $set->get_set()
  Returns  - this set
  Args     - none
  Function - returns this set
  
=cut
sub get_set {
	my $self = shift;
	return (!$self->is_empty())?@{$self->{SET}}:();
}

=head2 contains

  Usage    - $set->contains()
  Returns  - true if this set contains the given element
  Args     - the element to be checked
  Function - checks if this set constains the given element
  
=cut
sub contains {
	my $self = shift;
	my $result = 0;
	if (@_){
		my $target = shift;
		
		croak "The element to be tested must be a CCO::Core::Synonym object" if (!UNIVERSAL::isa($target, 'CCO::Core::Synonym'));
		
		foreach my $ele (@{$self->{SET}}){
			if ($target->equals($ele)) {
				$result = 1;
				last;
			}
		}
	}
	return $result;
}

=head2 size

  Usage    - print $set->size()
  Returns  - the size of this set
  Args     - 
  Function - tells the number of elements held by this set
  
=cut
sub size {
	my $self = shift;
    return $#{$self->{SET}} + 1;
}

=head2 clear

  Usage    - $set->clear()
  Returns  - none
  Args     - none
  Function - clears this set
  
=cut
sub clear {
	my $self = shift;
	@{$self->{SET}} = ();
}

=head2 is_empty

  Usage    - $set->is_empty()
  Returns  - 1 (true) if this set is empty
  Args     - none
  Function - checks if this set is empty
  
=cut
sub is_empty{
	my $self = shift;
	return ($#{$self->{SET}} == -1);
}

=head2 equals

  Usage    - $set->equals()
  Returns  - true or false
  Args     - the set to compare with
  Function - tells whether this set is equal to the given one
  
=cut
sub equals {
	my $self = shift;
	my $result = 0; # I guess they'are NOT identical
	if (@_) {
		my $other_set = shift;
		
		croak "The element to be tested must be a CCO::Core::SynonymSet object" if (!UNIVERSAL::isa($other_set, 'CCO::Core::SynonymSet'));
		
		my %count = ();
# TODO parece que esta funcioando este metodo sin necesidad de usar 'equals' anivel de synonym...los tests pasan...raro...	
		my @this = map ({scalar $_;} @{$self->{SET}});
		my @that = map ({scalar $_;} $other_set->get_set());
		
		if ($#this == $#that) {
			foreach (@this, @that) {
				$count{$_}++;
			}
			foreach my $count (values %count) {
				if ($count != 2) {
					$result = 0;
					last;
				} else {
					$result = 1;
				}
			}
		}
	}
	return $result;
}

1;

=head1 NAME
    CCO::Core::SynonymSet  - a Set implementation
=head1 SYNOPSIS

use CCO::Core::SynonymSet;
use CCO::Core::Synonym;
use strict;

my $my_set = CCO::Core::SynonymSet->new;

my @arr = $my_set->get_set();

# three new terms
my $n1 = CCO::Core::Synonym->new;
my $n2 = CCO::Core::Synonym->new;
my $n3 = CCO::Core::Synonym->new;

$n1->id("CCO:P0000001");
$n2->id("CCO:P0000002");
$n3->id("CCO:P0000003");

$n1->name("One");
$n2->name("Two");
$n3->name("Three");

# remove from my_set
$my_set->remove($n1);
$my_set->add($n1);
$my_set->remove($n1);

### set versions ###
$my_set->add($n1);
$my_set->add($n2);
$my_set->add($n3);

my $n4 = CCO::Core::Synonym->new;
my $n5 = CCO::Core::Synonym->new;
my $n6 = CCO::Core::Synonym->new;

$n4->id("CCO:P0000004");
$n5->id("CCO:P0000005");
$n6->id("CCO:P0000006");

$n4->name("Four");
$n5->name("Five");
$n6->name("Six");

$my_set->add_all($n4, $n5, $n6);

$my_set->add_all($n4, $n5, $n6);

# remove from my_set
$my_set->remove($n4);

my $n7 = $n4;
my $n8 = $n5;
my $n9 = $n6;

my $my_set2 = CCO::Core::SynonymSet->new;

$my_set->add_all($n4, $n5, $n6);
$my_set2->add_all($n7, $n8, $n9, $n1, $n2, $n3);

$my_set2->clear();

=head1 DESCRIPTION
A set of synonyms for a term or relationship type.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut    