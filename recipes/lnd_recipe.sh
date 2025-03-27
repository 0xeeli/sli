#
# LND SLi package recipe - Lightning daemon
#

lnd_install() {

	PKG_NAME="lnd"
	PKG_VERSION="$(pkg_get_version $PKG_NAME)"
	SRC_URL="https://github.com/lightningnetwork/lnd/releases/download"
	TARBALL="${PKG_NAME}-linux-amd64-${PKG_VERSION}.tar.gz"
	SRC_DIR="${PKG_NAME}-linux-amd64-${PKG_VERSION}"
	DL_URL=${SRC_URL}/${PKG_VERSION}/${TARBALL}

	# Pre install
	pkg_pre_install "lnd" "$PKG_VERSION"
	pkg_download_tarball
	pkg_extract_tarball

	# Install to /usr/local/bin
	echo -e "${CYAN}Install path: /usr/local/bin${NC}"
	echo " * Installing: ${PKG_NAME}"
	sudo cp -f ${SRC_DIR}/${PKG_NAME} /usr/local/bin
	echo " * Installing: lncli"
	sudo cp -f "${SRC_DIR}/lncli" /usr/local/bin

	echo "/usr/local/bin/${PKG_NAME}" > ${PKG_DATA}/files.list
	echo "/usr/local/bin/lncli" >> ${PKG_DATA}/files.list

	# LND/lncli will conflict with LiT Bundle, prefer this version.
	# lnd-mode=remote can be set in lit.conf
	if [ -d ${INSTALLED_PKGS}/lit ]; then
		if grep -q "^lncli|" ${INSTALLED_PKGS}/lit/files.list; then
			echo -e " * ${YELLOW}NOTE:${NC} Lncli already installed by lit --> Erasing"
			sed -i '/^\/usr\/local\/bin\/lncli$/d' "${INSTALLED_PKGS}/lit/files.list"
			# Store a backup of 'lit lncli' to be restored on lnd remove
			#cp /usr/local/bin/lncli ${INSTALLED_PKGS}/lit
		fi
	fi

	# Systemd service
	config_service_unit "lnd" "Lightning Node Daemon" "notify"
	pkg_post_install
}

# Basic and working lnd.conf to get started
lnd_config_file() {
	cat << EOT
#
# LND Configuration file: lnd.conf
#

# --- Wallet ---

#wallet-unlock-password-file=${WALLET_PASS}
#wallet-unlock-allow-create=true

# --- Node ---

# Set a nice name for your node
alias=${USER}-LND

[fee]

# Optional URL for external fee estimation.
fee.url=https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json

[rpcmiddleware]

# Used by Lit UI and other backend
rpcmiddleware.enable=true

[bitcoin]

# Use a neutrino light back-end so we don't need a full ₿ node.
bitcoin.node=neutrino

# Connect to mainnet
bitcoin.mainnet=1
bitcoin.active=1

# The seed DNS server(s) to use for initial peer discovery.
bitcoin.dnsseed=nodes.lightning.directory,soa.nodes.lightning.directory
EOT
}

# Initialize LND
lnd_init() {	
	check_command "lnd"
	print_header "⚡️ LND Initialization"
	
	# lnd.conf
	if [ ! -f "$LND_CONF" ]; then
		echo -e "Creating config file: ${YELLOW}$LND_CONF${NC}"
		mkdir -p ${HOME}/.lnd && touch ${LND_CONF}
		lnd_config_file > ${LND_CONF}
		echo "Setting secure permissions: read only by $USER (0600)"
		chmod 0600 ${LND_CONF}
	else
		echo -e "Config file already exist:"
		echo -e " --> ${YELLOW}$LND_CONF${NC}"
	fi
	
	# We can now start LND and create a Wallet if any
	echo "" && service_start "start" "lnd"
	if [ ! -f "$WALLET_DB" ]; then
		echo ""
		echo -e "${CYAN}Wallet Creation${NC}"
		wallet_init
	else
		echo -e "\n🔒 Found Wallet database"
		echo -e " --> ${YELLOW}$WALLET_DB${NC}"
		[ -f "$WALLET_PASS" ] && echo -e " --> ${YELLOW}$WALLET_PASS${NC}"
	fi
	
	# Wallet auto-unlock
	if [ ! "$(grep ^wallet-unlock-password-file $LND_CONF)" ]; then
		echo ""
		echo -e "${CYAN}Wallet Auto-unlock${NC}"
		echo "Let LND auto-unlock the wallet on startup (useful)"
		echo ""
		read -p "Do you wish to enable Wallet auto-unlock ? (yes/no) " auto_unlock
		if [ "$auto_unlock" == "yes" ]; then
			echo "Enabling auto-unlock in: $LND_CONF"
			sed -i 's/#wallet-unlock-password-file=/wallet-unlock-password-file=/' "$LND_CONF"
			sed -i 's/#wallet-unlock-allow-create=true/wallet-unlock-allow-create=true/' "$LND_CONF"
			echo "Restarting lnd to apply auto-unlock..."
			service_restart "restart" "lnd"
		else
			echo "Edit lnd.conf if you want auto-unlock or run again: sli init"
		fi
	else
		echo "Wallet auto-unlock is enabled"
	fi
}
