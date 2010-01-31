
default:
	@echo "Build enfilade from directory"
	@echo "E.g. use: make var/enf/name.enf ENF_DIR='var/htdocs/0.empty'"
	@echo "Generates new (overwrites) FeBe content-script and enf.enf."
	# TODO: links, the old demo docs don't have many

ENF_DIR=var/htdocs/0.empty

CWD=$(shell pwd)
CONTENT_LIST=$(ENF_DIR)/content.list
CONTENT_SCRIPT=$(ENF_DIR)/init-content.febe
LINK_SCRIPT=$(ENF_DIR)/init-links.febe

$(CONTENT_SCRIPT): $(CONTENT_LIST)
	@echo "Create a FeBe script for xumain which inserts contents from files"
	create-content-script.py $< > $@

enf: $(CONTENT_SCRIPT) $(LINK_SCRIPT)
	if test -f enf.enf; then rm enf.enf; fi;
	@echo "Insert contents end let xumain create a new enfilade"
	(cd $(ENF_DIR);$(CWD)/bin/green/be_source/xumain < ../$(CONTENT_SCRIPT);mv enf.enf $(CWD))
	@echo "Edit links into the enfilade"
	bin/green/be_source/backend < $(LINK_SCRIPT)
	mv enf.enf var/enfilade/`basename $(ENF_DIR)`.enf


run: bin/pyxi
	cd $(<D); ./$(<F) -d

# :vim: set noexpandtab
