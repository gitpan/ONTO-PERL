# $Id: Makefile.PL 1896 2011-02-14 14:49:23Z erick $
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
	ABSTRACT          => 'PERL Modules for OBO-formatted ontologies such as the Gene Ontology (GO)',
	VERSION_FROM      => 'lib/OBO/Core/Ontology.pm', # finds $VERSION
	#LICENCE           => 'perl',
	#PREREQ_PM         => {
	#		'SWISS::Entry' => 1.65,
	#		'XML::Simple'  => 2.16}, # e.g., Module::Name => 1.1
	EXE_FILES         => [
							qw(
								scripts/get_ancestor_terms.pl
								scripts/get_child_terms.pl
								scripts/get_descendent_terms.pl
								scripts/get_obsolete_term_id_vs_def_in_go.pl
								scripts/get_obsolete_term_id_vs_name_in_go.pl
								scripts/get_obsolete_terms.pl
								scripts/get_parent_terms.pl
								scripts/get_relationship_id_vs_relationship_def.pl
								scripts/get_relationship_id_vs_relationship_name.pl
								scripts/get_relationship_id_vs_relationship_namespace.pl
								scripts/get_relationship_types.pl
								scripts/get_root_terms.pl
								scripts/get_subontology_from.pl
								scripts/get_term_id_vs_term_def.pl
								scripts/get_term_id_vs_term_name.pl
								scripts/get_term_id_vs_term_namespace.pl
								scripts/get_term_synonyms.pl
								scripts/get_terms.pl
								scripts/get_terms_and_synonyms.pl
								scripts/get_terms_by_name.pl
								scripts/go2owl.pl
								scripts/goa2rdf.pl
								scripts/obo2cco.pl
								scripts/obo2owl.pl
								scripts/obo2rdf.pl
								scripts/obo2tran.pl	
								scripts/obo2xml.pl
								scripts/obo_intersection.pl
								scripts/obo_transitive_reduction.pl
								scripts/obo_trimming.pl
								scripts/obo_union.pl
								scripts/owl2obo.pl
							)
						],
			
	($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	(AUTHOR   => 'Erick Antezana <erick.antezana -@- gmail.com>') : ()),
	dist      => { 
					'SUFFIX'       => ".gz",
					'DIST_DEFAULT' => 'all tardist',
					'COMPRESS'     => "gzip -9f" 
				},
	clean      => {FILES => "t/data/human.2.map t/data/add_goa_assocs.out t/data/goa.rdf t/data/go.obo t/data/go_transitive_closure.obo t/data/go_transitive_reduction.obo t/data/ncbi.rdf t/data/pre_cco_taxa.obo t/data/test0.obo t/data/test1.obo t/data/test1.rdf t/data/test1.xml t/data/test2.dot t/data/test2.obo t/data/test2.owl t/data/test2.rdf t/data/test2.xml t/data/test_ulo_cco2.obo t/data/test_ulo_cco.dot t/data/test_ulo_cco.owl"},
);
