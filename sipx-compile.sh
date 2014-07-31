#!/bin/bash
INSTALL_DIR="/usr/local/sipxecs-install";
SOURCES_DIR="~/git/sipxecs";
BUILD_DIR="~/sipxecs-build";

eval SRC_DIR=$SOURCES_DIR;
eval BLD_DIR=$BUILD_DIR;

MY_USER=$USER;   
MY_GROUP=`id -g -n $USER`;

echo "Install dir: ... $INSTALL_DIR";
echo "Build   dir: ... $BLD_DIR";
echo "Sources dir: ... $SRC_DIR";
echo "SipX user    ... $MY_USER";
echo "SipX group   ... $MY_GROUP";


do_reconf(){
    cd $SRC_DIR; 
    echo "running autoreconf in `pwd`";
    autoreconf -if;
}

do_configure(){
    cd $BLD_DIR;
    CONFIG_CMD="$SRC_DIR/configure --cache-file=`pwd`/ac-cache-file SIPXPBXUSER=$MY_USER SIPXPBXGROUP=$MY_GROUP \
         --prefix=$INSTALL_DIR JAVAC_DEBUG=on JAVAC_OPTIMIZED=off \
         --enable-rpm \
         UPSTREAM_URL=http://download.sipfoundry.org/pub/14.10-unstable/  MIRROR_SITE=http://download.sipfoundry.org/pub PACKAGE_REVISION=stable";
    
    CONFIG_CMD_NORPM="$SRC_DIR/configure --cache-file=`pwd`/ac-cache-file SIPXPBXUSER=$MY_USER SIPXPBXGROUP=$MY_GROUP \
         --prefix=$INSTALL_DIR JAVAC_DEBUG=on JAVAC_OPTIMIZED=off"

    read -p "Activate rpms (y/n) ?" yn;
    case $yn in 
        [Yy]* )
            echo $CONFIG_CMD;
            sleep 1;
            $CONFIG_CMD;;
            
        [Nn]* ) 
            echo $CONFIG_CMD_NORPM;
            sleep 1;
            $CONFIG_CMD_NORPM;;
            * ) echo "You have chosen not to run configure again";
                continue;;
    esac
}

do_build() {
    read -p "Continue with make build (y/n) ?" yn;
    case $yn in 
        [Yy]* )
            make build;;
        [Nn]* ) echo "You have chosen not to run 'make build' again";
                continue;;
            * ) echo "You have chosen not to run 'make build' again";
                continue;;
    esac
}

do_regen_key() {
    ssh-keygen -t rsa -f "$INSTALL_DIR/var/sipxdata/key/reach.key" -N "" -q
}


do_install_missing_deps() {
    sudo yum -y install createrepo npm mock thttpd;
    sudo usermod -a -G mock;
}

do_patch_reach_stuff() {
    echo;
    echo "Copy js stuff for reach (package.json, Gruntfile.js) to the build dir";
    echo;
    mkdir -p $BLD_DIR/reach-app/apps/reach_ouc/;
    cp $SRC_DIR/reach-app/apps/reach_ouc/package.json $BLD_DIR/reach-app/apps/reach_ouc/;
    cp $SRC_DIR/reach-app/apps/reach_ouc/Gruntfile.js $BLD_DIR/reach-app/apps/reach_ouc/;
    cp -r $SRC_DIR/reach-app/apps/reach_ouc/site/     $BLD_DIR/reach-app/apps/reach_ouc/;
}



read -p "Continue (y/n) ?" yn;
case $yn in
     [Yy]* ) 
        do_reconf;
        do_configure;
        do_patch_reach_stuff; # To be removed after Mina fixes this.
        do_build;
        do_regen_key;
        continue;;
     [Nn]* ) exit;;
         * ) echo "Please answer yes or no.";;
esac

