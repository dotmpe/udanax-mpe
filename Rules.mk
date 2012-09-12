include				$(MK_SHARE)Core/Main.dirstack.mk

MK				  += $/Rules.mk



#### Old rules
#
#_default:
#	@echo "make var/enf/%.enf ENF_DIR=path/to/files"
#	@echo "  Build enfilade from directory"
#	@echo "  E.g. use: make var/enf/name.enf ENF_DIR='var/htdocs/0.empty'"
#	@echo "  Generates new (overwrites) FeBe content-script and enf.enf."
#	@echo "Run"
#	@echo "  run - for pyxi frontend"
#	@echo "  server - for TCP server"
#	# TODO: links, the old demo docs don't have many
#
##$(CONTENT_SCRIPT): $(CONTENT_LIST)
##	@echo "Create a FeBe script for xumain which inserts contents from files"
##	create-content-script.py $< > $@
#
#### end old

# Enfilade directories, see below.

ENFS = \
		   EMPTY=var/enf/0.empty.enf;\
		   DEMO=var/enf/1.olddemo.enf;\
		   WIKI=var/enf/Xanadu-archaeology.enf;

ENF_DIRS = \
		   EMPTY=var/htdocs/0.empty/;\
		   DEMO=var/htdocs/1.olddemo/;\
		   WIKI=var/htdocs/Xanadu-archaeology/;

# Current enfilade directory
ENF_DIR=EMPTY

# Contents of enfilade directory
#CONTENT_LIST=$(ENF_DIR)/content.list
CONTENT_SCRIPT=$(ENF_DIR)/init-content.febe
LINK_SCRIPT=$(ENF_DIR)/init-links.febe

# stuff to clean (see also git clean -df)
CLN            += $(shell find $/ -iname '*.pyc' -or -path 'bin/be/x88.*' -or -name 'gmon.out' -or -name 'backenderror')


### Special targets

T				 := $(call mkid,$(d)enf)
DESCRIPTION	   += $(T)='Build an enfilade from CONTENT_SCRIPT and LINK_SCRIPT'
STRGT			 += $(T)

$T:		   ENF := EMPTY
$(T): 
	@-if test -f enf.enf; then rm -v enf.enf; fi;
	@\
	ENF=$(ENF);\
	! [ -z "$$ENF" ] || exit 50;\
	declare $(ENF_DIRS)\
	enf_dir=$${!ENF};\
	declare $(ENFS)\
	enf=$${!ENF};\
	\
	content_script=$$enf_dir/init-content.febe;\
	link_script=$$enf_dir/init-links.febe;\
	\
	cd $$enf_dir;\
	\
	echo;echo "Initializing and inserting text...";\
	../../../bin/green/be_source/xumain < ../../../$$content_script;\
	\
	echo;echo "Inserting links...";\
	../../../bin/green/be_source/backend < ../../../$$link_script; echo;\
	\
	cd ./$$(echo $$enf_dir | sed 's/[^\/]\+/../g');\
	mv $$enf_dir/enf.enf $$enf;\
	echo;echo Ready, size:;\
	wc -c $$enf


define install-enf
	ENF=$(ENF);\
	declare $(ENF_DIRS)\
	enf_dir=$${!ENF};\
	declare $(ENFS)\
	enf=$${!ENF};\
	cd bin/be; echo pwd=$$(pwd); rm -v enf.enf; ln -vs ../../$$enf enf.enf
endef

define run-pyxi
	echo -e "\nImportant: Use alt-q to exit (and wait for the backend to close)\n";\
	echo "Need to fix tkinter event handers.."
	cd $(<D); ./$(<F)
endef


T				 := $(call mkid,$drun)
DESCRIPTION	     += $(T)='Run pyxi normally'
STRGT			 += $(T)

$T:		   ENF := EMPTY
$(T):			  $/bin/pyxi
	@$(install-enf)
	@$(run-pyxi)


T				 := $(call mkid,$ddebug)
DESCRIPTION	     += $(T)='Run pyxi in verbose mode'
STRGT			 += $(T)

$T:		   ENF := EMPTY
$(T):				$/bin/pyxi
	@$(install-enf)
	@$(run-pyxi) -d

_test:
	python test/Tumbler.py


T				 := $(call mkid,$(d)server)
DESCRIPTION	     += $T='Run server with -t CONN -b BE'
STRGT			 += $T

$T:		   ENF := EMPTY
$T:		   DIR := $/
$T:		  CONN := localhost:55146
$T:			BE := be/backend
$T:				  $/bin/x-be-pipestream-tcpwrapper.py
	@$(install-enf)
	@cd $(DIR); ./bin/$(<F) -l -t $(CONN) -b $(BE)


T				 := $(call mkid,$(d)prompt)
DESCRIPTION	   += $T='Interactive session (Python) for Xu88.1 backend'
STRGT			 += $T

$T:		   ENF := EMPTY
$T:			PY := ipython
$T:			BE := $/be/backend
$T:				  $/bin/x-interactive-session.py
	@$(ll) file_target "$@" "Starting interactive session"
	@$(install-enf)
	@cd $(<D);$(PY) -i -- $(<F) -l -b $(BE)
	@$(ll) file_done "$@" "Interactive session ended"

###


#	  ------------ -- 
include				$(MK_SHARE)Core/Main.dirstack-pop.mk
# vim:noet:

