# $Id: Makefile.PL 1896 2008-02-14 14:49:23Z erant $
use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

$p = "XML::XPath";
if (!eval "require $p") {
    print <<MSG;

   XML::XPath is missing. This module is only required in order to
   perform parsing operations with IntAct-XML files. However, this 
   module is not required for using ONTO-PERL. If you do not intend 
   to use IntAct XML files, then you may continue, and install 
   XML::XPath in the future.

MSG
      
}

$p = "SWISS::Entry";
if (!eval "require $p") {
    print <<MSG;

   SWISS::Entry is missing. This module is only required in order to
   perform parsing operations with UniProt files. However, this 
   module is not required for using ONTO-PERL. If you do not intend 
   to use UniProt files, then you may continue, and install 
   SWISS::Entry in the future.

MSG
      
}

$p = "XML::Parser";
if (!eval "require $p") {
    print <<MSG;

   XML::Parser is missing. This module is only required in order to
   perform parsing operations with XML files (obo2owl). However, this 
   module is not fully required for using ONTO-PERL. If you do not intend 
   to convert your files to OWL, then you may continue, and install 
   XML::Parser in the future.

MSG
      
}

WriteMakefile(
    NAME              => 'ONTO-PERL',
    DISTNAME          => 'ONTO-PERL',
    ABSTRACT          => 'PERL Modules for biomedical ontologies such as the Cell Cycle Ontology (CCO) and OBO ontologies in general like Gene Ontology (GO)',
    VERSION_FROM      => 'ONTO-PERL.pod', # finds $VERSION
    #LICENCE           => 'perl',
    #PREREQ_PM         => {
	#		'SWISS::Entry' => 1.65,
	#		'XML::Simple'  => 2.16}, # e.g., Module::Name => 1.1
	EXE_FILES         => [
							qw(
								scripts/get_ancestor_terms.pl
								scripts/get_child_terms.pl
								scripts/get_descendent_terms.pl
								scripts/get_parent_terms.pl
								scripts/get_relationship_types.pl
								scripts/get_terms.pl
								scripts/go2owl.pl
								scripts/obo2cco.pl
								scripts/obo2owl.pl
								scripts/obo2rdf.pl
								scripts/obo2tran.pl	
								scripts/obo2xml.pl
								scripts/obsolete_term_id_vs_def_in_go.pl
								scripts/obsolete_term_id_vs_name_in_go.pl
								scripts/owl2obo.pl
								scripts/term_id_vs_term_def.pl
								scripts/term_id_vs_term_name.pl
							)
						],
			
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
    (AUTHOR           => 'Erick Antezana <erick.antezana -@- gmail.com>') : ()),
     dist             => { 
			'SUFFIX'       => ".gz",
			'DIST_DEFAULT' => 'all tardist',
			'COMPRESS'     => "gzip -9f" 
			},
);
