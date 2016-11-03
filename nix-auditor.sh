#!/bin/bash
# Nix-auditor - A simple Ubuntu / Redhat / CentOS audit script (which may run on other Linux variants)
# Nix-auditor should be run as root
# v0.20 Matt Byrne - November 2016
clear
echo ===========================================================
echo Nix-auditor v0.20 - Matt Byrne, November 2016
echo 
echo A simple Ubuntu / Redhat / CentOS and Debian Audit Script
echo ===========================================================
FILENAME=$1 
if [ "$FILENAME" = "" ]
then
	echo ""	
	echo "Error: No filename entered."
	echo ""
	echo "Usage- ./nix-auditor.sh <filename>"
	exit
fi

FILECHECK=`ls | grep $FILENAME`

if [ "$FILECHECK" = "$FILENAME" ] 
then 
	echo ""
	echo "Filename already exists. Overwrite <y/n>?"
	read RESPONSE >> $FILENAME
	if [ "$RESPONSE" = "y" ]
	then 
		echo "Overwriting file..."
	else
		echo "Exiting. Please re-run with different filename"
		exit
	fi
fi
clear
echo "================================================================" | tee $FILENAME
echo "Nix-auditor v0.20 Scan: Initiated `date`" | tee -a $FILENAME
echo ""
echo "A simple Ubuntu / Redhat / CentOS and Debian Audit Script" | tee -a $FILENAME
echo "================================================================" | tee -a $FILENAME
echo ""
ID=$(id | cut -c 5) 
if [ "$ID" != 0 ]; then
	echo "You need to run nix-auditor as root....Please "su" to "root!!!""	
	exit
	else
echo "Do you want to list (optional):"
echo ""
echo "	ALL World Readable Files?"
echo "	ALL World Writable Files?"
echo "	ALL SETUID Files?"
echo "	ALL SETGID Files?"
echo "	ALL Installed Software Packages?" 
echo ""
echo "WARNING: These File checks take considerably longer than the standard checks."  
echo ""
echo "Perform Extra File Checks Listed Above?: <y/n>?"
	read RESPONSE >> $FILENAME
	if [ "$RESPONSE" = "y" ]
	then 
	        echo "" 	
		echo "nix-auditor is performing the File Checks this may take a while...."
		echo "" >> .files_tmp 
		echo "Listing World Readable / Writable Files:" >> .files_tmp
		echo ========================================= >> .files_tmp 
		echo "" >> .files_tmp
		find / -type f \( -perm -a+r -o -perm -a+w \) -not -regex '.*/proc/*.*' -not -regex '.*/dev/*.*' ! -type l -exec ls -ld '{}' \; >> .files_tmp
		echo "" >> .files_tmp 
		echo "Listing SETUID / SETGID Files:" >> .files_tmp 
		echo =============================== >> .files_tmp 
		echo "" >> .files_tmp
		find / -type f \( -perm -4000 -o -perm -2000 \) -not -regex '.*/proc/*.*' -not -regex '.*/dev/*.*' -exec ls -ld '{}' \; >> .files_tmp
		echo "" >> .files_tmp
		echo "Listing installed Software Packages:" >> .files_tmp 
		echo ===================================== >> .files_tmp
		echo "" >> .files_tmp
		if [ -f /bin/rpm ] ; then
		rpm -qa >> .files_tmp 
		elif [ -f /usr/bin/rpm ] ; then
		rpm -qa >> .files_tmp 
		fi
	        if [ -f /bin/dpkg ] ; then
		dpkg --list >> .files_tmp	
		elif [ -f /usr/bin/dpkg ] ; then
		dpkg --list >> .files_tmp
		fi
	fi	
fi
echo ""
echo "nix-auditor is now performing the standard checks, not long now...."
echo "" >> $FILENAME
echo Hostname: >> $FILENAME
echo =========== >> $FILENAME
hostname >> $FILENAME
echo "" >> $FILENAME
echo Linux Distribution: >> $FILENAME
echo =================== >> $FILENAME
echo "" >> $FILENAME
echo "Linux version currently in use:" >> $FILENAME
cat /etc/issue >> $FILENAME
if [ -f /usr/bin/lsb_release ] ; then
	/usr/bin/lsb_release -dric | grep -v "No LSB" >> $FILENAME
fi
if [ -f /bin/lsb_release ] ; then
	/bin/lsb_release -dric >> $FILENAME
fi
echo "" >> $FILENAME
echo Kernel Version: >> $FILENAME
echo ================ >> $FILENAME
uname -a >> $FILENAME
echo "" >> $FILENAME
echo "Reference Linux supported OS info:" >> $FILENAME
echo =================================== >> $FILENAME
echo "CentOS < 4 is End of Life (EoL), CentOS 4 EoL date: February 29th, 2012" >> $FILENAME
echo "CentOS 5 EoL date: March 31st, 2017" >> $FILENAME 
echo "https://wiki.centos.org/About/Product" >> $FILENAME
echo "" >> $FILENAME
echo "RHEL < 3 is EoL, RHEL 3 EoL date: January 30, 2014" >> $FILENAME
echo "RHEL 4 EoL date: March 31, 2017" >> $FILENAME
echo "https://access.redhat.com/support/policy/updates/errata" >> $FILENAME
echo "" >> $FILENAME
echo "Ubuntu < 12.04 LTS is EoL, Ubuntu 12.04 LTS EoL date: April 2017" >> $FILENAME
echo "https://www.ubuntu.com/info/release-end-of-life" >> $FILENAME
echo "" >> $FILENAME
echo "Debian < 7.0 is EoL, Debian 7.0 EoL date: May 2018 (LTS)" >> $FILENAME
echo "https://wiki.debian.org/DebianReleases" >> $FILENAME
echo "" >> $FILENAME
echo Network Interfaces: >> $FILENAME
echo =================== >> $FILENAME
ifconfig | grep -B 100 lo | grep -v lo | grep -B 1 "inet " >> $FILENAME 
echo "" >> $FILENAME
echo Routing Info: >> $FILENAME
echo ============= >> $FILENAME
route -n | grep -v Kernel >> $FILENAME
echo "" >> $FILENAME
echo "IP Forwarding Enabled? (1=Enabled, 0=Disabled):" >> $FILENAME
echo ================================================ >> $FILENAME
if [ -f /etc/sysctl.conf ] ; then
	cat /etc/sysctl.conf | grep ipv4.ip_forward >> $FILENAME
fi
echo "" >> $FILENAME
echo netstat -an output: >> $FILENAME
echo =================== >> $FILENAME
netstat -anp | grep -B 100 Active | grep -v Active | grep -v 127.0.0.1 >> $FILENAME 
echo "" >> $FILENAME
echo Contents of /etc/hosts: >> $FILENAME
echo ======================= >> $FILENAME
cat /etc/hosts >> $FILENAME
echo "" >> $FILENAME
echo "Listing Sensitive File & Folder Permissions:" >> $FILENAME
echo ============================================= >> $FILENAME
if [ -f /etc/passwd ] ; then
	ls -l /etc/passwd >> $FILENAME
fi
if [ -f /etc/passwd- ] ; then
	ls -l /etc/passwd- >> $FILENAME
fi
if [ -f /etc/shadow ] ; then
	ls -l /etc/shadow >> $FILENAME
fi
if [ -f /etc/shadow- ] ; then
	ls -l /etc/shadow- >> $FILENAME
fi
if [ -f /etc/sudoers ] ; then
	ls -l /etc/sudoers >> $FILENAME
fi
if [ -d /root ] ; then
	ls -ld /root >> $FILENAME
fi
if [ -d /root/.ssh ] ; then
	ls -ld /root/.ssh >> $FILENAME
fi
if [ -d /root/.ssh ] ; then
	ls -l /root/.ssh | grep -v total >> $FILENAME
fi
if [ -f /root/.bash_history ] ; then
	ls -l /root/.bash_history >> $FILENAME
fi
if [ -f /etc/hosts.equiv ] ;then
	ls -l /etc/hosts.equiv >> $FILENAME
fi
echo "" >> $FILENAME
echo Listing uid 0 accounts: >> $FILENAME
echo ======================= >> $FILENAME
awk -F: '{if ($3=="0") print$1}' /etc/passwd >> $FILENAME
echo "" >> $FILENAME
echo "List members of the wheel group (i.e. root users):" >> $FILENAME
echo =================================================== >> $FILENAME
cat /etc/group | grep wheel >> $FILENAME
echo "" >> $FILENAME
echo "List Accounts with blank passwords (if any):" >> $FILENAME
echo ============================================= >> $FILENAME
if [ -f /etc/shadow ] ; then
      echo `awk -F: '{if ($2=="") print $1}' /etc/shadow` >> $FILENAME
else
      echo `awk -F: '{if ($2=="") print $1}' /etc/passwd` >> $FILENAME
fi
echo "" >> $FILENAME
echo Listing Last Time Users Logged On: >> $FILENAME
echo ================================== >> $FILENAME
lastlog >> $FILENAME
echo "" >> $FILENAME
echo Listing Potentially Useful Utilities: >> $FILENAME
echo ===================================== >> $FILENAME
find / -type f -name rlogin > .find_tmp
find / -type f -name rsh >> .find_tmp
find / -type f -name wget >> .find_tmp
find / -type f -name nc >> .find_tmp
find / -type f -name netcat >> .find_tmp
find / -type f -name tftp >> .find_tmp
find / -type f -name ftp >> .find_tmp
find / -type f -name ssh >> .find_tmp
find / -type f -name telnet >> .find_tmp
find / -type f -name nmap >> .find_tmp
find / -type f -name perl >> .find_tmp
find / -type f -name python >> .find_tmp
find / -type f -name ruby >> .find_tmp
for i in `cat .find_tmp`
do
    	TARGET=${i}
    	ls -l ${TARGET} >> $FILENAME
done
rm .find_tmp
echo "" >> $FILENAME
echo "Listing /etc/hosts.allow configuration (if populated):" >> $FILENAME
echo ======================================================= >> $FILENAME
egrep -v '^.{0}#' /etc/hosts.allow >> $FILENAME
echo "" >> $FILENAME
echo "Listing /etc/hosts.deny configuration (if populated):" >> $FILENAME
echo ====================================================== >> $FILENAME
egrep -v '^.{0}#' /etc/hosts.deny >> $FILENAME
echo "" >> $FILENAME
echo "Listing SELinux Configuration (if present):" >> $FILENAME
echo "===========================================" >> $FILENAME
if [ -f /etc/selinux/config ] ; then
	cat /etc/selinux/config >> $FILENAME
fi
echo "" >> $FILENAME
echo "Listing /etc/hosts.equiv file (if present):" >> $FILENAME
echo ============================================ >> $FILENAME
if [ -f /etc/hosts.equiv ] ; then
	cat /etc/hosts.equiv >> $ FILENAME
fi
echo "" >> $FILENAME
echo "Listing User's .rhosts files (if present):" >> $FILENAME
echo =========================================== >> $FILENAME
find /home -type f -name .rhosts > .rhosts_tmp 
for j in `cat .rhosts_tmp`
do 
	TARGET=${j}
	ls -l ${TARGET} >> $FILENAME
	echo "" >> $FILENAME
	echo "Contents of ${TARGET}:" >> $FILENAME
	cat ${TARGET} >> $FILENAME
	echo "" >> $FILENAME
done
rm .rhosts_tmp
echo "" >> $FILENAME
echo "Listing User's .ssh file permissions (if present):" >> $FILENAME
echo =================================================== >> $FILENAME
find /home -type d -name .ssh > .ssh_tmp
for k in `cat .ssh_tmp`
do
	TARGET=${k}
	ls -ld ${TARGET} >> $FILENAME
	echo "" >> $FILENAME
	echo "Contents of ${TARGET}:" >> $FILENAME
	ls -l ${TARGET} | grep -v total >> $FILENAME
	echo "" >> $FILENAME
done
rm .ssh_tmp
echo "" >> $FILENAME
echo "Listing FTP User Permissions (if any):" >> $FILENAME
echo ======================================= >> $FILENAME
if [ -f /etc/ftpusers ] ; then
	cat /etc/ftpusers >> $FILENAME
fi 
if [ -f /etc/vsftpd.conf ] ; then
	cat /etc/vsftp.conf >> $FILENAME
fi
if [ -f /etc/vsftpd/vsftpd.conf ] ; then
	cat /etc/vsftpd/vsftpd.conf >> $FILENAME
fi
echo "" >> $FILENAME
echo "Listing NFS Exports (if any):" >> $FILENAME
echo =============================== >> $FILENAME
if [ -f /etc/exports ] ; then
      cat /etc/exports >> $FILENAME
fi
echo "" >> $FILENAME
echo "Listing SNMP Configuration (if any):" >> $FILENAME
echo ===================================== >> $FILENAME
if [ -f /etc/snmp/snmpd.conf ] ; then
	cat /etc/snmp/snmpd.conf >> $FILENAME
fi
echo "" >> $FILENAME
echo "Listing iptables configuration:" >> $FILENAME
echo ================================ >> $FILENAME
iptables -L >> $FILENAME
echo "" >> $FILENAME
echo "Listing all System processes:" >> $FILENAME
echo =============================== >> $FILENAME
ps -ef >> $FILENAME
echo "" >> $FILENAME
if [ -f .files_tmp ] ; then 
	cat .files_tmp >> $FILENAME
	rm .files_tmp
fi
echo "" >> $FILENAME
echo "Searching for DirtyCOW source/compiled exploit (no output = not found)" >> $FILENAME
echo ========================================================================= >> $FILENAME
for f in $(find /home/ -type f -size -300 2> /dev/null); do if [[ $(egrep "/proc/(self|%d)/(mem|maps)" "$f") != "" ]];then m=$(stat -c %y "$f"); echo "Contains DirtyCOW string: $f MOD_DATE: $m"; fi; done; >> $FILENAME
#Credit=Neo23x0
echo "" >> $FILENAME
echo Kernel Version: >> $FILENAME
echo ================ >> $FILENAME
uname -a >> $FILENAME
echo "" >> $FILENAME
echo "Kernel versions < those listed below ARE vulnerable to DirtyCow:" >> $FILENAME
echo ================================================================= >> $FILENAME
echo "4.8.0-26.28 for Ubuntu 16.10" >> $FILENAME
echo "4.4.0-45.66 for Ubuntu 16.04 LTS" >> $FILENAME
echo "3.13.0-100.147 for Ubuntu 14.04 LTS" >> $FILENAME
echo "3.2.0-113.155 for Ubuntu 12.04 LTS" >> $FILENAME
echo "3.16.36-1+deb8u2 for Debian 8" >> $FILENAME
echo "3.2.82-1 for Debian 7" >> $FILENAME
echo "4.7.8-1 for Debian unstable" >> $FILENAME
echo "" >> $FILENAME
echo "RHEL DirtyCOW check:" >> $FILENAME
echo ====================== >> $FILENAME
#RED="\033[1;31m"
#YELLOW="\033[1;33m"
#GREEN="\033[1;32m"
#BOLD="\033[1m"
#RESET="\033[0m"

SAFE_KERNEL="SAFE_KERNEL"
SAFE_KPATCH="SAFE_KPATCH"
MITIGATED="MITIGATED"
VULNERABLE="VULNERABLE"

MITIGATION_ON='CVE-2016-5195 mitigation loaded'
MITIGATION_OFF='CVE-2016-5195 mitigation unloaded'

VULNERABLE_VERSIONS=(
    # RHEL5
    "2.6.18-8.1.1.el5"
    "2.6.18-8.1.3.el5"
    "2.6.18-8.1.4.el5"
    "2.6.18-8.1.6.el5"
    "2.6.18-8.1.8.el5"
    "2.6.18-8.1.10.el5"
    "2.6.18-8.1.14.el5"
    "2.6.18-8.1.15.el5"
    "2.6.18-53.el5"
    "2.6.18-53.1.4.el5"
    "2.6.18-53.1.6.el5"
    "2.6.18-53.1.13.el5"
    "2.6.18-53.1.14.el5"
    "2.6.18-53.1.19.el5"
    "2.6.18-53.1.21.el5"
    "2.6.18-92.el5"
    "2.6.18-92.1.1.el5"
    "2.6.18-92.1.6.el5"
    "2.6.18-92.1.10.el5"
    "2.6.18-92.1.13.el5"
    "2.6.18-92.1.18.el5"
    "2.6.18-92.1.22.el5"
    "2.6.18-92.1.24.el5"
    "2.6.18-92.1.26.el5"
    "2.6.18-92.1.27.el5"
    "2.6.18-92.1.28.el5"
    "2.6.18-92.1.29.el5"
    "2.6.18-92.1.32.el5"
    "2.6.18-92.1.35.el5"
    "2.6.18-92.1.38.el5"
    "2.6.18-128.el5"
    "2.6.18-128.1.1.el5"
    "2.6.18-128.1.6.el5"
    "2.6.18-128.1.10.el5"
    "2.6.18-128.1.14.el5"
    "2.6.18-128.1.16.el5"
    "2.6.18-128.2.1.el5"
    "2.6.18-128.4.1.el5"
    "2.6.18-128.4.1.el5"
    "2.6.18-128.7.1.el5"
    "2.6.18-128.8.1.el5"
    "2.6.18-128.11.1.el5"
    "2.6.18-128.12.1.el5"
    "2.6.18-128.14.1.el5"
    "2.6.18-128.16.1.el5"
    "2.6.18-128.17.1.el5"
    "2.6.18-128.18.1.el5"
    "2.6.18-128.23.1.el5"
    "2.6.18-128.23.2.el5"
    "2.6.18-128.25.1.el5"
    "2.6.18-128.26.1.el5"
    "2.6.18-128.27.1.el5"
    "2.6.18-128.29.1.el5"
    "2.6.18-128.30.1.el5"
    "2.6.18-128.31.1.el5"
    "2.6.18-128.32.1.el5"
    "2.6.18-128.35.1.el5"
    "2.6.18-128.36.1.el5"
    "2.6.18-128.37.1.el5"
    "2.6.18-128.38.1.el5"
    "2.6.18-128.39.1.el5"
    "2.6.18-128.40.1.el5"
    "2.6.18-128.41.1.el5"
    "2.6.18-164.el5"
    "2.6.18-164.2.1.el5"
    "2.6.18-164.6.1.el5"
    "2.6.18-164.9.1.el5"
    "2.6.18-164.10.1.el5"
    "2.6.18-164.11.1.el5"
    "2.6.18-164.15.1.el5"
    "2.6.18-164.17.1.el5"
    "2.6.18-164.19.1.el5"
    "2.6.18-164.21.1.el5"
    "2.6.18-164.25.1.el5"
    "2.6.18-164.25.2.el5"
    "2.6.18-164.28.1.el5"
    "2.6.18-164.30.1.el5"
    "2.6.18-164.32.1.el5"
    "2.6.18-164.34.1.el5"
    "2.6.18-164.36.1.el5"
    "2.6.18-164.37.1.el5"
    "2.6.18-164.38.1.el5"
    "2.6.18-194.el5"
    "2.6.18-194.3.1.el5"
    "2.6.18-194.8.1.el5"
    "2.6.18-194.11.1.el5"
    "2.6.18-194.11.3.el5"
    "2.6.18-194.11.4.el5"
    "2.6.18-194.17.1.el5"
    "2.6.18-194.17.4.el5"
    "2.6.18-194.26.1.el5"
    "2.6.18-194.32.1.el5"
    "2.6.18-238.el5"
    "2.6.18-238.1.1.el5"
    "2.6.18-238.5.1.el5"
    "2.6.18-238.9.1.el5"
    "2.6.18-238.12.1.el5"
    "2.6.18-238.19.1.el5"
    "2.6.18-238.21.1.el5"
    "2.6.18-238.27.1.el5"
    "2.6.18-238.28.1.el5"
    "2.6.18-238.31.1.el5"
    "2.6.18-238.33.1.el5"
    "2.6.18-238.35.1.el5"
    "2.6.18-238.37.1.el5"
    "2.6.18-238.39.1.el5"
    "2.6.18-238.40.1.el5"
    "2.6.18-238.44.1.el5"
    "2.6.18-238.45.1.el5"
    "2.6.18-238.47.1.el5"
    "2.6.18-238.48.1.el5"
    "2.6.18-238.49.1.el5"
    "2.6.18-238.50.1.el5"
    "2.6.18-238.51.1.el5"
    "2.6.18-238.52.1.el5"
    "2.6.18-238.53.1.el5"
    "2.6.18-238.54.1.el5"
    "2.6.18-238.55.1.el5"
    "2.6.18-238.56.1.el5"
    "2.6.18-274.el5"
    "2.6.18-274.3.1.el5"
    "2.6.18-274.7.1.el5"
    "2.6.18-274.12.1.el5"
    "2.6.18-274.17.1.el5"
    "2.6.18-274.18.1.el5"
    "2.6.18-308.el5"
    "2.6.18-308.1.1.el5"
    "2.6.18-308.4.1.el5"
    "2.6.18-308.8.1.el5"
    "2.6.18-308.8.2.el5"
    "2.6.18-308.11.1.el5"
    "2.6.18-308.13.1.el5"
    "2.6.18-308.16.1.el5"
    "2.6.18-308.20.1.el5"
    "2.6.18-308.24.1.el5"
    "2.6.18-348.el5"
    "2.6.18-348.1.1.el5"
    "2.6.18-348.2.1.el5"
    "2.6.18-348.3.1.el5"
    "2.6.18-348.4.1.el5"
    "2.6.18-348.6.1.el5"
    "2.6.18-348.12.1.el5"
    "2.6.18-348.16.1.el5"
    "2.6.18-348.18.1.el5"
    "2.6.18-348.19.1.el5"
    "2.6.18-348.21.1.el5"
    "2.6.18-348.22.1.el5"
    "2.6.18-348.23.1.el5"
    "2.6.18-348.25.1.el5"
    "2.6.18-348.27.1.el5"
    "2.6.18-348.28.1.el5"
    "2.6.18-348.29.1.el5"
    "2.6.18-348.30.1.el5"
    "2.6.18-348.31.2.el5"
    "2.6.18-371.el5"
    "2.6.18-371.1.2.el5"
    "2.6.18-371.3.1.el5"
    "2.6.18-371.4.1.el5"
    "2.6.18-371.6.1.el5"
    "2.6.18-371.8.1.el5"
    "2.6.18-371.9.1.el5"
    "2.6.18-371.11.1.el5"
    "2.6.18-371.12.1.el5"
    "2.6.18-398.el5"
    "2.6.18-400.el5"
    "2.6.18-400.1.1.el5"
    "2.6.18-402.el5"
    "2.6.18-404.el5"
    "2.6.18-406.el5"
    "2.6.18-407.el5"
    "2.6.18-408.el5"
    "2.6.18-409.el5"
    "2.6.18-410.el5"
    "2.6.18-411.el5"
    "2.6.18-412.el5"

    # RHEL6
    "2.6.32-71.7.1.el6"
    "2.6.32-71.14.1.el6"
    "2.6.32-71.18.1.el6"
    "2.6.32-71.18.2.el6"
    "2.6.32-71.24.1.el6"
    "2.6.32-71.29.1.el6"
    "2.6.32-71.31.1.el6"
    "2.6.32-71.34.1.el6"
    "2.6.32-71.35.1.el6"
    "2.6.32-71.36.1.el6"
    "2.6.32-71.37.1.el6"
    "2.6.32-71.38.1.el6"
    "2.6.32-71.39.1.el6"
    "2.6.32-71.40.1.el6"
    "2.6.32-131.0.15.el6"
    "2.6.32-131.2.1.el6"
    "2.6.32-131.4.1.el6"
    "2.6.32-131.6.1.el6"
    "2.6.32-131.12.1.el6"
    "2.6.32-131.17.1.el6"
    "2.6.32-131.21.1.el6"
    "2.6.32-131.22.1.el6"
    "2.6.32-131.25.1.el6"
    "2.6.32-131.26.1.el6"
    "2.6.32-131.28.1.el6"
    "2.6.32-131.29.1.el6"
    "2.6.32-131.30.1.el6"
    "2.6.32-131.30.2.el6"
    "2.6.32-131.33.1.el6"
    "2.6.32-131.35.1.el6"
    "2.6.32-131.36.1.el6"
    "2.6.32-131.37.1.el6"
    "2.6.32-131.38.1.el6"
    "2.6.32-131.39.1.el6"
    "2.6.32-220.el6"
    "2.6.32-220.2.1.el6"
    "2.6.32-220.4.1.el6"
    "2.6.32-220.4.2.el6"
    "2.6.32-220.4.7.bgq.el6"
    "2.6.32-220.7.1.el6"
    "2.6.32-220.7.3.p7ih.el6"
    "2.6.32-220.7.4.p7ih.el6"
    "2.6.32-220.7.6.p7ih.el6"
    "2.6.32-220.7.7.p7ih.el6"
    "2.6.32-220.13.1.el6"
    "2.6.32-220.17.1.el6"
    "2.6.32-220.23.1.el6"
    "2.6.32-220.24.1.el6"
    "2.6.32-220.25.1.el6"
    "2.6.32-220.26.1.el6"
    "2.6.32-220.28.1.el6"
    "2.6.32-220.30.1.el6"
    "2.6.32-220.31.1.el6"
    "2.6.32-220.32.1.el6"
    "2.6.32-220.34.1.el6"
    "2.6.32-220.34.2.el6"
    "2.6.32-220.38.1.el6"
    "2.6.32-220.39.1.el6"
    "2.6.32-220.41.1.el6"
    "2.6.32-220.42.1.el6"
    "2.6.32-220.45.1.el6"
    "2.6.32-220.46.1.el6"
    "2.6.32-220.48.1.el6"
    "2.6.32-220.51.1.el6"
    "2.6.32-220.52.1.el6"
    "2.6.32-220.53.1.el6"
    "2.6.32-220.54.1.el6"
    "2.6.32-220.55.1.el6"
    "2.6.32-220.56.1.el6"
    "2.6.32-220.57.1.el6"
    "2.6.32-220.58.1.el6"
    "2.6.32-220.60.2.el6"
    "2.6.32-220.62.1.el6"
    "2.6.32-220.63.2.el6"
    "2.6.32-220.64.1.el6"
    "2.6.32-220.65.1.el6"
    "2.6.32-220.66.1.el6"
    "2.6.32-220.67.1.el6"
    "2.6.32-279.el6"
    "2.6.32-279.1.1.el6"
    "2.6.32-279.2.1.el6"
    "2.6.32-279.5.1.el6"
    "2.6.32-279.5.2.el6"
    "2.6.32-279.9.1.el6"
    "2.6.32-279.11.1.el6"
    "2.6.32-279.14.1.bgq.el6"
    "2.6.32-279.14.1.el6"
    "2.6.32-279.19.1.el6"
    "2.6.32-279.22.1.el6"
    "2.6.32-279.23.1.el6"
    "2.6.32-279.25.1.el6"
    "2.6.32-279.25.2.el6"
    "2.6.32-279.31.1.el6"
    "2.6.32-279.33.1.el6"
    "2.6.32-279.34.1.el6"
    "2.6.32-279.37.2.el6"
    "2.6.32-279.39.1.el6"
    "2.6.32-279.41.1.el6"
    "2.6.32-279.42.1.el6"
    "2.6.32-279.43.1.el6"
    "2.6.32-279.43.2.el6"
    "2.6.32-279.46.1.el6"
    "2.6.32-358.el6"
    "2.6.32-358.0.1.el6"
    "2.6.32-358.2.1.el6"
    "2.6.32-358.6.1.el6"
    "2.6.32-358.6.2.el6"
    "2.6.32-358.6.3.p7ih.el6"
    "2.6.32-358.11.1.bgq.el6"
    "2.6.32-358.11.1.el6"
    "2.6.32-358.14.1.el6"
    "2.6.32-358.18.1.el6"
    "2.6.32-358.23.2.el6"
    "2.6.32-358.28.1.el6"
    "2.6.32-358.32.3.el6"
    "2.6.32-358.37.1.el6"
    "2.6.32-358.41.1.el6"
    "2.6.32-358.44.1.el6"
    "2.6.32-358.46.1.el6"
    "2.6.32-358.46.2.el6"
    "2.6.32-358.48.1.el6"
    "2.6.32-358.49.1.el6"
    "2.6.32-358.51.1.el6"
    "2.6.32-358.51.2.el6"
    "2.6.32-358.55.1.el6"
    "2.6.32-358.56.1.el6"
    "2.6.32-358.59.1.el6"
    "2.6.32-358.61.1.el6"
    "2.6.32-358.62.1.el6"
    "2.6.32-358.65.1.el6"
    "2.6.32-358.67.1.el6"
    "2.6.32-358.68.1.el6"
    "2.6.32-358.69.1.el6"
    "2.6.32-358.70.1.el6"
    "2.6.32-358.71.1.el6"
    "2.6.32-358.72.1.el6"
    "2.6.32-358.73.1.el6"
    "2.6.32-358.111.1.openstack.el6"
    "2.6.32-358.114.1.openstack.el6"
    "2.6.32-358.118.1.openstack.el6"
    "2.6.32-358.123.4.openstack.el6"
    "2.6.32-431.el6"
    "2.6.32-431.1.1.bgq.el6"
    "2.6.32-431.1.2.el6"
    "2.6.32-431.3.1.el6"
    "2.6.32-431.5.1.el6"
    "2.6.32-431.11.2.el6"
    "2.6.32-431.17.1.el6"
    "2.6.32-431.20.3.el6"
    "2.6.32-431.20.5.el6"
    "2.6.32-431.23.3.el6"
    "2.6.32-431.29.2.el6"
    "2.6.32-431.37.1.el6"
    "2.6.32-431.40.1.el6"
    "2.6.32-431.40.2.el6"
    "2.6.32-431.46.2.el6"
    "2.6.32-431.50.1.el6"
    "2.6.32-431.53.2.el6"
    "2.6.32-431.56.1.el6"
    "2.6.32-431.59.1.el6"
    "2.6.32-431.61.2.el6"
    "2.6.32-431.64.1.el6"
    "2.6.32-431.66.1.el6"
    "2.6.32-431.68.1.el6"
    "2.6.32-431.69.1.el6"
    "2.6.32-431.70.1.el6"
    "2.6.32-431.71.1.el6"
    "2.6.32-431.72.1.el6"
    "2.6.32-431.73.2.el6"
    "2.6.32-431.74.1.el6"
    "2.6.32-504.el6"
    "2.6.32-504.1.3.el6"
    "2.6.32-504.3.3.el6"
    "2.6.32-504.8.1.el6"
    "2.6.32-504.8.2.bgq.el6"
    "2.6.32-504.12.2.el6"
    "2.6.32-504.16.2.el6"
    "2.6.32-504.23.4.el6"
    "2.6.32-504.30.3.el6"
    "2.6.32-504.30.5.p7ih.el6"
    "2.6.32-504.33.2.el6"
    "2.6.32-504.36.1.el6"
    "2.6.32-504.38.1.el6"
    "2.6.32-504.40.1.el6"
    "2.6.32-504.43.1.el6"
    "2.6.32-504.46.1.el6"
    "2.6.32-504.49.1.el6"
    "2.6.32-504.50.1.el6"
    "2.6.32-504.51.1.el6"
    "2.6.32-504.52.1.el6"
    "2.6.32-573.el6"
    "2.6.32-573.1.1.el6"
    "2.6.32-573.3.1.el6"
    "2.6.32-573.4.2.bgq.el6"
    "2.6.32-573.7.1.el6"
    "2.6.32-573.8.1.el6"
    "2.6.32-573.12.1.el6"
    "2.6.32-573.18.1.el6"
    "2.6.32-573.22.1.el6"
    "2.6.32-573.26.1.el6"
    "2.6.32-573.30.1.el6"
    "2.6.32-573.32.1.el6"
    "2.6.32-573.34.1.el6"
    "2.6.32-642.el6"
    "2.6.32-642.1.1.el6"
    "2.6.32-642.3.1.el6"
    "2.6.32-642.4.2.el6"
    "2.6.32-642.6.1.el6"

    # RHEL7
    "3.10.0-123.el7"
    "3.10.0-123.1.2.el7"
    "3.10.0-123.4.2.el7"
    "3.10.0-123.4.4.el7"
    "3.10.0-123.6.3.el7"
    "3.10.0-123.8.1.el7"
    "3.10.0-123.9.2.el7"
    "3.10.0-123.9.3.el7"
    "3.10.0-123.13.1.el7"
    "3.10.0-123.13.2.el7"
    "3.10.0-123.20.1.el7"
    "3.10.0-229.el7"
    "3.10.0-229.1.2.el7"
    "3.10.0-229.4.2.el7"
    "3.10.0-229.7.2.el7"
    "3.10.0-229.11.1.el7"
    "3.10.0-229.14.1.el7"
    "3.10.0-229.20.1.el7"
    "2.10.0-229.24.2.el7"
    "2.10.0-229.26.2.el7"
    "2.10.0-229.28.1.el7"
    "2.10.0-229.30.1.el7"
    "2.10.0-229.34.1.el7"
    "2.10.0-229.38.1.el7"
    "2.10.0-229.40.1.el7"
    "2.10.0-229.42.1.el7"
    "3.10.0-327.el7"
    "3.10.0-327.3.1.el7"
    "3.10.0-327.4.4.el7"
    "3.10.0-327.4.5.el7"
    "3.10.0-327.10.1.el7"
    "3.10.0-327.13.1.el7"
    "3.10.0-327.18.2.el7"
    "3.10.0-327.22.2.el7"
    "3.10.0-327.28.2.el7"
    "3.10.0-327.28.3.el7"
    "3.10.0-327.36.1.el7"
    "3.10.0-327.36.2.el7"
    "3.10.0-229.1.2.ael7b"
    "3.10.0-229.4.2.ael7b"
    "3.10.0-229.7.2.ael7b"
    "3.10.0-229.11.1.ael7b"
    "3.10.0-229.14.1.ael7b"
    "3.10.0-229.20.1.ael7b"
    "3.10.0-229.24.2.ael7b"
    "3.10.0-229.26.2.ael7b"
    "3.10.0-229.28.1.ael7b"
    "3.10.0-229.30.1.ael7b"
    "3.10.0-229.34.1.ael7b"
    "3.10.0-229.38.1.ael7b"
    "3.10.0-229.40.1.ael7b"
    "3.10.0-229.42.1.ael7b"
    "4.2.0-0.21.el7"

    # RHEL5
    "2.6.24.7-74.el5rt"
    "2.6.24.7-81.el5rt"
    "2.6.24.7-93.el5rt"
    "2.6.24.7-101.el5rt"
    "2.6.24.7-108.el5rt"
    "2.6.24.7-111.el5rt"
    "2.6.24.7-117.el5rt"
    "2.6.24.7-126.el5rt"
    "2.6.24.7-132.el5rt"
    "2.6.24.7-137.el5rt"
    "2.6.24.7-139.el5rt"
    "2.6.24.7-146.el5rt"
    "2.6.24.7-149.el5rt"
    "2.6.24.7-161.el5rt"
    "2.6.24.7-169.el5rt"
    "2.6.33.7-rt29.45.el5rt"
    "2.6.33.7-rt29.47.el5rt"
    "2.6.33.7-rt29.55.el5rt"
    "2.6.33.9-rt31.64.el5rt"
    "2.6.33.9-rt31.67.el5rt"
    "2.6.33.9-rt31.86.el5rt"

    # RHEL6
    "2.6.33.9-rt31.66.el6rt"
    "2.6.33.9-rt31.74.el6rt"
    "2.6.33.9-rt31.75.el6rt"
    "2.6.33.9-rt31.79.el6rt"
    "3.0.9-rt26.45.el6rt"
    "3.0.9-rt26.46.el6rt"
    "3.0.18-rt34.53.el6rt"
    "3.0.25-rt44.57.el6rt"
    "3.0.30-rt50.62.el6rt"
    "3.0.36-rt57.66.el6rt"
    "3.2.23-rt37.56.el6rt"
    "3.2.33-rt50.66.el6rt"
    "3.6.11-rt28.20.el6rt"
    "3.6.11-rt30.25.el6rt"
    "3.6.11.2-rt33.39.el6rt"
    "3.6.11.5-rt37.55.el6rt"
    "3.8.13-rt14.20.el6rt"
    "3.8.13-rt14.25.el6rt"
    "3.8.13-rt27.33.el6rt"
    "3.8.13-rt27.34.el6rt"
    "3.8.13-rt27.40.el6rt"
    "2.10.0-229.rt56.144.el6rt"
    "2.10.0-229.rt56.147.el6rt"
    "2.10.0-229.rt56.149.el6rt"
    "2.10.0-229.rt56.151.el6rt"
    "2.10.0-229.rt56.153.el6rt"
    "2.10.0-229.rt56.158.el6rt"
    "2.10.0-229.rt56.161.el6rt"
    "2.10.0-229.rt56.162.el6rt"
    "2.10.0-327.rt56.170.el6rt"
    "2.10.0-327.rt56.171.el6rt"
    "2.10.0-327.rt56.176.el6rt"
    "2.10.0-327.rt56.183.el6rt"
    "2.10.0-327.rt56.190.el6rt"
    "2.10.0-327.rt56.194.el6rt"
    "2.10.0-327.rt56.195.el6rt"
    "2.10.0-327.rt56.197.el6rt"
    "3.10.33-rt32.33.el6rt"
    "3.10.33-rt32.34.el6rt"
    "3.10.33-rt32.43.el6rt"
    "3.10.33-rt32.45.el6rt"
    "3.10.33-rt32.51.el6rt"
    "3.10.33-rt32.52.el6rt"
    "3.10.58-rt62.58.el6rt"
    "3.10.58-rt62.60.el6rt"

    # RHEL7
    "3.10.0-229.rt56.141.el7"
    "3.10.0-229.1.2.rt56.141.2.el7_1"
    "3.10.0-229.4.2.rt56.141.6.el7_1"
    "3.10.0-229.7.2.rt56.141.6.el7_1"
    "3.10.0-229.11.1.rt56.141.11.el7_1"
    "3.10.0-229.14.1.rt56.141.13.el7_1"
    "3.10.0-229.20.1.rt56.141.14.el7_1"
    "3.10.0-229.rt56.141.el7"
    "3.10.0-327.rt56.204.el7"
    "3.10.0-327.4.5.rt56.206.el7_2"
    "3.10.0-327.10.1.rt56.211.el7_2"
    "3.10.0-327.13.1.rt56.216.el7_2"
    "3.10.0-327.18.2.rt56.223.el7_2"
    "3.10.0-327.22.2.rt56.230.el7_2"
    "3.10.0-327.28.2.rt56.234.el7_2"
    "3.10.0-327.28.3.rt56.235.el7"
    "3.10.0-327.36.1.rt56.237.el7"
)

KPATCH_MODULE_NAMES=(
    "kpatch_3_10_0_327_36_1_1_1"
    "kpatch_3_10_0_327_36_2_1_1"
)

running_kernel=$( uname -r )

# Check supported platform
if [[ "$running_kernel" != *".el"[5-7]* ]]; then
    echo -e "${RED}Red Hat Enterprise Linux not detected.${RESET}" >> $FILENAME
echo "" >> $FILENAME
echo ================================================================= >> $FILENAME
echo THIS IS THE END OF THE AUDIT FILE FOR HOST: `hostname`  >> $FILENAME
echo ================================================================= >> $FILENAME
echo ""
echo "Audit successful the results can be found in $FILENAME  : )"
exit 4
fi

# Check kernel if it is vulnerable
for tested_kernel in "${VULNERABLE_VERSIONS[@]}"; do
	if [[ "$running_kernel" == *"$tested_kernel"* ]]; then
	    vulnerable_kernel=${running_kernel}
	    break
	fi
done

# Check if kpatch is installed
modules=$( lsmod )
for tested_kpatch in "${KPATCH_MODULE_NAMES[@]}"; do
    if [[ "$modules" == *"$tested_kpatch"* ]]; then
	    applied_kpatch=${tested_kpatch}
	    break
	fi
done

# Check mitigation
mitigated=0
while read -r line; do
    if [[ "$line" == *"$MITIGATION_ON"* ]]; then
        mitigated=1
    elif [[ "$line" == *"$MITIGATION_OFF"* ]]; then
        mitigated=0
    fi
done < <( dmesg )

# Result interpretation
result=${VULNERABLE}
if (( mitigated )); then
    result=${MITIGATED}
fi
if [[ ! "$vulnerable_kernel" ]]; then
    result=${SAFE_KERNEL}
elif [[ "$applied_kpatch" ]]; then
    result=${SAFE_KPATCH}
fi

# Print result
if [[ ${result} == "$SAFE_KERNEL" ]]; then
    echo -e "${GREEN}Your kernel is ${RESET}$running_kernel${GREEN} which is NOT vulnerable.${RESET}"
elif [[ ${result} == "$SAFE_KPATCH" ]]; then
    echo -e "Your kernel is $running_kernel which is normally vulnerable."
    echo -e "${GREEN}However, you have kpatch ${RESET}$applied_kpatch${GREEN} applied, which fixes the vulnerability.${RESET}"
elif [[ ${result} == "$MITIGATED" ]]; then
    echo -e "${YELLOW}Your kernel is ${RESET}$running_kernel${YELLOW} which IS vulnerable.${RESET}"
    echo -e "${YELLOW}You have a partial mitigation applied.${RESET}"
    echo -e "This mitigation protects against most common attack vectors which are already exploited in the wild,"
    echo -e "but does not protect against all possible attack vectors."
    echo -e "Red Hat recommends that you update your kernel as soon as possible."
else
    echo -e "${RED}Your kernel is ${RESET}$running_kernel${RED} which IS vulnerable.${RESET}"
    echo -e "Red Hat recommends that you update your kernel. Alternatively, you can apply partial"
    echo -e "mitigation described at https://access.redhat.com/security/vulnerabilities/2706661 ."
fi
echo "" >> $FILENAME
echo ================================================================= >> $FILENAME
echo THIS IS THE END OF THE AUDIT FILE FOR HOST: `hostname`  >> $FILENAME
echo ================================================================= >> $FILENAME
echo ""
echo "Audit successful the results can be found in $FILENAME  : )"
