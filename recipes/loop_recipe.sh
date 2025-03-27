#
# This pool package provides loop and loopd (deamon). It will erase
# loop version from Lit bundle but will not be erased on Lit install.
#

loop_install() {

	PKG_NAME="loop"
	PKG_VERSION="$(pkg_get_version $PKG_NAME)"
	SRC_URL="https://github.com/lightninglabs/loop/releases/download"
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

	# Loop will conflict with LiT Bundle, prefer this version.
	# loop-mode=disable can be set in lit.conf
	if [ -d ${INSTALLED_PKGS}/lit ]; then
		if grep -q ".*loop" ${INSTALLED_PKGS}/lit/files.list 2>/dev/null; then
			echo -e " * ${YELLOW}NOTE:${NC} Loop already installed by lit --> Erasing"
			sed -i '/^\/usr\/local\/bin\/loop$/d' "${INSTALLED_PKGS}/lit/files.list"
			# Store a backup of 'lit loop' to be restored on loop remove
			#cp /usr/local/bin/loop ${INSTALLED_PKGS}/lit
		fi
	fi

	# Systemd service
	config_service_unit "loopd" "Loopd Off/On Chain Bridge" "simple"

	echo "Documentation: https://lightning.engineering/loop/"

	# Post install
	pkg_post_install
}
