# $Id: SynonymSet.pm 2010-09-29 erick.antezana $
#
# Module  : SynonymSet.pm
# Purpose : Synonym set.
# License : Copyright (c) 2006-2011 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Util::SynonymSet;

our @ISA = qw(OBO::Util::Set);
use OBO::Util::Set;

use strict;
use warnings;

=head2 remove

  Usage    - $set->remove($element)
  Returns  - the removed element
  Args     - the element (OBO::Core::Synonym) to be removed
  Function - removes an element from this set
  
=cut
sub remove {
	my $self = shift;
	my $result = undef;
	if (@_) {
		my $ele = shift;
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

  Usage    - $set->contains()
  Returns  - true if this set contains the given element
  Args     - the element (OBO::Core::Synonym) to be checked
  Function - checks if this set constains the given element
  
=cut
sub contains {
	my $self = shift;
	my $result = 0;
	if (@_){
		my $target = shift;
		
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

  Usage    - $set->equals()
  Returns  - true or false
  Args     - the set (OBO::Util::SynonymSet) to compare with
  Function - tells whether this set is equal to the given one
  
=cut
sub equals {
	my $self = shift;
	my $result = 0; # I guess they'are NOT identical
	if (@_) {
		my $other_set = shift;
		
		my %count = ();
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

__END__


=head1 NAME

OBO::Util::SynonymSet - An implementation of a set of synonyms.
    
=head1 SYNOPSIS

use OBO::Util::SynonymSet;

use OBO::Core::Synonym;

use strict;

my $my_set = OBO::Util::SynonymSet->new;

my @arr = $my_set->get_set();


# three new synonyms

my $n1 = OBO::Core::Synonym->new;

my $n2 = OBO::Core::Synonym->new;

my $n3 = OBO::Core::Synonym->new;


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


my $n4 = OBO::Core::Synonym->new;

my $n5 = OBO::Core::Synonym->new;

my $n6 = OBO::Core::Synonym->new;


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


my $my_set2 = OBO::Util::SynonymSet->new;

$my_set->add_all($n4, $n5, $n6);

$my_set2->add_all($n7, $n8, $n9, $n1, $n2, $n3);


$my_set2->clear();

=head1 DESCRIPTION

A set (OBO::Util::Set) of synonyms (OBO::Core::Synonym) for a term (OBO::Core::Term) 
or relationship type (OBO::Core::RelationshipType).

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut