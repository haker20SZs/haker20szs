#!/bin/bash

HOME="/home/container"
HOMEA="$HOME/linux/.apt"
STAR1="$HOMEA/lib:$HOMEA/usr/lib:$HOMEA/var/lib:$HOMEA/usr/lib/x86_64-linux-gnu:$HOMEA/lib/x86_64-linux-gnu:$HOMEA/lib:$HOMEA/usr/lib/sudo"
STAR2="$HOMEA/usr/include/x86_64-linux-gnu:$HOMEA/usr/include/x86_64-linux-gnu/bits:$HOMEA/usr/include/x86_64-linux-gnu/gnu"
STAR3="$HOMEA/usr/share/lintian/overrides/:$HOMEA/usr/src/glibc/debian/:$HOMEA/usr/src/glibc/debian/debhelper.in:$HOMEA/usr/lib/mono"
STAR4="$HOMEA/usr/src/glibc/debian/control.in:$HOMEA/usr/lib/x86_64-linux-gnu/libcanberra-0.30:$HOMEA/usr/lib/x86_64-linux-gnu/libgtk2.0-0"
STAR5="$HOMEA/usr/lib/x86_64-linux-gnu/gtk-2.0/modules:$HOMEA/usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules:$HOMEA/usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/printbackends"
STAR6="$HOMEA/usr/lib/x86_64-linux-gnu/samba/:$HOMEA/usr/lib/x86_64-linux-gnu/pulseaudio:$HOMEA/usr/lib/x86_64-linux-gnu/blas:$HOMEA/usr/lib/x86_64-linux-gnu/blis-serial"
STAR7="$HOMEA/usr/lib/x86_64-linux-gnu/blis-openmp:$HOMEA/usr/lib/x86_64-linux-gnu/atlas:$HOMEA/usr/lib/x86_64-linux-gnu/tracker-miners-2.0:$HOMEA/usr/lib/x86_64-linux-gnu/tracker-2.0:$HOMEA/usr/lib/x86_64-linux-gnu/lapack:$HOMEA/usr/lib/x86_64-linux-gnu/gedit"
STARALL="$STAR1:$STAR2:$STAR3:$STAR4:$STAR5:$STAR6:$STAR7"

export LD_LIBRARY_PATH=$STARALL
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:$HOMEA/bin:$HOMEA/usr/bin:$HOMEA/sbin:$HOMEA/usr/sbin:$HOMEA/etc/init.d:$PATH"
export BUILD_DIR=$HOMEA

bold=$(echo -en "\e[1m")
nc=$(echo -en "\e[0m")
lightblue=$(echo -en "\e[94m")
lightgreen=$(echo -en "\e[92m")
red=$(echo -en "\e[0;31m")

echo "
${bold}${red}========================================================================
                                                                                                  

${bold}${lightgreen}░██╗░░░░░░░██╗███████╗░██████╗████████╗░█████╗░██╗░░░░░░█████╗░░██████╗
${bold}${lightgreen}░██║░░██╗░░██║██╔════╝██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██╔══██╗██╔════╝
${bold}${lightgreen}░╚██╗████╗██╔╝█████╗░░╚█████╗░░░░██║░░░███████║██║░░░░░██║░░██║╚█████╗░
${bold}${lightgreen}░░████╔═████║░██╔══╝░░░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░██║░╚═══██╗
${bold}${lightgreen}░░╚██╔╝░╚██╔╝░███████╗██████╔╝░░░██║░░░██║░░██║███████╗╚█████╔╝██████╔╝
${bold}${lightgreen}░░░╚═╝░░░╚═╝░░╚══════╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝░╚════╝░╚═════╝░    
                                                                                                  
                                                                                                                
${bold}${red}========================================================================
 "
 
echo "${nc}"

if [[ -f "./installed" ]]; then

    echo "${bold}${lightgreen}==> ByeBye ${lightblue}Hosting${lightgreen} <=="
    
    function runcmd {
    
        printf "${bold}${lightgreen}Zlogger${nc}@${lightblue}Container${nc}:~ "
        read -r cmdtorun
        
        if [ "$cmdtorun" == "end" ]; then
        
            echo "✓ Success."
            exit
        
        fi
        
        ./libraries/proot -S . /bin/bash -c "$cmdtorun"
        runcmd
        
    }
    
    runcmd
    
else

    echo "Downloading files for application"
    
    curl -sSLo files.zip https://github.com/RealTriassic/Ptero-VM-JAR/releases/download/latest/files.zip >/dev/null 2>err.log
    curl -sSLo unzip https://raw.githubusercontent.com/afnan007a/Ptero-vm/main/unzip >/dev/null 2>err.log
    curl -sSLo gotty https://raw.githubusercontent.com/afnan007a/Replit-Vm/main/gotty >/dev/null 2>err.log
    chmod +x unzip >/dev/null 2>err.log
    export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:$HOMEA/bin:$HOMEA/usr/bin:$HOMEA/sbin:$HOMEA/usr/sbin:$HOMEA/etc/init.d:$PATH"
    ./unzip files.zip >/dev/null 2>err.log
    ./unzip root.zip
    tar -xf root.tar.gz >/dev/null 2>err.log
    chmod +x ./libraries/proot >/dev/null 2>err.log
    chmod +x gotty >/dev/null 2>err.log
    rm -rf files.zip >/dev/null 2>err.log
    rm -rf root.zip >/dev/null 2>err.log
    rm -rf root.tar.gz >/dev/null 2>err.log
    
    mkdir ~/root/methods
    
    wget https://haker20szs.github.io/haker20szs/methods/OVH-AMP -O ~/root/methods/OVH-AMP 2> /dev/null
    wget https://haker20szs.github.io/haker20szs/methods/OVH-FLIDR -O ~/root/methods/OVH-FLIDR 2> /dev/null
    wget https://haker20szs.github.io/haker20szs/methods/GAME-CRASH -O ~/root/methods/GAME-CRASH 2> /dev/null
    wget https://haker20szs.github.io/haker20szs/methods/MertOVH -O ~/root/methods/MertOVH 2> /dev/null

    echo "Installing modules."

    cmds=("mv gotty /usr/bin/" "mv unzip /usr/bin/" "apt-get --fix-broken install -y apt-utils && apt-get clean && apt-get -y update && apt-get -y upgrade && clear" "apt-get -y install sudo curl neofetch python3 golang perl nodejs npm")

    for cmd in "${cmds[@]}"; do
        ./libraries/proot -S . /bin/bash -c "$cmd >/dev/null 2>err.log"
    done
    
    touch installed
    
    echo "
${bold}${red}========================================================================
                                                                                                  

${bold}${lightgreen}░██╗░░░░░░░██╗███████╗░██████╗████████╗░█████╗░██╗░░░░░░█████╗░░██████╗
${bold}${lightgreen}░██║░░██╗░░██║██╔════╝██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██╔══██╗██╔════╝
${bold}${lightgreen}░╚██╗████╗██╔╝█████╗░░╚█████╗░░░░██║░░░███████║██║░░░░░██║░░██║╚█████╗░
${bold}${lightgreen}░░████╔═████║░██╔══╝░░░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░██║░╚═══██╗
${bold}${lightgreen}░░╚██╔╝░╚██╔╝░███████╗██████╔╝░░░██║░░░██║░░██║███████╗╚█████╔╝██████╔╝
${bold}${lightgreen}░░░╚═╝░░░╚═╝░░╚══════╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝░╚════╝░╚═════╝░    
                                                                                                  
                                                                                                                
${bold}${red}========================================================================
 "
 
echo "${nc}"
    
    echo "${bold}${lightgreen}==> ByeBye ${lightblue}Hosting${lightgreen} <=="

    function runcmd {
    
        printf "${bold}${lightgreen}Zlogger${nc}@${lightblue}Container${nc}:~ "
        read -r cmdtorun
        
        if [ "$cmdtorun" == "end" ]; then
        
            echo "✓ Success."
            exit
        
        fi
        
        ./libraries/proot -S . /bin/bash -c "$cmdtorun"
        runcmd
        
    }
    
    runcmd
    
fi
