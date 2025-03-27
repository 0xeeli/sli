#
# Alby Hub SLi package recipe
#

albyhub_install() {

	PKG_NAME="albyhub"
	PKG_VERSION="$(pkg_get_version $PKG_NAME)"
	SRC_URL="https://github.com/getAlby/hub/releases/download"
	TARBALL="${PKG_NAME}-Server-Linux-x86_64.tar.bz2"
	SRC_DIR="${PKG_NAME}-Server-Linux-x86_64"
	DL_URL=${SRC_URL}/${PKG_VERSION}/${TARBALL}

	# Pre install
	pkg_pre_install "albyhub" "$PKG_VERSION"
	pkg_download_tarball
	pkg_extract_tarball

	# Install to /usr/local/bin
	echo -e "${CYAN}Install path: /usr/local/bin${NC}"
	echo " * Installing: ${PKG_NAME}"
	sudo cp -f ${SRC_DIR}/bin/${PKG_NAME} /usr/local/bin
	echo "/usr/local/bin/${PKG_NAME}" > ${PKG_DATA}/files.list
	
	# Install to /usr/local/lib (shared libraries.so)
	for lib in $(ls ${SRC_DIR}/lib); do
		echo " * Installing: $lib"
		sudo cp -f ${SRC_DIR}/lib/${lib} /usr/local/lib
		echo "/usr/local/lib/${lib}" >> ${PKG_DATA}/files.list
	done
	
	# Systemd service
	config_service_unit "${PKG_NAME}" "Alby Hub Server" "simple"
	
	# Alby Hub don't use a config file, we need additional startup 
	# environment variables. Let's sed!
	echo "Adding environment variables to: ${PKG_NAME}.service"
	sudo sed -i "/AmbientCapabilities=CAP_NET_BIND_SERVICE/a \
Environment=\"PORT=8029\"\n\
Environment=\"WORK_DIR=$HOME/.albyhub\"\n\
Environment=\"LOG_EVENTS=true\"\n\
Environment=\"LDK_GOSSIP_SOURCE=\"" "/etc/systemd/system/${PKG_NAME}.service"
	sudo systemctl daemon-reload
	
	pkg_post_install
}
