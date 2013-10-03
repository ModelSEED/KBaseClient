THIS_MAKEFILE_PATH:=$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_DIR:=$(shell cd $(dir $(THIS_MAKEFILE_PATH));pwd)
THIS_MAKEFILE:=$(notdir $(THIS_MAKEFILE_PATH))
SRC_PERL = $(wildcard plbin/*.pl)
BIN_DIR = $(THIS_DIR)/bin
BIN_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PERL))))

clean:
	rm $(THIS_DIR)/bin/*
	
gather:
	if [ !-d $(THIS_DIR)/lib/Bio ] ; then \
		mkdir $(THIS_DIR)/lib/Bio
	fi \
	if [ !-d $(THIS_DIR)/lib/Bio/KBase ] ; then \
		mkdir $(THIS_DIR)/lib/Bio/KBase
	fi \
	if [ -d $(THIS_DIR)/../probabilistic_annotation ] ; then \
		cp $(THIS_DIR)/../probabilistic_annotation/scripts/pa-* $(THIS_DIR)/plbin/
		rm -rf $(THIS_DIR)/lib/Bio/KBase/probabilistic_annotation
		mkdir $(THIS_DIR)/lib/Bio/KBase/probabilistic_annotation
		cp $(THIS_DIR)/../probabilistic_annotation/lib/Bio/KBase/probabilistic_annotation/Client.pm $(THIS_DIR)/lib/Bio/KBase/probabilistic_annotation/Client.pm
		cp $(THIS_DIR)/../probabilistic_annotation/lib/Bio/KBase/probabilistic_annotation/Helpers.pm $(THIS_DIR)/lib/Bio/KBase/probabilistic_annotation/Helpers.pm		
	fi \
	if [ -d $(THIS_DIR)/../workspace_service ] ; then \
		cp $(THIS_DIR)/../workspace_service/scripts/ws-* $(THIS_DIR)/plbin/
		cp $(THIS_DIR)/../workspace_service/scripts/kbws-* $(THIS_DIR)/plbin/
		rm -rf $(THIS_DIR)/lib/Bio/KBase/workspaceService
		mkdir $(THIS_DIR)/lib/Bio/KBase/workspaceService
		cp $(THIS_DIR)/../workspace_service/lib/Bio/KBase/workspaceService/Client.pm $(THIS_DIR)/lib/Bio/KBase/workspaceService/Client.pm
		cp $(THIS_DIR)/../workspace_service/lib/Bio/KBase/workspaceService/Helpers.pm $(THIS_DIR)/lib/Bio/KBase/workspaceService/Helpers.pm
	fi \
	if [ -d $(THIS_DIR)/../auth ] ; then \
		rm -rf $(THIS_DIR)/lib/Bio/KBase/*.pm
		mkdir $(THIS_DIR)/lib/Bio/KBase/SSHAgent
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/AuthUser.pm $(THIS_DIR)/lib/Bio/KBase/AuthUser.pm
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/AuthToken.pm $(THIS_DIR)/lib/Bio/KBase/AuthToken.pm
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/Auth.pm $(THIS_DIR)/lib/Bio/KBase/Auth.pm
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/SSHAgent/*.pm $(THIS_DIR)/lib/Bio/KBase/SSHAgent/	
	fi \
	if [ -d $(THIS_DIR)/../KBaseFBAModeling ] ; then \
		cp $(THIS_DIR)/../KBaseFBAModeling/scripts/ga-* $(THIS_DIR)/plbin/
		cp $(THIS_DIR)/../KBaseFBAModeling/scripts/fba-* $(THIS_DIR)/plbin/
		cp $(THIS_DIR)/../KBaseFBAModeling/scripts/kbfba-* $(THIS_DIR)/plbin/
		rm -rf $(THIS_DIR)/lib/Bio/KBase/fbaModelServices
		mkdir $(THIS_DIR)/lib/Bio/KBase/fbaModelServices
		cp $(THIS_DIR)/../KBaseFBAModeling/lib/Bio/KBase/fbaModelServices/Client.pm $(THIS_DIR)/lib/Bio/KBase/fbaModelServices/Client.pm
		cp $(THIS_DIR)/../KBaseFBAModeling/lib/Bio/KBase/fbaModelServices/Helpers.pm $(THIS_DIR)/lib/Bio/KBase/fbaModelServices/Helpers.pm
		cp $(THIS_DIR)/../KBaseFBAModeling/lib/Bio/KBase/Exceptions.pm $(THIS_DIR)/lib/Bio/KBase/Exceptions.pm	
	fi \
	if [ -d $(THIS_DIR)/../MSSeedSupportServer ] ; then \
		rm -rf $(THIS_DIR)/lib/Bio/ModelSEED/MSSeedSupportServer
		mkdir $(THIS_DIR)/lib/Bio/ModelSEED/MSSeedSupportServer
		cp $(THIS_DIR)/../MSSeedSupportServer/lib/Bio/ModelSEED/MSSeedSupportServer/Client.pm $(THIS_DIR)/lib/Bio/ModelSEED/MSSeedSupportServer/Client.pm
	fi \
	if [ -d $(THIS_DIR)/../ModelSEED ] ; then \
		rm -rf $(THIS_DIR)/lib/myRAST
		mkdir $(THIS_DIR)/lib/myRAST
		cp $(THIS_DIR)/../ModelSEED/lib/myRAST/ClientTHing.pm $(THIS_DIR)/lib/myRAST
	fi \
	if [ -d $(THIS_DIR)/../genome_annotation ] ; then \
		rm -rf $(THIS_DIR)/lib/Bio/KBase/genome_annotation
		mkdir $(THIS_DIR)/lib/Bio/KBase/genome_annotation
		cp $(THIS_DIR)/../genome_annotation/lib/Bio/KBase/GenomeAnnotation/Client.pm $(THIS_DIR)/lib/Bio/KBase/GenomeAnnotation/Client.pm	
	fi \
				
all: 
	for src in $(SRC_PERL) ; do \
		basefile=`basename $$src`; \
		base=`basename $$src .pl`; \
		echo install $(THIS_DIR) $$src $$base ; \
		bash wrap_perl.sh $(THIS_DIR) $$src "bin/$$base" ; \
	done
