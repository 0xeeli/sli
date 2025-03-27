#
# Lightning Terminal SLi package recipe
#

lit_install() {

	PKG_NAME="lit"
	PKG_VERSION="$(pkg_get_version $PKG_NAME)"
	SRC_URL="https://github.com/lightninglabs/lightning-terminal/releases/download"
	TARBALL="lightning-terminal-linux-amd64-${PKG_VERSION}.tar.gz"
	SRC_DIR="lightning-terminal-linux-amd64-${PKG_VERSION}"
	DL_URL=${SRC_URL}/${PKG_VERSION}/${TARBALL}

	# Pre install
	pkg_pre_install "lit" "$PKG_VERSION"
	pkg_download_tarball
	pkg_extract_tarball

	# Install to /usr/local/bin
	echo -e "${CYAN}Install path: /usr/local/bin${NC}"
	for bin in $(ls $SRC_DIR); do
		# Handle conflict with loop, pool and lncli
		if [ ! -d ${INSTALLED_PKGS}/${bin} ] && ! grep -q "${bin}" "${INSTALLED_PKGS}/lnd/files.list" 2>/dev/null; then
			echo " * Installing: $bin"
			sudo cp -f ${SRC_DIR}/${bin} /usr/local/bin
			echo "/usr/local/bin/$bin" >> ${PKG_DATA}/files.list
		else
			echo -e " ! Skipping  : ${RED}$bin${NC}"
		fi
	done

	# Systemd service
	config_service_unit "litd" "Lightning Terminal (LiT)" "notify"
	pkg_post_install
}

# Basic and working lit.conf to get started
lit_config_file() {
	cat << EOT
#
# LiTd Configuration file: lit.conf
#
uipassword=
lnd-mode=integrated

# --- Wallet ---

#lnd.wallet-unlock-password-file=${WALLET_PASS}
#lnd.wallet-unlock-allow-create=true

# --- Node ---

# Set a nice name for your node
lnd.alias=${USER}-Node

# Optional URL for external fee estimation.
lnd.fee.url=https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json

# Used by Lit UI and other backend
lnd.rpcmiddleware.enable=true

# --- Bitcoin ---

# Use a neutrino light back-end so we don't need a full ₿ node.
lnd.bitcoin.node=neutrino

# Connect to mainnet
lnd.bitcoin.mainnet=1
lnd.bitcoin.active=1

# The seed DNS server(s) to use for initial peer discovery.
lnd.bitcoin.dnsseed=nodes.lightning.directory,soa.nodes.lightning.directory
EOT
}

# Initialize LiTd
lit_init() {
	check_command "litd"
	print_header "⚡️ Lit Initialization"
	
	# lit.conf
	if [ ! -f "$LIT_CONF" ]; then
		echo -e "Creating config file: ${YELLOW}$LIT_CONF${NC}"
		mkdir -p ${HOME}/.lit && touch ${LIT_CONF}
		lit_config_file > ${LIT_CONF}
		echo "Setting secure permissions: read only by $USER (0600)"
		chmod 0600 ${LIT_CONF}
	else
		echo -e "Config file already exist:"
		echo -e " --> ${YELLOW}$LIT_CONF${NC}"
	fi
	
	# Check if uipassword= is empty and offer to creat random password
	ui_password=$(awk -F= '$1=="uipassword"{print $2}' "$LIT_CONF")
	if [ -z "$ui_password" ]; then
		echo ""
		echo -e "${CYAN}Password for Lit Web UI${NC}"
		read -p "Create a secure password ? (yes/no) " gen_uipassword
		if [ "$gen_uipassword" == "yes" ]; then
			password_init ui-password
		fi
	else
		echo " --> uipassword= is set"
	fi
	
	# We can now start litd and create a Wallet if any
	echo "" && service_start "start" "litd"
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
	if [ ! "$(grep ^lnd.wallet-unlock-password-file $LIT_CONF)" ]; then
		echo ""
		echo -e "${CYAN}Wallet Auto-unlock${NC}"
		echo "Let litd auto-unlock the wallet on startup (useful)"
		echo ""
		read -p "Do you wish to enable Wallet auto-unlock ? (yes/no) " auto_unlock
		if [ "$auto_unlock" == "yes" ]; then
			echo "Enabling auto-unlock in: $LIT_CONF"
			sed -i 's/#lnd.wallet-unlock-password-file=/lnd.wallet-unlock-password-file=/' "$LIT_CONF"
			sed -i 's/#lnd.wallet-unlock-allow-create=true/lnd.wallet-unlock-allow-create=true/' "$LIT_CONF"
			echo "Restarting litd to apply auto-unlock..."
			service_restart "restart" "litd"
		else
			echo "Edit lit.conf if you want auto-unlock or run again: sli init"
		fi
	else
		echo "Wallet auto-unlock is enabled"
	fi
}
