#
# Thunderhub Sli package recipe - https://thunderhub.io/
# Setup and install guide: https://docs.thunderhub.io/
#

thunderhub_install() {
	
	PKG_NAME="thunderhub"
	PKG_VERSION="$(pkg_get_version $PKG_NAME)"
	TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
	SRC_URL="https://github.com/apotdevin/thunderhub/archive/refs/tags"
	SRC_DIR="${PKG_NAME}-${PKG_VERSION#v}" # strip the 'v'
	DL_URL=${SRC_URL}/${PKG_VERSION}.tar.gz
	
	# Pre install
	pkg_pre_install "$PKG_NAME" "$PKG_VERSION"
	pkg_download_tarball
	pkg_extract_tarball
	
	# Ensure install path exist and store install_dir in pkg.conf to be
	# used by ${PKG_NAME}_init and on upgrade.
	if [ -f "${PKG_DATA}/pkg.conf" ]; then
		upgrade="yes"
		source ${PKG_DATA}/pkg.conf
	else
		echo -e "\n${CYAN}$PKG_NAME must be built and installed in user space.${NC}"
		read -p "Install path (default $HOME): " path
		if [ -n "$path" ] && [ -d "$path" ]; then
			install_dir="${path}/${PKG_NAME}"
		else
			install_dir="${HOME}/${PKG_NAME}"
		fi
		echo "install_dir=\"${install_dir}\"" >> ${PKG_DATA}/pkg.conf
	fi
	
	# Copy source files to install dir and track it
	echo " * Installing $PKG_NAME : $install_dir"
	mkdir -p ${install_dir}
	cp -a ${SRC_DIR}/* ${install_dir}
	echo "$install_dir" > ${PKG_DATA}/files.list
	
	# Install all the necessary npm modules, build and run
	echo -e "\n${CYAN}Install npm modules and build:${NC} npm must be installed"
	read -p "Do you wish to build $PKG_NAME ? (yes/no) " build
	if [ "$build" == "yes" ]; then
		check_command "npm"
		cd ${install_dir}
		npm install && npm run build #&& npm prune --production
	else
		echo "To install all the necessary modules and build $PKG_NAME:"
		echo " --> cd ${install_dir}"
		echo " --> npm install"
		echo " --> npm run build"
		#echo " --> npm prune --production"
		#npm audit fix
	fi
	
	# Setup instructions
	echo -e "\n${CYAN}Setup and start $PKG_NAME${NC}"
	echo "Setup guide: https://docs.thunderhub.io/setup"
	echo " --> sli init $PKG_NAME"
	echo " --> sli start $PKG_NAME"
	echo -e "\nOr start $PKG_NAME without systemd (init first):"
	echo " --> cd ${install_dir}"
	echo " --> npm start"
	
	pkg_post_install
}

thunderhub_init() {
	echo "⚡️ Thunderhub Initialization"
	print_separator
	
	# Set install and user config path
	source ${PKG_DATA}/pkg.conf
	user_config="${HOME}/.thunderhub/config.yaml"
	echo "Install dir: $install_dir"
	
	# .env.local (avoid erasing it on upgrade)
	echo -e "\nChecking server config: .env.local"
	if [ ! -f ${install_dir}/.env.local ]; then
		echo -e " * Creating server config: ${YELLOW}${install_dir}/.env.local${NC}"
		echo "ACCOUNT_CONFIG_PATH='${HOME}/.thunderhub/config.yaml'" \
			> ${install_dir}/.env.local
	else
		echo -e " --> ${YELLOW}${install_dir}/.env.local${NC}"
	fi
	
	# config.yaml (avoid erasing it on upgrade)
	echo -e "\nChecking user config: config.yaml"
	if [ ! -f "$user_config" ]; then
	
		# Ask for master password and user name
		echo -e "${CYAN}Master password & user name for $PKG_NAME UI${NC}\n"
		read -p "Enter master password: " master_pass
		[ -n "$master_pass" ] || master_pass="MY_PASSWORD"
		read -p "Enter default user name: " user_name
		[ -n "$user_name" ] || user_name="LOGIN_NAME"
		
		echo -e " * Creating user config: ${YELLOW}${user_config}${NC}"
		mkdir -p ${HOME}/.thunderhub
		cat << EOT >> ${user_config}
masterPassword: '$master_pass'
accounts:
  - name: '$user_name'
    serverUrl: '127.0.0.1:10009'
    lndDir: '$HOME/.lnd'
EOT
	else
		echo -e " --> ${YELLOW}${user_config}${NC}"
	fi
	
	# Systemd service unit
	echo -e "\nChecking systemd service unit..."
	service_unit="/etc/systemd/system/${PKG_NAME}.service"
	if [ ! -f "$service_unit" ]; then
		echo -e "Creating: ${YELLOW}${service_unit}${NC}"
		cat << EOF | sudo tee ${service_unit} > /dev/null
[Unit]
Description=Thunderhub
Wants=lnd.service litd.service
After=lnd.service litd.service

[Service]
User=$USER
WorkingDirectory=${install_dir}
ExecStart=npm start
Restart=always
TimeoutSec=120
RestartSec=30
PrivateTmp=true
ProtectSystem=strict

[Install]
WantedBy=multi-user.target
EOF
		echo "${service_unit}" >> ${PKG_DATA}/files.list
		sudo systemctl daemon-reload
		read -p "Do you wish to enable $PKG_NAME on each boot ? (yes/no) " enable
		if [ "$enable" == "yes" ]; then
			echo " * Enabling $PKG_NAME on boot time..."
			sudo systemctl enable ${PKG_NAME} 2>/dev/null
		fi
	else
		echo -e " --> ${YELLOW}${service_unit}${NC}"
	fi
	echo -e "\n${CYAN}Ready to start:${NC} sli start $PKG_NAME"
}
