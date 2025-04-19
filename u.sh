#!/bin/bash

# Fonction pour afficher un logo
print_logo() {
    echo "
███████╗███████╗██████╗ ████████╗███████╗ ██████╗
██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔═══██╗
███████╗█████╗  ██████╔╝   ██║   █████╗  ██║   ██║
╚════██║██╔══╝  ██╔═══╝    ██║   ██╔══╝  ██║   ██║
███████║███████╗██║        ██║   ███████╗╚██████╔╝
╚══════╝╚══════╝╚═╝        ╚═╝   ╚══════╝ ╚═════╝

Configuration d'ubuntu 24.04 LTS
"
}

# Fonction pour afficher une séparation
print_separator() {
    echo -e
    echo "--------------------------------------------------"
    echo -e
}

# Afficher le logo
print_logo

# Activer le mode debug et arrêter en cas d'erreur
#set -x
#set -e

# Mise à jour du système
print_separator
echo "--> Mise à jour du système en cours..."
echo -e
sudo apt update && sudo apt upgrade -y

# Installation des dépendances pour le déverrouillage automatique du bureau
print_separator
echo "--> Installation des dépendances pour le déverrouillage automatique du bureau..."
sudo apt-get -y install clevis clevis-tpm2 clevis-luks clevis-initramfs initramfs-tools tss2

# Demande du mot de passe de chiffrement
print_separator
echo -n "Entrer le mot de passe de chiffrement : "
read -s LUKSKEY
echo ""

# Trouver le nom du périphérique LUKS
LUKS_DEVICE=$(sudo lsblk --fs | grep "crypto_LUKS" | awk '{print $1}' | tr -dc '[:alnum:]')

# Lier le périphérique LUKS avec Clevis et TPM2
print_separator
echo "--> Liaison du périphérique LUKS avec Clevis et TPM2..."
echo -e
sudo clevis luks bind -d /dev/$LUKS_DEVICE tpm2 '{"pcr_bank":"sha256"}' <<< "$LUKSKEY"

# Mettre à jour l'initramfs
print_separator
echo "--> Mise à jour de l'initramfs..."
sudo update-initramfs -u -k all

# Installation de GlobalProtect
print_separator
echo "--> Installation de GlobalProtect..."
echo -e

wget https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v1.4.9/globalprotect-openconnect-1.4.9.tar.gz
tar zxvf globalprotect-openconnect-1.4.9.tar.gz
cd $PWD/globalprotect-openconnect-1.4.9
sh scripts/install-ubuntu.sh
sed -i 's/^openconnect-args=/openconnect-args= --csd-wrapper=\/usr\/libexec\/openconnect\/hipreport.sh/' /etc/gpservice/gp.conf


# Activation du firewall
print_separator
echo "--> Activation du firewall"
echo -e
sudo ufw enable


print_separator
echo "--> Block incoming SSH connections"
echo -e
sudo ufw deny ssh




print_separator
echo "--> Configuration du XDR "
echo -e

wget https://fichiers.septeo.fr/index.php/s/iMSnwQxsJxGaxPm/download/taegis-agent_1.4.2_amd64.deb
sleep 2
sudo dpkg -i taegis-agent_1.4.2_amd64.deb
sleep 1
sudo /opt/secureworks/taegis-agent/bin/taegisctl register --key MTQ1NzM3fEZ4NHAyR3FRQWJjbFAtd0JmcUp0SFlR --server reg.e.taegiscloud.com
sleep 1
export PATH=/opt/secureworks/taegis-agent/bin:$PATH
sudo /opt/secureworks/taegis-agent/bin/taegisctl start


print_separator
echo "--> Installation de Trend "
echo -e

ACTIVATIONURL='dsm://agents.deepsecurity.trendmicro.com:443/'
MANAGERURL='https://app.deepsecurity.trendmicro.com:443'
CURLOPTIONS='--silent --tlsv1.2'
linuxPlatform='';
isRPM='';

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo You are not running as the root user.  Please try again with root privileges.;
    logger -t You are not running as the root user.  Please try again with root privileges.;
    exit 1;
fi;

if ! type curl >/dev/null 2>&1; then
    echo "Please install CURL before running this script."
    logger -t Please install CURL before running this script
    exit 1
fi

CURLOUT=$(eval curl -L $MANAGERURL/software/deploymentscript/platform/linuxdetectscriptv1/ -o /tmp/PlatformDetection $CURLOPTIONS;)
err=$?
if [[ $err -eq 60 ]]; then
    echo "TLS certificate validation for the agent package download has failed. Please check that your Workload Security Manager TLS certificate is signed by a trusted root certificate authority. For more information, search for \"deployment scripts\" in the Deep Security Help Center."
    logger -t TLS certificate validation for the agent package download has failed. Please check that your Workload Security Manager TLS certificate is signed by a trusted root certificate authority. For more information, search for \"deployment scripts\" in the Deep Security Help Center.
    exit 1;
fi

if [ -s /tmp/PlatformDetection ]; then
    . /tmp/PlatformDetection
else
    echo "Failed to download the agent installation support script."
    logger -t Failed to download the Deep Security Agent installation support script
    exit 1
fi

platform_detect
if [[ -z "${linuxPlatform}" ]] || [[ -z "${isRPM}" ]]; then
    echo Unsupported platform is detected
    logger -t Unsupported platform is detected
    exit 1
fi

if [[ ${linuxPlatform} == *"SuSE_15"* ]]; then
    if ! type pidof &> /dev/null || ! type start_daemon &> /dev/null || ! type killproc &> /dev/null; then
        echo Please install sysvinit-tools before running this script
        logger -t Please install sysvinit-tools before running this script
        exit 1
    fi
fi

echo Downloading agent package...
if [[ $isRPM == 1 ]]; then package='agent.rpm'
    else package='agent.deb'
fi
curl -H "Agent-Version-Control: on" -L $MANAGERURL/software/agent/${runningPlatform}${majorVersion}/${archType}/$package?tenantID=105559 -o /tmp/$package $CURLOPTIONS

echo Installing agent package...
rc=1
if [[ $isRPM == 1 && -s /tmp/agent.rpm ]]; then
    rpm -ihv /tmp/agent.rpm
    rc=$?
elif [[ -s /tmp/agent.deb ]]; then
    dpkg -i /tmp/agent.deb
    rc=$?
else
    echo Failed to download the agent package. Please make sure the package is imported in the Workload Security Manager
    logger -t Failed to download the agent package. Please make sure the package is imported in the Workload Security Manager
    exit 1
fi
if [[ ${rc} != 0 ]]; then
    echo Failed to install the agent package
    logger -t Failed to install the agent package
    exit 1
fi

echo Install the agent package successfully

sleep 15
/opt/ds_agent/dsa_control -r
/opt/ds_agent/dsa_control -a $ACTIVATIONURL "tenantID:3C66A21B-CC05-A4BB-FA3B-24EA3BE8BDFB" "token:9EE9DE4E-7EEB-5DAE-ED22-38D4EE9A07F3" "policyid:1797" "groupid:2682"


print_separator
echo "--> Installation de Microsoft Intune "
echo -e

sudo apt install curl gpg
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" > /etc/apt/sources.list.d/microsoft-ubuntu-noble-prod.list'
sudo rm microsoft.gpg
sudo apt update && sudo apt install -y intune-portal


print_separator
echo "--> Configuration du Secure Boot "
echo -e

sudo apt install efitools
sudo mokutil --import /opt/ds_agent/secureboot/DS2022.der /opt/ds_agent/secureboot/DS20_v2.der

print_separator
echo "Script terminé avec succès."
