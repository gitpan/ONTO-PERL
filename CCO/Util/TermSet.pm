# $Id: TermSet.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : TermSet.pm
# Purpose : Term set.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Util::TermSet;
our @ISA = qw(CCO::Util::ObjectSet);
use CCO::Util::ObjectSet;

use strict;
use warnings;
use Carp;

=head2 contains_id

  Usage    - $set->contains_id($element_id)
  Returns  - true if this set contains an element with the given ID
  Args     - the ID to be checked
  Function - checks if this set constains an element with the given ID
  
=cut
sub contains_id {
	my ($self, $id) = @_;
	return ($self->{MAP}->{$id})?1:0;
}

=head2 contains_name

  Usage    - $set->contains_name($element_name)
  Returns  - true if this set contains an element with the given name
  Args     - the name to be checked
  Function - checks if this set constains an element with the given name
  
=cut
sub contains_name {
	my $self = shift;
	my $result = 0;
	if (@_) {
		my $term_id = shift;
		
		foreach my $ele (values %{$self->{MAP}}){
			if ($ele->name() eq $term_id) {
				$result = 1;
				last;
			}
		}
	}
	return $result;
}

1;

=head1 NAME

    CCO::Util::TermSet  - a Set implementation
    
=head1 SYNOPSIS

use CCO::Util::TermSet;

use CCO::Core::Term;

use strict;


my $my_set = CCO::Util::TermSet->new;

my @arr = $my_set->get_set();


# three new terms

my $n1 = CCO::Core::Term->new;

my $n2 = CCO::Core::Term->new;

my $n3 = CCO::Core::Term->new;

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



my $n4 = CCO::Core::Term->new;

my $n5 = CCO::Core::Term->new;

my $n6 = CCO::Core::Term->new;


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


my $my_set2 = CCO::Util::TermSet->new;

$my_set->add_all($n4, $n5, $n6);

$my_set2->add_all($n7, $n8, $n9, $n1, $n2, $n3);

$my_set2->clear();

=head1 DESCRIPTION

A set (CCO::Util::Set) of terms (CCO::Core::Term).

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut    
