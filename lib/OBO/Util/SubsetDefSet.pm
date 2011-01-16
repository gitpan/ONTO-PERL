# $Id: SubsetDefSet.pm 2010-10-29 erick.antezana $
#
# Module  : SubsetDefSet.pm
# Purpose : Synonym Type Definition Set.
# License : Copyright (c) 2006-2011 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Util::SubsetDefSet;
# TODO This class is identical to OBO::Util::IDspaceSet
# TODO This class is identical to OBO::Util::SynonymTypeDefSet

our @ISA = qw(OBO::Util::Set);
use OBO::Util::Set;

use strict;
use warnings;

=head2 contains

  Usage    - $set->contains()
  Returns  - true if this set contains the given element
  Args     - the element (OBO::Core::SubsetDef) to be checked
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
  Args     - the set (OBO::Util::SubsetDefSet) to compare with
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

=head2 remove

  Usage    - $set->remove($element)
  Returns  - the removed element
  Args     - the element (OBO::Core::SubsetDef) to be removed
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

1;

__END__


=head1 NAME

OBO::Util::SubsetDefSet - A Set implementation of a subset definition.
    
=head1 SYNOPSIS

use OBO::Util::SubsetDefSet;

use OBO::Core::SubsetDef;

use strict;

my $my_set = OBO::Util::SubsetDefSet->new();

my @arr = $my_set->get_set();

my $n1 = OBO::Core::SubsetDef->new();

my $n2 = OBO::Core::SubsetDef->new();

my $n3 = OBO::Core::SubsetDef->new();


$n1->name("GO_SLIM");

$n2->name("CCO_SLIM");

$n3->name("SO_SLIM");

$n1->description("GO terms");

$n2->description("CCO terms");

$n3->description("SO terms");


$my_set->add($n1);

$my_set->add($n2);

$my_set->add($n3);


$my_set->remove($n1);

$my_set->add($n1);

$my_set->remove($n1);

=head1 DESCRIPTION

A set (OBO::Util::Set) of subset definitions (OBO::Core::SubsetDef).

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut