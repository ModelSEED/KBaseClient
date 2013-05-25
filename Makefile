THIS_MAKEFILE_PATH:=$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_DIR:=$(shell cd $(dir $(THIS_MAKEFILE_PATH));pwd)
THIS_MAKEFILE:=$(notdir $(THIS_MAKEFILE_PATH))
SRC_PERL = $(wildcard plbin/*.pl)
BIN_DIR = $(THIS_DIR)/bin
BIN_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PERL))))

clean:
	rm $(THIS_DIR)/bin/*
	
gather:
	rm $(THIS_DIR)/plbin/kb*
	rm -rf $(THIS_DIR)/lib/Bio
	cp $(THIS_DIR)/../KBaseFBAModeling/scripts/kbfba-* $(THIS_DIR)/plbin/
	cp $(THIS_DIR)/../workspace_service/scripts/kbws-* $(THIS_DIR)/plbin/
	mkdir $(THIS_DIR)/lib/Bio
	mkdir $(THIS_DIR)/lib/Bio/KBase
	mkdir $(THIS_DIR)/lib/Bio/KBase/workspaceService
	mkdir $(THIS_DIR)/lib/Bio/KBase/fbaModelServices
	mkdir $(THIS_DIR)/lib/Bio/KBase/GenomeAnnotation
	mkdir $(THIS_DIR)/lib/Bio/KBase/SSHAgent
	mkdir -p $(THIS_DIR)/lib/ModelSEED/Client
	mkdir -p $(THIS_DIR)/lib/myRAST
	cp $(THIS_DIR)/../workspace_service/lib/Bio/KBase/workspaceService/Client.pm $(THIS_DIR)/lib/Bio/KBase/workspaceService/Client.pm
	cp $(THIS_DIR)/../workspace_service/lib/Bio/KBase/workspaceService/Helpers.pm $(THIS_DIR)/lib/Bio/KBase/workspaceService/Helpers.pm
	cp $(THIS_DIR)/../KBaseFBAModeling/lib/Bio/KBase/fbaModelServices/Client.pm $(THIS_DIR)/lib/Bio/KBase/fbaModelServices/Client.pm
	cp $(THIS_DIR)/../KBaseFBAModeling/lib/Bio/KBase/fbaModelServices/Helpers.pm $(THIS_DIR)/lib/Bio/KBase/fbaModelServices/Helpers.pm
	cp $(THIS_DIR)/../KBaseFBAModeling/lib/Bio/KBase/Exceptions.pm $(THIS_DIR)/lib/Bio/KBase/Exceptions.pm
	cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/AuthUser.pm $(THIS_DIR)/lib/Bio/KBase/AuthUser.pm
	cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/AuthToken.pm $(THIS_DIR)/lib/Bio/KBase/AuthToken.pm
	cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/Auth.pm $(THIS_DIR)/lib/Bio/KBase/Auth.pm
	cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/SSHAgent/*.pm $(THIS_DIR)/lib/Bio/KBase/SSHAgent/
	cp $(THIS_DIR)/../ModelSEED/lib/ModelSEED/Client/MSSeedSupport.pm $(THIS_DIR)/lib/ModelSEED/Client
	cp $(THIS_DIR)/../ModelSEED/lib/myRAST/ClientTHing.pm $(THIS_DIR)/lib/myRAST
	cp $(THIS_DIR)/../genome_annotation/lib/Bio/KBase/GenomeAnnotation/Client.pm $(THIS_DIR)/lib/Bio/KBase/GenomeAnnotation/Client.pm	

all: 
	for src in $(SRC_PERL) ; do \
		basefile=`basename $$src`; \
		base=`basename $$src .pl`; \
		echo install $(THIS_DIR) $$src $$base ; \
		bash wrap_perl.sh $(THIS_DIR) $$src "bin/$$base" ; \
	done
