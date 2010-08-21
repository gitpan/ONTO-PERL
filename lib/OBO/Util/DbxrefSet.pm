# $Id: DbxrefSet.pm 1846 2008-01-08 12:35:31Z easr $
#
# Module  : DbxrefSet.pm
# Purpose : Reference structure set.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Util::DbxrefSet;
our @ISA = qw(OBO::Util::ObjectSet);

=head1 NAME

OBO::Util::DbxrefSet  - A Dbxref set implementation.
    
=head1 SYNOPSIS

use OBO::Util::DbxrefSet;
use OBO::Core::Dbxref;
use strict;

my $my_set = OBO::Util::DbxrefSet->new;

# three new dbxref's
my $ref1 = OBO::Core::Dbxref->new;
my $ref2 = OBO::Core::Dbxref->new;
my $ref3 = OBO::Core::Dbxref->new;

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

my $ref4 = OBO::Core::Dbxref->new;
my $ref5 = OBO::Core::Dbxref->new;
my $ref6 = OBO::Core::Dbxref->new;

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

my $my_set2 = OBO::Util::DbxrefSet->new;

$my_set->add_all($ref4, $ref5, $ref6);
$my_set2->add_all($ref7, $ref8, $ref9, $ref1, $ref2, $ref3);

$my_set2->clear();

=head1 DESCRIPTION

A set (OBO::Util::Set) of dbxref (OBO::Core::Dbxref) elements.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use OBO::Util::ObjectSet;

use strict;
use warnings;
use Carp;

# TODO Values in dbxref lists should be ordered alphabetically on the dbxref name.

=head2 equals

  Usage    - $set->equals($another_dbxref_set)
  Returns  - either 1 (true) or 0 (false)
  Args     - the set (OBO::Util::DbxrefSet) to compare with
  Function - tells whether this set is equal to the given one
  
=cut
sub equals {
	my $self = shift;
	my $result = 0; # I guess they'are NOT identical
	
	if (@_) {
		my $other_set = shift;
		my %count = ();
		
		my @this = values %{$self->{MAP}};
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