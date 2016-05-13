#!/bin/sh

setupenv(){
    export LFS="/img"
    echo "setupenv success"
}

createfs() {
    local name=lfs.img

    if [ ! -f "lfs.img" ];then
        echo "Create image"
      dd if=/dev/zero of=$name bs=1024 count=10240000
      mkfs.ext4 $name
    fi

    [ ! -d "$LFS" ] &&  sudo mkdir -v $LFS

    result=`df | gawk '/\'$LFS'/{print $6}'`
    [ "$result" != "$LFS" ] && sudo mount -o loop $name $LFS
    echo "createfs success"
}

createdir(){
    [ ! -d "$LFS/sources" ] && sudo mkdir -v $LFS/sources
    [ $(. ./getmod.sh $LFS/sources) != "1444" ] && sudo chmod -v a+wt $LFS/sources 

    [ ! -d "$LFS/tools" ] && sudo mkdir -v $LFS/tools
    [ ! -d "/tools" ] && sudo ln -sv $LFS/tools /
    [ ! -d "$LFS/build" ] && sudo mkdir -v build
    echo "createdir success"
}

getsourcecode(){
    wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
    echo "download codes success"
}

addlfsuser(){
    id -g "lfs" &>/dev/null
    [ "$?" != 0 ] && sudo groupadd lfs

    id -u "lfs" &>/dev/null
    [ "$?" != 0 ] && sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs

    # -s: select commandline
    # -g: add user lfs to group lfs
    # -m: create a home directory for lfs
    # -k: prevent to copy files from skeleton directory (/etc/skel)

    sudo passwd lfs
    sudo chown -v lfs $LFS/tools
    sudo chown -v lfs $LFS/sources
    #su lfs -c "pwd"
    su lfs -c "sh ./inlfsexec.sh"
    echo "adduser success"
}


setupenv
#createfs
#createdir
#getsourcecode
addlfsuser
