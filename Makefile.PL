use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CCO',
    DISTNAME          => 'onto-perl',
    ABSTRACT          => 'Modules for OBO ontologies such as Cell Cycle Ontology (CCO) and Gene Ontology (GO)',
    VERSION_FROM      => 'onto-perl.pod', # finds $VERSION
    #LICENSE           => 'perl',
    PREREQ_PM         => {
			'SWISS::Entry' => 1.65,
			'XML::Simple'  => 2.16}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
    (AUTHOR           => 'Erick Antezana <erant@psb.ugent.be>') : ()),
     dist             => { 
			'SUFFIX'       => ".gz",
			'DIST_DEFAULT' => 'all tardist',
			'COMPRESS'     => "gzip -9f" 
			},
);
