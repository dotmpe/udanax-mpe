
default:
	@echo "make var/enf/%.enf ENF_DIR=path/to/files"
	@echo "  Build enfilade from directory"
	@echo "  E.g. use: make var/enf/name.enf ENF_DIR='var/htdocs/0.empty'"
	@echo "  Generates new (overwrites) FeBe content-script and enf.enf."
	# TODO: links, the old demo docs don't have many

ENF_DIR=var/htdocs/0.empty

CWD=$(shell pwd)
CONTENT_LIST=$(ENF_DIR)/content.list
CONTENT_SCRIPT=$(ENF_DIR)/init-content.febe
LINK_SCRIPT=$(ENF_DIR)/init-links.febe

#$(CONTENT_SCRIPT): $(CONTENT_LIST)
#	@echo "Create a FeBe script for xumain which inserts contents from files"
#	create-content-script.py $< > $@

enf: $(CONTENT_SCRIPT) $(LINK_SCRIPT)
	if test -f enf.enf; then rm enf.enf; fi;
	@echo "Insert contents end let xumain create a new enfilade"
	@(cd $(ENF_DIR);\
		$(CWD)/bin/green/be_source/xumain < ../../../$(CONTENT_SCRIPT);\
		mv enf.enf $(CWD));
	@echo "Edit links into the enfilade"
	@bin/green/be_source/backend < $(LINK_SCRIPT); echo
	@mv enf.enf var/enf/`basename $(ENF_DIR)`.enf;\
		rm gmon.out backenderror


run: bin/pyxi
	cd $(<D); ./$(<F)

debug: bin/pyxi
	cd $(<D); ./$(<F) -d

test:
	python test/Tumbler.py

# :vim: set noexpandtab
