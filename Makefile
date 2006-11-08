# This Makefile is for the CCO extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.17 (Revision: 1.133) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
#   MakeMaker Parameters:

#     ABSTRACT => q[CCO Perl]
#     AUTHOR => q[Erick Antezana <erant@psb.ugent.be>]
#     DISTNAME => q[onto-perl]
#     NAME => q[CCO]
#     PREREQ_PM => {  }
#     VERSION_FROM => q[onto-perl.pod]
#     dist => { DIST_DEFAULT=>q[all tardist], COMPRESS=>q[gzip -9f], SUFFIX=>q[.gz] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/local/perl/lib/5.8.7/x86_64-linux/Config.pm)

# They may have been overridden via Makefile.PL or on the command line
AR = ar
CC = cc
CCCDLFLAGS = -fpic
CCDLFLAGS = -Wl,-E -Wl,-rpath,/usr/local/perl/lib/5.8.7/x86_64-linux/CORE
DLEXT = so
DLSRC = dl_dlopen.xs
LD = cc
LDDLFLAGS = -shared -L/usr/local/lib
LDFLAGS =  -L/usr/local/lib
LIBC = /lib/libc-2.3.4.so
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 2.6.9-11.elsmp
RANLIB = :
SITELIBEXP = /usr/local/perl/lib/site_perl/5.8.7
SITEARCHEXP = /usr/local/perl/lib/site_perl/5.8.7/x86_64-linux
SO = so
EXE_EXT = 
FULL_AR = /usr/bin/ar
VENDORARCHEXP = 
VENDORLIBEXP = 


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
NAME = CCO
NAME_SYM = CCO
VERSION = 0.23
VERSION_MACRO = VERSION
VERSION_SYM = 0_23
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.23
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3
INSTALLDIRS = site
DESTDIR = 
PREFIX = 
PERLPREFIX = /usr/local/perl
SITEPREFIX = /usr/local/perl
VENDORPREFIX = 
INSTALLPRIVLIB = $(PERLPREFIX)/lib/5.8.7
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = $(SITEPREFIX)/lib/site_perl/5.8.7
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = 
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(PERLPREFIX)/lib/5.8.7/x86_64-linux
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = $(SITEPREFIX)/lib/site_perl/5.8.7/x86_64-linux
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = 
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(PERLPREFIX)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(SITEPREFIX)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = 
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(PERLPREFIX)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLMAN1DIR = $(PERLPREFIX)/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(SITEPREFIX)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = 
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(PERLPREFIX)/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(SITEPREFIX)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = 
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB = /usr/local/perl/lib/5.8.7
PERL_ARCHLIB = /usr/local/perl/lib/5.8.7/x86_64-linux
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = $(FIRST_MAKEFILE).old
MAKE_APERL_FILE = $(FIRST_MAKEFILE).aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/local/perl/lib/5.8.7/x86_64-linux/CORE
PERL = /usr/local/perl/bin/perl
FULLPERL = /usr/local/perl/bin/perl
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/local/perl/lib/5.8.7/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.17
MM_REVISION = 1.133

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
FULLEXT = CCO
BASEEXT = CCO
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = onto-perl.pod
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = CCO/Core/Dbxref.pm \
	CCO/Core/Def.pm \
	CCO/Core/Ontology.pm \
	CCO/Core/Relationship.pm \
	CCO/Core/RelationshipType.pm \
	CCO/Core/Synonym.pm \
	CCO/Core/Term.pm \
	CCO/Parser/NCBIParser.pm \
	CCO/Parser/OBOParser.pm \
	CCO/Util/DbxrefSet.pm \
	CCO/Util/Set.pm \
	CCO/Util/SynonymSet.pm \
	CCO/Util/TermSet.pm \
	onto-perl.pod

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DIRFILESEP)Config.pm $(PERL_INC)$(DIRFILESEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = CCO/Core/Dbxref.pm \
	CCO/Core/Def.pm \
	CCO/Core/Ontology.pm \
	CCO/Core/Relationship.pm \
	CCO/Core/RelationshipType.pm \
	CCO/Core/Synonym.pm \
	CCO/Core/Term.pm \
	CCO/Parser/NCBIParser.pm \
	CCO/Parser/OBOParser.pm \
	CCO/Util/DbxrefSet.pm \
	CCO/Util/Set.pm \
	CCO/Util/SynonymSet.pm \
	CCO/Util/TermSet.pm \
	onto-perl.pod

PM_TO_BLIB = onto-perl.pod \
	$(INST_LIB)/onto-perl.pod \
	CCO/Core/Dbxref.pm \
	$(INST_LIB)/CCO/Core/Dbxref.pm \
	CCO/Util/DbxrefSet.pm \
	$(INST_LIB)/CCO/Util/DbxrefSet.pm \
	CCO/Core/Relationship.pm \
	$(INST_LIB)/CCO/Core/Relationship.pm \
	CCO/Util/TermSet.pm \
	$(INST_LIB)/CCO/Util/TermSet.pm \
	CCO/Core/RelationshipType.pm \
	$(INST_LIB)/CCO/Core/RelationshipType.pm \
	CCO/Util/SynonymSet.pm \
	$(INST_LIB)/CCO/Util/SynonymSet.pm \
	CCO/Core/Ontology.pm \
	$(INST_LIB)/CCO/Core/Ontology.pm \
	CCO/Core/Synonym.pm \
	$(INST_LIB)/CCO/Core/Synonym.pm \
	CCO/Core/Def.pm \
	$(INST_LIB)/CCO/Core/Def.pm \
	CCO/Util/Set.pm \
	$(INST_LIB)/CCO/Util/Set.pm \
	CCO/Core/Term.pm \
	$(INST_LIB)/CCO/Core/Term.pm \
	CCO/Parser/NCBIParser.pm \
	$(INST_LIB)/CCO/Parser/NCBIParser.pm \
	CCO/Parser/OBOParser.pm \
	$(INST_LIB)/CCO/Parser/OBOParser.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 1.42
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(PERLRUN)  -e 'use AutoSplit;  autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1)'



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(SHELL) -c true
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(PERLRUN) "-MExtUtils::Command" -e mkpath
EQUALIZE_TIMESTAMP = $(PERLRUN) "-MExtUtils::Command" -e eqtime
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(PERLRUN) -MExtUtils::Install -e 'install({@ARGV}, '\''$(VERBINST)'\'', 0, '\''$(UNINST)'\'');'
DOC_INSTALL = $(PERLRUN) "-MExtUtils::Command::MM" -e perllocal_install
UNINSTALL = $(PERLRUN) "-MExtUtils::Command::MM" -e uninstall
WARN_IF_OLD_PACKLIST = $(PERLRUN) "-MExtUtils::Command::MM" -e warn_if_old_packlist


# --- MakeMaker makemakerdflt section:
makemakerdflt: all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip -9f
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = all tardist
DISTNAME = onto-perl
DISTVNAME = onto-perl-0.23


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIB="$(LIB)"\
	LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	OPTIMIZE="$(OPTIMIZE)"\
	PASTHRU_DEFINE="$(PASTHRU_DEFINE)"\
	PASTHRU_INC="$(PASTHRU_INC)"


# --- MakeMaker special_targets section:
.SUFFIXES: .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) $(INST_LIBDIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

config :: $(INST_ARCHAUTODIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

config :: $(INST_AUTODIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

$(INST_AUTODIR)/.exists :: /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h $(INST_AUTODIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_AUTODIR)

$(INST_LIBDIR)/.exists :: /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h $(INST_LIBDIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_LIBDIR)

$(INST_ARCHAUTODIR)/.exists :: /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h $(INST_ARCHAUTODIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_ARCHAUTODIR)

config :: $(INST_MAN3DIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)


$(INST_MAN3DIR)/.exists :: /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/perl/lib/5.8.7/x86_64-linux/CORE/perl.h $(INST_MAN3DIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_MAN3DIR)

help:
	perldoc ExtUtils::MakeMaker


# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	onto-perl.pod \
	CCO/Core/Dbxref.pm \
	CCO/Util/DbxrefSet.pm \
	CCO/Core/Relationship.pm \
	CCO/Util/TermSet.pm \
	CCO/Core/RelationshipType.pm \
	CCO/Util/SynonymSet.pm \
	CCO/Core/Ontology.pm \
	CCO/Core/Synonym.pm \
	CCO/Core/Def.pm \
	CCO/Util/Set.pm \
	CCO/Core/Term.pm \
	CCO/Parser/NCBIParser.pm \
	CCO/Parser/OBOParser.pm \
	onto-perl.pod \
	CCO/Core/Dbxref.pm \
	CCO/Util/DbxrefSet.pm \
	CCO/Core/Relationship.pm \
	CCO/Util/TermSet.pm \
	CCO/Core/RelationshipType.pm \
	CCO/Util/SynonymSet.pm \
	CCO/Core/Ontology.pm \
	CCO/Core/Synonym.pm \
	CCO/Core/Def.pm \
	CCO/Util/Set.pm \
	CCO/Core/Term.pm \
	CCO/Parser/NCBIParser.pm \
	CCO/Parser/OBOParser.pm
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW)\
	  onto-perl.pod $(INST_MAN3DIR)/onto-perl.$(MAN3EXT) \
	  CCO/Core/Dbxref.pm $(INST_MAN3DIR)/CCO::Core::Dbxref.$(MAN3EXT) \
	  CCO/Util/DbxrefSet.pm $(INST_MAN3DIR)/CCO::Util::DbxrefSet.$(MAN3EXT) \
	  CCO/Core/Relationship.pm $(INST_MAN3DIR)/CCO::Core::Relationship.$(MAN3EXT) \
	  CCO/Util/TermSet.pm $(INST_MAN3DIR)/CCO::Util::TermSet.$(MAN3EXT) \
	  CCO/Core/RelationshipType.pm $(INST_MAN3DIR)/CCO::Core::RelationshipType.$(MAN3EXT) \
	  CCO/Util/SynonymSet.pm $(INST_MAN3DIR)/CCO::Util::SynonymSet.$(MAN3EXT) \
	  CCO/Core/Ontology.pm $(INST_MAN3DIR)/CCO::Core::Ontology.$(MAN3EXT) \
	  CCO/Core/Synonym.pm $(INST_MAN3DIR)/CCO::Core::Synonym.$(MAN3EXT) \
	  CCO/Core/Def.pm $(INST_MAN3DIR)/CCO::Core::Def.$(MAN3EXT) \
	  CCO/Util/Set.pm $(INST_MAN3DIR)/CCO::Util::Set.$(MAN3EXT) \
	  CCO/Core/Term.pm $(INST_MAN3DIR)/CCO::Core::Term.$(MAN3EXT) \
	  CCO/Parser/NCBIParser.pm $(INST_MAN3DIR)/CCO::Parser::NCBIParser.$(MAN3EXT) \
	  CCO/Parser/OBOParser.pm $(INST_MAN3DIR)/CCO::Parser::OBOParser.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	-$(RM_RF) ./blib $(MAKE_APERL_FILE) $(INST_ARCHAUTODIR)/extralibs.all $(INST_ARCHAUTODIR)/extralibs.ld perlmain.c tmon.out mon.out so_locations pm_to_blib *$(OBJ_EXT) *$(LIB_EXT) perl.exe perl perl$(EXE_EXT) $(BOOTSTRAP) $(BASEEXT).bso $(BASEEXT).def lib$(BASEEXT).def $(BASEEXT).exp $(BASEEXT).x core core.*perl.*.? *perl.core core.[0-9] core.[0-9][0-9] core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9][0-9]
	-$(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:

# Delete temporary files (via clean) and also delete installed files
realclean purge ::  clean realclean_subdirs
	$(RM_RF) $(INST_AUTODIR) $(INST_ARCHAUTODIR)
	$(RM_RF) $(DISTVNAME)
	$(RM_F)  $(INST_LIB)/CCO/Util/DbxrefSet.pm $(INST_LIB)/CCO/Core/Relationship.pm $(INST_LIB)/CCO/Core/RelationshipType.pm $(MAKEFILE_OLD) $(INST_LIB)/CCO/Parser/OBOParser.pm $(INST_LIB)/CCO/Core/Dbxref.pm
	$(RM_F) $(INST_LIB)/CCO/Parser/NCBIParser.pm $(INST_LIB)/CCO/Core/Def.pm $(INST_LIB)/onto-perl.pod $(INST_LIB)/CCO/Util/SynonymSet.pm $(INST_LIB)/CCO/Core/Synonym.pm $(FIRST_MAKEFILE)
	$(RM_F) $(INST_LIB)/CCO/Util/TermSet.pm $(INST_LIB)/CCO/Core/Ontology.pm $(INST_LIB)/CCO/Core/Term.pm $(INST_LIB)/CCO/Util/Set.pm


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(ECHO) '# http://module-build.sourceforge.net/META-spec.html' > META.yml
	$(NOECHO) $(ECHO) '#XXXXXXX This is a prototype!!!  It will change in the future!!! XXXXX#' >> META.yml
	$(NOECHO) $(ECHO) 'name:         onto-perl' >> META.yml
	$(NOECHO) $(ECHO) 'version:      0.23' >> META.yml
	$(NOECHO) $(ECHO) 'version_from: onto-perl.pod' >> META.yml
	$(NOECHO) $(ECHO) 'installdirs:  site' >> META.yml
	$(NOECHO) $(ECHO) 'requires:' >> META.yml
	$(NOECHO) $(ECHO) '' >> META.yml
	$(NOECHO) $(ECHO) 'distribution_type: module' >> META.yml
	$(NOECHO) $(ECHO) 'generated_by: ExtUtils::MakeMaker version 6.17' >> META.yml


# --- MakeMaker metafile_addtomanifest section:
metafile_addtomanifest:
	$(NOECHO) $(PERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{META.yml} => q{Module meta-data (added by MakeMaker)}}) } ' \
	-e '    or print "Could not add META.yml to MANIFEST: $${'\''@'\''}\n"'


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ *.orig */*~ */*.orig



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(PERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	-e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';'

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
distdir : metafile metafile_addtomanifest
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"



# --- MakeMaker dist_test section:

disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)


# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker install section:

install :: all pure_install doc_install

install_perl :: all pure_perl_install doc_perl_install

install_site :: all pure_site_install doc_site_install

install_vendor :: all pure_vendor_install doc_vendor_install

pure_install :: pure_$(INSTALLDIRS)_install

doc_install :: doc_$(INSTALLDIRS)_install

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE:
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:

# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	-$(MAKE) -f $(MAKEFILE_OLD) clean $(DEV_NULL) || $(NOOP)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the make command.  <=="
	false



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/local/perl/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) -f $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE)
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE)

test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd:
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="0,23,0,0">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <TITLE>$(DISTNAME)</TITLE>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>CCO Perl</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Erick Antezana &lt;erant@psb.ugent.be&gt;</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <OS NAME="$(OSNAME)" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="x86_64-linux" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib: $(TO_INST_PM)
	$(NOECHO) $(PERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', '\''$(PM_FILTER)'\'')'\
	  onto-perl.pod $(INST_LIB)/onto-perl.pod \
	  CCO/Core/Dbxref.pm $(INST_LIB)/CCO/Core/Dbxref.pm \
	  CCO/Util/DbxrefSet.pm $(INST_LIB)/CCO/Util/DbxrefSet.pm \
	  CCO/Core/Relationship.pm $(INST_LIB)/CCO/Core/Relationship.pm \
	  CCO/Util/TermSet.pm $(INST_LIB)/CCO/Util/TermSet.pm \
	  CCO/Core/RelationshipType.pm $(INST_LIB)/CCO/Core/RelationshipType.pm \
	  CCO/Util/SynonymSet.pm $(INST_LIB)/CCO/Util/SynonymSet.pm \
	  CCO/Core/Ontology.pm $(INST_LIB)/CCO/Core/Ontology.pm \
	  CCO/Core/Synonym.pm $(INST_LIB)/CCO/Core/Synonym.pm \
	  CCO/Core/Def.pm $(INST_LIB)/CCO/Core/Def.pm \
	  CCO/Util/Set.pm $(INST_LIB)/CCO/Util/Set.pm \
	  CCO/Core/Term.pm $(INST_LIB)/CCO/Core/Term.pm \
	  CCO/Parser/NCBIParser.pm $(INST_LIB)/CCO/Parser/NCBIParser.pm \
	  CCO/Parser/OBOParser.pm $(INST_LIB)/CCO/Parser/OBOParser.pm 
	$(NOECHO) $(TOUCH) $@

# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
