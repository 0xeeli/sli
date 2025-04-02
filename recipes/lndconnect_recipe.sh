#
# lndconnect Sli package recipe - https://github.com/LN-Zap/lndconnect
#

lndconnect_install() {

	PKG_NAME="lndconnect"
	PKG_VERSION="$(pkg_get_version $PKG_NAME)"
	SRC_URL="https://github.com/LN-Zap/lndconnect/releases/download"
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
	echo "/usr/local/bin/${PKG_NAME}" > ${PKG_DATA}/files.list

	# Post install
	pkg_post_install
}
