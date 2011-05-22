include                $(MK_SHARE)Core/Main.dirstack.mk

MK                  += $/Rules.mk



### Old rules

_default:
	@echo "make var/enf/%.enf ENF_DIR=path/to/files"
	@echo "  Build enfilade from directory"
	@echo "  E.g. use: make var/enf/name.enf ENF_DIR='var/htdocs/0.empty'"
	@echo "  Generates new (overwrites) FeBe content-script and enf.enf."
	@echo "Run"
	@echo "  run - for pyxi frontend"
	@echo "  server - for TCP server"
	# TODO: links, the old demo docs don't have many

#$(CONTENT_SCRIPT): $(CONTENT_LIST)
#	@echo "Create a FeBe script for xumain which inserts contents from files"
#	create-content-script.py $< > $@

### end old


ENF_DIR=var/htdocs/0.empty

CONTENT_LIST=$(ENF_DIR)/content.list
CONTENT_SCRIPT=$(ENF_DIR)/init-content.febe
LINK_SCRIPT=$(ENF_DIR)/init-links.febe


CLN += $(shell find $/ -iname '*.pyc')


### Special targets

T                 := $(call mkid,$(d)enf)
DESCRIPTION       += $(T)='Build an enfilade from CONTENT_SCRIPT and LINK_SCRIPT'
STRGT             += $(T)

$(T): $(CONTENT_SCRIPT) $(LINK_SCRIPT)
	if test -f enf.enf; then rm enf.enf; fi;
	@echo "Insert contents end let xumain create a new enfilade"
	@(cd $(ENF_DIR);\
		$d/bin/green/be_source/xumain < ../../../$(CONTENT_SCRIPT);\
		mv enf.enf $d);
	@echo "Edit links into the enfilade"
	@bin/green/be_source/backend < $(LINK_SCRIPT); echo
	@mv enf.enf var/enf/`basename $(ENF_DIR)`.enf;\
		rm gmon.out backenderror


T                 := $(call mkid,$drun)
DESCRIPTION       += $(T)='Run pyxi normally'
STRGT             += $(T)

$(T):              $/bin/pyxi
	@cd $(<D); ./$(<F)


T                 := $(call mkid,$ddebug)
DESCRIPTION       += $(T)='Run pyxi in verbose mode'
STRGT             += $(T)

$(T):                $/bin/pyxi
	@cd $(<D); ./$(<F) -d

_test:
	python test/Tumbler.py


T                 := $(call mkid,$(d)server)
DESCRIPTION       += $T='Run server with -t CONN -b BE'
STRGT             += $T

$T:           DIR := $/
$T:          CONN := localhost:55146
$T:            BE := be/backend
$T:                  $/bin/x-be-pipestream-tcpwrapper.py
	cd $(DIR); ./bin/$(<F) -l -t $(CONN) -b $(BE)


T                 := $(call mkid,$(d)prompt)
DESCRIPTION       += $T='Interactive session (Python) for Xu88.1 backend'
STRGT             += $T

$T:            PY := ipython
$T:            BE := $/be/backend
$T:                  $/bin/x-interactive-session.py
	@$(ll) file_target "$@" "Starting interactive session"
	@cd $(<D);$(PY) -i -- $(<F) -l -b $(BE)
	@$(ll) file_done "$@" "Interactive session ended"

###


#      ------------ -- 
include                $(MK_SHARE)Core/Main.dirstack-pop.mk
# vim:noet:

