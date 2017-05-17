#!/bin/bash
#
# run this file on some bare metal to deploy setup 1box environments
# the 1box image files needs to be placed in the same folder as this script
#
# usage:
# ./deploy-1box <n>, where <n> is the numbers of 1box environments
#
# ports exposed: <current_dir>/boxes/box_<n>/kvm.ports
# kvm boot cmd: <current_dir>/boxes/box_<n>/kvm.cmdline
# kvm pid: <current_dir>/boxes/box_<n>/box_<n>.pid

BOX_CNT=${1}
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ONEBOX_IMG="${CURRENT_DIR}/1box.tar.gz"
PORT_FORWARD=(
    22   0.0.0.0    # ssh on 1box
    22   10.0.2.100 # wakame instance ssh
    9000 0.0.0.0    # wakame gui
    9001 0.0.0.0    # wakame api
    8080 10.0.2.100 # jenkins
)

# [[ -f "${ONEBOX_IMG}" ]] || { echo "Missing 1box image" ; exit 1 ; }
. ${CURRENT_DIR}/generate-qemu-cmd.sh

for (( i=0; i < ${BOX_CNT} ; i++ )) ; do
    echo "Deploying box ${i}"
    box_path="${CURRENT_DIR}/boxes/box_${i}"
    mkdir -p "${box_path}"
    # [[ -f "${box_path}/box.img" ]] || tar Sxvf 1box.tar.gz -C "${box_path}"
    [[ -f "${box_path}/kvm.cmdline" ]] || build_qemu_cmd "${i}" "${box_path}"
    # [[ -f "${box_path}/box_${i}.pid" ]] || {
    #     cat "${box_path}/kvm.cmdline"
    #     ./preconfigure-cienv.sh $(( 22 + 10000 + ( i * 10 ) )) "${box_path}/1box-key"
    # }
done
