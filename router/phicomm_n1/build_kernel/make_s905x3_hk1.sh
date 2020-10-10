#!/bin/bash

#===============================================================================================================
# https://github.com/ophub/op
# Description: Use Phicomm N1 firmware to build s905x3 related firmware (s905x3 hk1)
# Function: Use Phicomm N1 firmware to build s905x3 related firmware
# Copyright (C) 2020 https://github.com/ophub/op
#===============================================================================================================
#
# example: ~/op/router/phicomm_n1/build_kernel/
# ├── flippy
# │   └── phicomm.img
# └── make_s905x3_hk1.sh
#
# Usage: Use Ubuntu 18 LTS 64-bit
# 01. Log in to the home directory of the local Ubuntu system
# 02. git clone https://github.com/ophub/op.git
# 03. cd ~/op/router/phicomm_n1/build_kernel/
# 04. Put Phicomm N1 firmware ${flippy_file} file into ${flippy_folder}
# 05. Run: sudo ./make_s905x3_hk1.sh
# 06. The generated files path: ~/op/router/phicomm_n1/build_kernel/out/openwrt_${convert_firmware}.img
# 07. git push to your github
# 08. Github.com Build openwrt: ~/op/.github/workflows/build-openwrt-s905x3-hk1.yml
#
# Tips: If run 'sudo ./make_s905x3_hk1.sh ${firmware_key}' is 'Command not found'
# 01. chmod +x make_s905x3_hk1.sh
# 02. vi make_s905x3_hk1.sh
# 03. :set ff=unix
# 04. :wq
#
# ❗❗❗ Warning:
# According to Flippy’s introduction, the difference between s905x3 and Phicomm-N1 firmware is the difference 
# in the dtb file specified in boot/uEnv.txt, and the contents of other firmware are common. 
# This script downloads the N1 firmware that has been built, and modifies the path to the dtb file. 
# Since the s905x3 device has not been purchased, the firmware has not been personally tested, 
# and the script has just been online, there may be unknown bugs. 
# You can also test other N1 dtb paths according to the introduction.
#
# ✅ /boot/uEnv.txt:  
#    #Method: Add # in front of the dtb file path of Phicomm N1, and remove the # in front of the firmware you need. E.g
#
#    #Phicomm N1
#    #FDT=/dtb/amlogic/meson-gxl-s905d-phicomm-n1.dtb
#    #Phicomm N1 (thresh)
#    #FDT=/dtb/amlogic/meson-gxl-s905d-phicomm-n1-thresh.dtb
#
#    #X96 Max+ (S905X3 for 100m)
#    #FDT=/dtb/amlogic/meson-sm1-x96-max-plus-100m.dtb
#    #X96 Max+ (S905X3 for 1000M) [tag: s905x3]
#    #FDT=/dtb/amlogic/meson-sm1-x96-max-plus.dtb
#
#    #HK1 BoX (S905X3 for 1000M) [tag: hk1]
#    FDT=/dtb/amlogic/meson-sm1-hk1box-vontar-x3.dtb
#=============================================================================================================

# Modify Phicomm N1 firmware's folder & *.img file name
flippy_folder="flippy"
flippy_file="phicomm.img"

# Default setting ( Don't modify )
build_tmp_folder="tmp"
boot_tmp=${build_tmp_folder}/boot
root_tmp=${build_tmp_folder}/root
build_save_folder="out"
[ -d ${build_tmp_folder} ] && rm -rf ${build_tmp_folder} 2>/dev/null
firmware_list=("s905x3" "hk1")
convert_firmware=${1}

# echo color codes
echo_color() {

    this_color=${1}
        case "${this_color}" in
        red)
            echo -e " \033[1;31m[ ${2} ]\033[0m ${3}"
            echo -e "-------------------${1}---------------------"
            echo -e "Current path -PWD-: [ ${PWD} ]"
            echo -e "Situation -lsblk-: [ $(lsblk) ]"
            echo -e "Directory file list -ls-: [ $(ls .) ]"
            echo -e "-------------------${1}---------------------"
            exit 1
            ;;
        green)
            echo -e " \033[1;32m[ ${2} ]\033[0m ${3}"
            ;;
        yellow)
            echo -e " \033[1;33m[ ${2} ]\033[0m ${3}"
            ;;
        blue)
            echo -e " \033[1;34m[ ${2} ]\033[0m ${3}"
            ;;
        purple)
            echo -e " \033[1;35m[ ${2} ]\033[0m ${3}"
            ;;
        *)
            echo -e " \033[1;30m[ ${2} ]\033[0m ${3}"
            ;;
        esac

}

# Check files
check_build_files() {

      if  [  ! -f ${flippy_folder}/${flippy_file} ]; then
        echo_color "red" "(1/4) Error: Files does not exist"  "\n \
        Please check if the following one files exist: \n \
        ${flippy_folder}/${flippy_file} "
      else
        # begin run the script
        echo_color "purple" "Start convert"  "Use [ ${flippy_file} ] Convert to [ ${convert_firmware} ] ..."
        echo_color "green" "(1/4) End check_build_files" "Use: ${flippy_file}..."
      fi

}

#losetup & mount ${flippy_file}
losetup_mount_img() {

     mkdir -p ${boot_tmp} ${root_tmp}

     cp -f ${flippy_folder}/${flippy_file}  ${flippy_folder}/make_${flippy_file} && sync
     chmod -R 777 ${flippy_folder} ${build_tmp_folder}

     lodev=$(losetup -P -f --show ${flippy_folder}/make_${flippy_file})
     [ $lodev ] || ( echo_color "red" "(2/4) losetup make_${flippy_file} failed!" "..." )
     mount ${lodev}p1 ${boot_tmp}
     [ $lodev ] || ( echo_color "red" "(2/4) mount ${lodev}p1 failed!" "..." )
     mount ${lodev}p2 ${root_tmp}
     [ $lodev ] || ( echo_color "red" "(2/4) mount ${lodev}p2 failed!" "..." )

     echo_color "green" "(2/4) End losetup_mount_img" "Use: ${lodev} ..."

}

#edit uEnv.txt from ${boot_tmp}
edit_uenv() {

  cd ${boot_tmp}

        if [  ! -f "uEnv.txt" ]; then
           echo_color "red" "(3/4) Error: uEnv.txt Files does not exist"  "\n \
           Please check if the following one files exist: \n \
           ${boot_tmp}/uEnv.txt"
        fi
        
        no_firmware=false
        firmware_dtb=${1}
        case "${firmware_dtb}" in
        s905x3)
            old_s905x3_dtb="#FDT=\/dtb\/amlogic\/meson-sm1-x96-max-plus.dtb"
            new_s905x3_dtb="FDT=\/dtb\/amlogic\/meson-sm1-x96-max-plus.dtb"
            sed -i "s/${old_s905x3_dtb}/${new_s905x3_dtb}/g" uEnv.txt
            echo_color "yellow" "(3/4) s905x3: convert completed" "..."
            ;;
        hk1)
            old_hk1_dtb="#FDT=\/dtb\/amlogic\/meson-sm1-hk1box-vontar-x3.dtb"
            new_hk1_dtb="FDT=\/dtb\/amlogic\/meson-sm1-hk1box-vontar-x3.dtb"
            sed -i "s/${old_hk1_dtb}/${new_hk1_dtb}/g" uEnv.txt
            echo_color "yellow" "(3/4) hk1: convert completed" "..."
            ;;
        *)
            echo_color "red" "(3/4) have no this firmware: ${convert_firmware}"  "Please select from this list: [ ${firmware_list[@]} ]"
            no_firmware=ture
            ;;
        esac

        if [ ${no_firmware} = false ]; then
            old_n1_dtb="FDT=\/dtb\/amlogic\/meson-gxl-s905d-phicomm-n1.dtb"
            new_n1_dtb="#FDT=\/dtb\/amlogic\/meson-gxl-s905d-phicomm-n1.dtb"
            sed -i "s/${old_n1_dtb}/${new_n1_dtb}/g" uEnv.txt
            echo_color "yellow" "(3/4) old-phicomm-n1: dtb have close" "..."
        else
            echo_color "red" "(3/4) Error: Did not match the appropriate type" "..."
        fi

     sync

  echo_color "green" "(3/4) End edit_uenv:" "For: ${firmware_dtb} ..."

}

#umount & del losetup
umount_ulosetup() {

  cd ../../
     
     umount -f ${boot_tmp} 2>/dev/null
     umount -f ${root_tmp} 2>/dev/null
     losetup -d ${lodev} 2>/dev/null
     [ $? = 0 ] || ( echo_color "red" "(4/4) umount ${lodev} failed!" "..." )
     
     [ -d ${build_save_folder} ] || mkdir -p ${build_save_folder}
     cp -f ${flippy_folder}/make_${flippy_file} ${build_save_folder}/openwrt_${firmware_dtb}.img
     chmod -R 777 ${build_save_folder}
     echo_color "yellow" "(4/4) convert to ${build_save_folder}/openwrt_${firmware_dtb}.img" "..."
     
     sync

     rm -rf ${build_tmp_folder}
     rm -rf ${flippy_folder}/make_${flippy_file}

  echo_color "green" "(4/4) End umount_ulosetup"  "Del: ${lodev} ..."

}

#Parameter validity check
if [[ ! -n "${convert_firmware}" ]]; then echo_color "red" "(0/4) Parameter is empty!" "..."; fi
if [[ ! "${firmware_list[@]}"  =~ "${convert_firmware}" ]] &&  [[ ! "${convert_firmware}" = "all" ]]; then echo_color "red" "(0/4) Parameter error" "..."; fi

# Use Phicomm N1 firmware to build s905x3 related firmware (s905x3 hk1)
if [ ${convert_firmware} = "all" ];then
          for x in ${firmware_list[@]}; do
               check_build_files
               losetup_mount_img
               edit_uenv ${x}
               umount_ulosetup
          done
else
               check_build_files
               losetup_mount_img
               edit_uenv ${convert_firmware}
               umount_ulosetup
fi

echo_color "purple" "convert completed"  "..."

# end run the script
