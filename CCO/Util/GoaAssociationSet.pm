# $Id: GoaAssociationSet.pm 1377 2007-08-06 16:07:14Z erant $
#
# Module  : GoaAssociationSet.pm
# Purpose : GOA association set.
# License : Copyright (c) 2006 Vladimir Mironov. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Vladimir Mironov <vlmir@psb.ugent.be>
#
package CCO::Util::GoaAssociationSet;
our @ISA = qw(CCO::Util::Set);#TODO change inheritence
use CCO::Util::Set;
use strict;
use warnings;
use Carp;



=head2 add

 Usage    - $set->add($goa_association)
 Returns  - true if the element was successfully added
 Args     - the element (CCO::Core::GoaAssociation) to be added
 Function - adds an element to this set

=cut
sub add {
   my $self = shift;
   my $result = 0; # nothing added
   if (@_) {          my $ele = shift;
       if ( !$self -> contains($ele) ) {
           push @{$self->{SET}}, $ele;
           $result = 1; # successfully added
       }
   }
   return $result;
}

=head2 remove

 Usage    - $set->remove($element)
 Returns  - the removed element (CCO::Core::GoaAssociation)
 Args     - the element to be removed (CCO::Core::GoaAssociation)
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

=head2 remove_duplicates

 Usage    - $set->remove_duplicates()
 Returns  - a set object (CCO::Util::GoaAssociationSet) 
 Args     - none 
 Function - eliminates redundency in a GOA association set object (CCO::Util::GoaAssociationSet)

=cut
sub remove_duplicates {
	my $self = shift;
	my @list = @{$self->{SET}};
	my @set = ();
	while (scalar (@list)) {
		my $ele = pop(@list);
		my $result = 0;
		foreach (@list) {
			if ($ele->equals($_)) {
				$result = 1; 
				last; 
			}
		}
		unshift @set, $ele if $result == 0;
	}
	@{$self->{SET}} = @set;
	return $self;
}


=head2 contains

 Usage    - $set->contains($goa_association)
 Returns  - either 1(true) or 0 (false)
 Args     - the element (CCO::Core::GoaAssociation) to be checked
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

 Usage    - $set->equals($another_goa_assocations_set)
 Returns  - either 1 (true) or 0 (false)
 Args     - the set (CCO::Util::GoaAssociationSet) to compare with
 Function - tells whether this set is equal to the given one

=cut
sub equals {
   my $self = shift;
   my $result = 0; # I guess they'are NOT identical
     if (@_) {
       my $other_set = shift;
		my %count = ();
		my @this = @{$self->{SET}};
		my @that = $other_set->get_set();

       if ($#this == $#that) {
           if ($#this != -1) {
               foreach (@this, @that) {
                   $count{	$_->annot_src().
                   			$_->aspect().
                   			$_->assc_id().
                   			$_->date().
                   			$_->description().
                   			$_->evid_code().
                   			$_->go_id().
                   			$_->obj_id().
                   			$_->obj_src().
                   			$_->obj_symb().
                   			$_->qualifier().
                   			$_->refer().
                   			$_->sup_ref().
                   			$_->synonym().
                   			$_->taxon().
                   			$_->type()}++;
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

   CCO::Util::GoaAssociationSet  - a GoaAssociationSet implementation
   
=head1 SYNOPSIS

use CCO::Util::GoaAssociationSet;
use CCO::Core::GoaAssociation;
use strict;

my $my_set = CCO::Util::GoaAssociationSet->new();

# three new goa_association's
my $goa_association1 = CCO::Core::GoaAssociation->new();
my $goa_association2 = CCO::Core::GoaAssociation->new();
my $goa_association3 = CCO::Core::GoaAssociation->new();

$goa_association1->assc_id("CCO:vm");
$goa_association2->assc_id("CCO:ls");
$goa_association3->assc_id("CCO:ea");

# remove from my_set
$my_set->remove($goa_association1);
$my_set->add($goa_association1);
$my_set->remove($goa_association1);

### set versions ###
$my_set->add($goa_association1);
$my_set->add($goa_association2);
$my_set->add($goa_association3);

my $goa_association4 = CCO::Core::GoaAssociation->new();
my $goa_association5 = CCO::Core::GoaAssociation->new();
my $goa_association6 = CCO::Core::GoaAssociation->new();

$goa_association4->assc_id("CCO:ef");
$goa_association5->assc_id("CCO:sz");
$goa_association6->assc_id("CCO:qa");

$my_set->add_all($goa_association4, $goa_association5, $goa_association6);

$my_set->add_all($goa_association4, $goa_association5, $goa_association6);

# remove from my_set
$my_set->remove($goa_association4);

my $goa_association7 = $goa_association4;
my $goa_association8 = $goa_association5;
my $goa_association9 = $goa_association6;

my $my_set2 = CCO::Util::GoaAssociationSet->new();

$my_set->add_all($goa_association4, $goa_association5, $goa_association6);
$my_set2->add_all($goa_association7, $goa_association8, $goa_association9, $goa_association1, $goa_association2, $goa_association3);

$my_set2->clear();

=head1 DESCRIPTION

A set (CCO::Util::Set) of goa_association records.

=head1 AUTHOR

Vladimir Mironov, E<lt>vlmir@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut 