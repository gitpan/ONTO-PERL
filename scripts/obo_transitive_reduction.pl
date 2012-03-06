#!/usr/local/bin/perl
# $Id: obo_transitive_reduction.pl 2011-02-03 erick.antezana $
#
# Script  : obo_transitive_reduction.pl
# Purpose : Reduces all the transitive relationships (e.g. is_a, part_of) along the
#           hierarchy and generates a new ontology holding the minimal paths (relationships). 
# Usage   : obo_transitive_reduction.pl my_ontology.obo > transitive_reduction.obo
# License : Copyright (c) 2006-2012 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
###############################################################################

use Carp;
use strict;
use warnings;
use OBO::Parser::OBOParser;
use OBO::Util::Ontolome;

my $my_parser            = OBO::Parser::OBOParser->new();
my $onto                 = $my_parser->work(shift @ARGV);
my $my_ontolome          = OBO::Util::Ontolome->new();
my $transitive_reduction = $my_ontolome->transitive_reduction($onto);
$transitive_reduction->export('obo', \*STDOUT);

exit 0;

__END__

=head1 NAME

obo_transitive_reduction.pl - Finds the transitive reduction ontology of the given OBO-formatted ontology.

=head1 DESCRIPTION

Reduces all the transitive relationships (e.g. is_a, part_of) along the
hierarchy and generates a new ontology holding the minimal paths (relationships).

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2012 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut