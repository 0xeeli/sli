#
# This pool package provides pool and poold (deamon) and will erase
# pool provided by Lit but will not be erased on Lit install.
#

pool_install() {

	PKG_NAME="pool"
	PKG_VERSION="$(pkg_get_version $PKG_NAME)"
	SRC_URL="https://github.com/lightninglabs/pool/releases/download"
	TARBALL="${PKG_NAME}-linux-amd64-${PKG_VERSION}.tar.gz"
	SRC_DIR="${PKG_NAME}-linux-amd64-${PKG_VERSION}"
	DL_URL=${SRC_URL}/${PKG_VERSION}/${TARBALL}

	# Pre install
	pkg_pre_install "$PKG_NAME" "$PKG_VERSION"
	pkg_download_tarball
	pkg_extract_tarball

	# Install to /usr/local/bin
	echo -e "${CYAN}Install path: /usr/local/bin${NC}"
	echo " * Installing: ${PKG_NAME}"
	sudo cp -f ${SRC_DIR}/${PKG_NAME} /usr/local/bin
	echo " * Installing: ${PKG_NAME}d"
	sudo cp -f "${SRC_DIR}/${PKG_NAME}d" /usr/local/bin

	echo "/usr/local/bin/${PKG_NAME}" > ${PKG_DATA}/files.list
	echo "/usr/local/bin/${PKG_NAME}d" >> ${PKG_DATA}/files.list

	# Pool will conflict with LiT Bundle, prefer this version.
	# pool-mode=disable can be set in lit.conf
	if [ -d ${INSTALLED_PKGS}/lit ]; then
		if grep -q ".*pool" ${INSTALLED_PKGS}/lit/files.list 2>/dev/null; then
			echo -e " * ${YELLOW}NOTE:${NC} Pool already installed by lit --> Erasing"
			sed -i '/^\/usr\/local\/bin\/pool$/d' "${INSTALLED_PKGS}/lit/files.list"
			# Store a backup of 'lit pool' to be restored on pool remove
			#cp /usr/local/bin/pool ${INSTALLED_PKGS}/lit
		fi
	fi

	# Systemd service.
	config_service_unit "poold" "Lightning Pool Daemon" "simple"

	echo "Documentation: https://pool.lightning.engineering/"

	# Post install
	pkg_post_install
}
