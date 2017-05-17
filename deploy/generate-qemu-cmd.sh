#!/bin/bash
set -x

build_hostfwd_param()
{
    local idx=${1}
    local box_path="${2}"
    rm -f ${box_path}/kvm.open_ports

    for (( i=0 ; i < ${#PORT_FORWARD[@]} ; i+=2 )) ; do
        port="${PORT_FORWARD[i]}"
        host="${PORT_FORWARD[$(( i + 1 ))]}"
        access_port=$(( port + 10000 + ( idx  * 10 ) ))
        # make sure the access port is not used
        until [[ ! "${ret_val}" == *"${access_port}-"* ]] ; do
            [[ ! -f ${box_path}/kvm.open_ports ]] && break
            access_port=$(( access_port + 1 ))
        done
        ret_val="${ret_val}hostfwd=tcp::${access_port}-${host}:${port},"
        echo "port: ${access_port} -> ${host}:${port}" >> ${box_path}/kvm.ports
    done

    echo "${ret_val%,*}"
}

build_qemu_cmd()
{
    local idx="${1}"
    local box_path="${2}"
    local vnc_port="${vnc_port:-11050}"
    local serial_port="${serial_port:-14060}"
    local mac_addr="${mac_addr:-02:00:00:00:00:0${idx}}"

    cat <<- EOF > "${box_path}/kvm.cmdline"
qemu-system-x86_64 \
	-machine accel=kvm \
	-cpu ${cpu_type:-qemu64,+vmx} \
	-m ${mem_size:-4096} \
	-smp ${cpu_num:-2} \
	-vnc ${vnc_addr:-localhost}:$(( vnc_port + idx)) \
	-serial telnet:127.0.0.1:$(( serial_port + idx )),server,nowait \
	-serial pty \
	-drive file=${box_path}/box.img,media=disk,if=virtio,format=${format:-qcow2} \
	-net nic,vlan=0,macaddr=${mac_addr},model=virtio,addr=$(( 3 + idx )) \
	-net user,vlan=0,$(build_hostfwd_param ${idx} ${box_path}) \
	-daemonize \
	-pidfile ${box_path}/${vm_name:-box_${idx}}.pid
EOF
}
