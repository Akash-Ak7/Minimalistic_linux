KERNEL_VERSION=5.9.4
BUSYBOX_VERSION=1.35.0
KERNEL_MAJOR=$( echo $KERNEL_VERSION | sed 's/\([0-9]*\)[^0-9].*/\1/' )

KERNEL_BUILD=y
BUSYBOX_BUILD=y

create_runscript()
{
    if [ -e bzImage-$KERNEL_VERSION ]; then
        if [ -e initrd-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION.img ]; then

            if [ -e run.sh ]; then
                rm run.sh
            fi

            #Create a script to run in qumu-system emulator
            echo "!/bin/bash" > run.sh
            echo "echo [+] starting qemu-system emulator..." >> run.sh
            echo "qemu-system-x86_64 -kernel bzImage-$KERNEL_VERSION -initrd initrd-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION.img -nographic -append 'console=ttyS0'" >> run.sh
            chmod +x run.sh           

        else
            echo "[!] ERROR: initrd image with name initrd-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION.img not found"
        fi
    else
        echo "[!] ERROR: Kernel image with name bzImage-$KERNEL_VERSION  not found"
    fi
}

install_packages()
{
    mkdir -p src
    cd src

        echo "[+] INFO: Installing packages........"
        
        if [[ $KERNEL_BUILD == "y" ]]; then

            if [ -d linux-$KERNEL_VERSION ]; then
                touch linux-$KERNEL_VERSION/remove.txt
                rm -rf linux-$KERNEL_VERSION                #Remove existing kernel directory
            fi

            if [ -e linux-$KERNEL_VERSION.tar.xz ]; then
                echo "[*] INFO: kernel-$KERNEL_VERSION.tar.xz file found!"
            else
                echo "[+] INFO: Downloading Kernel (Version: $KERNEL_VERSION)"
                wget https://mirrors.edge.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
            fi
            
            echo "[+] INFO: Extracting the kernel package"
            tar -xf linux-$KERNEL_VERSION.tar.xz

            cd linux-$KERNEL_VERSION
                make defconfig  #Make default configuration
                make -j8 || exit    #Build the kernel
            cd ..
            echo "[+] SUCCESS: Kernel image created."
        fi


        if [[ $BUSYBOX_BUILD == "y" ]]; then

            if [ -d busybox-$BUSYBOX_VERSION ]; then
                touch busybox-$BUSYBOX_VERSION/remove.txt
                rm -rf busybox-$BUSYBOX_VERSION             #Remove existing busybox directory
            fi

            if [ -e busybox-$BUSYBOX_VERSION.tar.bz2 ]; then
                echo "[+] INFO: busybox-$BUSYBOX_VERSION.tar.bz2 file found!"
            else
                echo "[+] INFO: Downloading busybox (Version: $BUSYBOX_VERSION)"
                wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
            fi

            echo "[+] INFO: Extracting the busybox package"
            tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
            cd busybox-$BUSYBOX_VERSION
                make defconfig
                sed -i 's/# CONFIG_STATIC[^_].*/CONFIG_STATIC=y/g' .config
                make -j8 || exit
            cd ..
            echo "[+] SUCCESS: Busybox image created."
        fi

    cd .. 
    #exit src folder

    cp src/linux-$KERNEL_VERSION/arch/x86_64/boot/bzImage ./bzImage-$KERNEL_VERSION
    cp src/busybox-$BUSYBOX_VERSION/busybox ./busybox-$BUSYBOX_VERSION

    if [ -d initrd ]; then
        touch initrd/remove.txt
        rm -rf initrd               #Remove initrd and buildagain
    fi

    mkdir -p initrd
    cd initrd

        mkdir -p bin dev proc sys
        cd bin

            cp ../../src/busybox-$BUSYBOX_VERSION/busybox ./busybox-$BUSYBOX_VERSION

            for prog in $(./busybox-$BUSYBOX_VERSION --list); do    
                ln -s /bin/busybox-$BUSYBOX_VERSION $prog
            done

        cd ..

        #init script for mounting folders
        echo "#!/bin/sh" > init
        echo "mount -t sys sys /sys" >> init
        echo "mount -t proc proc /proc" >> init
        echo "mount -t devtmpfs udev /dev" >> init
        echo "sysctl -w kernel.printk="2 4 1 7"" >> init
        echo "/bin/sh" >> init
        echo "poweroff -f" >> init
        chmod -R 777 .

        find . | cpio -o -H newc > ../initrd-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION.img

        echo "[+] SUCCESS: initrd-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION.img created"

    cd ..   
    #Exit initrd

    create_runscript

    echo "[+] INFO: Start the run.sh script to boot"
    echo -e "[+] Would you like to run the script? (y/n) \c"
    read run_choice
    if [ $run_choice = "y" ]; then
        ./run.sh
    fi

    cd .. 
    #Exit minimalistic linux folder
}

# =========================================================
#           Main execution starts here
# =========================================================

echo "[+] INFO: KERNEL_VERSION=$KERNEL_VERSION"
echo "[+] INFO: BUSYBOX_VERSION=$BUSYBOX_VERSION"

if [ -d minimalistic_linux-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION ]; then

    cd minimalistic_linux-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION

    if [ -d src/ ]; then

        #If bzImage is not present, then remove the Kernel folder and build again
        if [ -e src/linux-$KERNEL_VERSION/arch/x86_64/boot/bzImage ]; then
            KERNEL_BUILD=n
        else
            KERNEL_BUILD=y
        fi

        #If Busybox directory present and busybox missing, then remove the entire busybox directory and build again
        if [ -e src/busybox-$BUSYBOX_VERSION/busybox ]; then
            BUSYBOX_BUILD=n
        else
            BUSYBOX_BUILD=y
        fi

        echo "Build Status: KERNEL:$KERNEL_BUILD BUSYBOX:$BUSYBOX_BUILD"

        if [[ $KERNEL_BUILD=="n" && $BUSYBOX_BUILD=="n" ]]; then

            echo "[!] WARNING: Installing again will remove some of existing configuration"
            echo -e "Would you like to continue?(y/n) \c"
            read build_choice
            case $build_choice in 
            "y" )
                    KERNEL_BUILD=y
                    BUSYBOX_BUILD=y 
                    install_packages      ;;
            "n" )
                echo -e "Would you like to run existing linux build?(y/n) \c"
                read run_choice
                if [ $run_choice = "y" ]; then
                    if [ -e run.sh ]; then
                        ./run.sh
                    else
                        create_runscript
                        ./run.sh
                    fi
                fi
                                            ;;
            * )
                echo "[!] WARNING: Invalid input" ;;
            esac
        fi

    else
        KERNEL_BUILD=y
        BUSYBOX_BUILD=y
        install_packages
    fi

else

    #No Folder, so Install freshly
    mkdir -p minimalistic_linux-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION
    cd minimalistic_linux-K-$KERNEL_VERSION-B-$BUSYBOX_VERSION

    install_packages
fi