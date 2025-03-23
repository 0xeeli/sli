#
# Debug package: variables, functions and commands in a package recipe
# Test: sli install debug (debug_recipe.sh must be in the current dir)
# Init: # sli init debug
#

debug_install() {
	
	PKG_NAME="debug"
	PKG_VERSION="0.0.0"
	SRC_URL="https://github.com/0xeeli/sli/releases/download"
	TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
	SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
	DL_URL=${SRC_URL}/${PKG_VERSION}/${TARBALL}
	
	# Pre install: check if pkg is already installed
	echo -e "Calling: ${YELLOW}pkg_pre_install()${NC}\n"
	pkg_pre_install "$PKG_NAME" "$PKG_VERSION"
	
	# Time to call download and extract
	#pkg_download_tarball
	#pkg_extract_tarball
	
	# Check package recipe variables
	echo -e "${CYAN}Package Variable${NC}"
	
	echo "PKG_NAME=${PKG_NAME}"
	echo "PKG_VERSION=${PKG_VERSION}"
	echo "SRC_URL=${SRC_URL}"
	echo "TARBALL=${TARBALL}"
	echo "SRC_DIR=${SRC_DIR}"
	echo "DL_URL=${DL_URL}"
	
	# Check paths
	echo -e "\n${CYAN}SLi Paths${NC}"
	
	echo "SLI_DIR=${SLI_DIR}"
	echo "INSTALLED_PKGS=${INSTALLED_PKGS}"
	echo "CACHE_DIR=${CACHE_DIR}"
	echo "PKGS_LIST=${SLI_DIR}/packages.list"
	
	# Package data
	echo -e "\n${CYAN}Package Data${NC}"
	
	echo "PKG_DATA=${PKG_DATA}"
	echo " --> ${PKG_DATA}/pkg.conf"
	echo " --> ${PKG_DATA}/files.list"
	touch ${PKG_DATA}/files.list
	
	# Post install will remove src dir and store pkg version in ${PKG_DATA}/pkg.conf
	# If we want to keep the source file: pkg_post_install "keep_src"
	echo -e "\nCalling: ${YELLOW}pkg_post_install()${NC}"
	pkg_post_install
}

debug_init() {
	echo "⚡️ Debug Initialization"
	print_separator
	echo "Executed: debug_init()"
}

