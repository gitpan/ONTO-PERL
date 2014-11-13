#!/usr/bin/env perl
# $Id: goa2rdf.pl 2014-11-11 erick.antezana $
#
# Script  : goa2rdf.pl
# Purpose : Generates a simple RDF graph from a given GOA file.
# Usage   : goa2rdf.pl /path/to/input_file.goa [base_URI] [namespace] > output_file.rdf
# Example : goa2rdf.pl /path/to/input_file.goa http://www.semantic-systems-biology.org SSB > output_file.rdf
# Arguments:
#  			1. Full path to the GOA file
#  			2. File handle for writing RDF: STDOUT
# 			3. base URI (default: 'http://www.semantic-systems-biology.org/')
# 			4. namespace (default: 'SSB')
# License : Copyright (c) 2006-2014 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
##############################################################################

use Carp;
use strict;
use warnings;

use OBO::APO::GoaToRDF;

my $input_file = shift(@ARGV);
my $goa2rdf = OBO::APO::GoaToRDF->new();

my $file_handle = \*STDOUT;
my $base        = 'http://www.semantic-systems-biology.org/';
my $ns          = 'SSB';
$file_handle    = $goa2rdf->work($input_file, $file_handle, $base, $ns);

exit 0;

__END__

=head1 NAME

goa2rdf.pl - Generates a simple RDF graph from a given GOA file.

=head1 DESCRIPTION

Generates a simple RDF graph from a given GOA file.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2014 by Erick Antezana

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut