#!/bin/bash

# This is the root of thi git repo (janus-packages) 
packages_folder=$(pwd)

# Automatically check for distro flavour
check_os_tag() {
	local distro
	distro="$(./get_plat_tag.sh)"

	local ostag
	case ${distro} in
	ASTRALINUX_64*)
		ostag="a2"
		;;
	UBUNTU20_64*)
		ostag="u20"
		;;
	UBUNTU18_64)
		ostag="u18"
		;;
	RHEL8*)
		ostag="r8"
		;;
	RHEL7*)
		ostag="r7"
		;;
	esac
	echo "${distro}.${ostag}"
}
os_tag="$(check_os_tag)"

# The packaging process begins...
while read -r line; do
	name=${line/zimbra\//}
	zimbra_name=$(echo "zimbra-$name" | sed 's/thirdparty\///g')
	echo "######## $zimbra_name ###############################################################"
	cd "$packages_folder/$line" || exit
	
	# Debian based if branch
	if [[ "${os_tag%%.*}" =~ "UBUNTU" ]] ||
		[[ "${os_tag%%.*}" =~ "ASTRALINUX" ]]; then
		if [[ $(ls build/"${os_tag%%.*}"/zimbra-*.deb 2>&1) == *"No such"* ]]; then
			if [[ $line == "thirdparty"* ]]; then
				make setup
				if [[ $(grep -r "^getsrc:" Makefile) != "" ]]; then
					make getsrc
				fi
				if [[ $line == "thirdparty/openssl" ]]; then
					make build
				fi
				make build_deb
				if [[ $1 != "clean" ]]; then
					if [[ $(ls build/"${os_tag%%.*}"/zimbra-*.deb 2>&1) == *"No such"* ]]; then
						echo "Compilation error!"
						exit 1
					else
						dpkg -i build/"${os_tag%%.*}"/zimbra-*.deb
					fi
				fi
			fi
		fi
	else
		# RedHat based if branch
		if [[ $(ls build/"${os_tag%%.*}"/"$zimbra_name"/rpm/RPMS/x86_64/*.rpm 2>&1) == *"No such"* ]]; then
			if [[ $line == "thirdparty"* ]]; then
				make setup
				if [[ $(grep -r "^getsrc:" Makefile) != "" ]]; then
					make getsrc
				fi
				if [[ $line == "thirdparty/openssl" ]]; then
					make build
				fi
				make build_rpm
				if [[ $1 != "clean" ]]; then
					if [[ $(ls build/"${os_tag%%.*}"/"$zimbra_name"/rpm/RPMS/x86_64/*.rpm 2>&1) == *"No such"* ]]; then
						echo "Compilation error!"
						exit 1
					else
						rpm -i build/"${os_tag%%.*}"/"$zimbra_name"/rpm/RPMS/x86_64/zimbra-*.rpm
					fi
				fi
			fi
		fi
	fi
done < build-order

# Last steps to build a tgz containing the previously generated packages.
cd "$packages_folder" || exit

if [ -d artifacts ]; then
	rm -rf artifacts
fi

tag=${os_tag##*.}-$(date +'%Y%m%d')
mkdir -p "artifacts/janus-gateway-${tag}"

if [[ "${os_tag%%.*}" =~ "UBUNTU" ]] ||
	[[ "${os_tag%%.*}" =~ "ASTRALINUX" ]]; then
	find . -name "*.deb" \
		-and -not -name "*-dbg*" \
		-exec cp {} "artifacts/janus-gateway-${tag}" \;
else
	find . -name "*.rpm" \
		-and -not -name "*.src.rpm" \
		-and -not -name "*-debuginfo-*" \
		-and -not -name "*-debugsource-*" \
		-exec cp {} "artifacts/janus-gateway-${tag}" \;
fi

cd artifacts || exit
tar cfvz "janus-gateway-${tag}.tgz" \
	"janus-gateway-${tag}"
