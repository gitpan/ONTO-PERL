#!/usr/bin/env perl
# $Id: obo2xml.pl 2013-09-29 erick.antezana $
#
# Script  : obo2xml.pl
# Purpose : Converts a file from OBO to XML.
# Usage   : obo2xml.pl $pre_apo_obo_path > $pre_apo_xml_path
# License : Copyright (c) 2006-2014 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
###############################################################################

use Carp;
use strict;
use warnings;
use OBO::Parser::OBOParser;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology = $my_parser->work(shift(@ARGV));
$ontology->export('obo', \*STDOUT);

exit 0;

__END__

=head1 NAME

obo2xml.pl - OBO to XML translator (APO scheme).

=head1 DESCRIPTION

This script transforms an OBO file into XML that follows the XML scheme.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2014 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut