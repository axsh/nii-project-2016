#!/bin/bash

reportfailed()
{
    echo "Script failed...exiting. ($*)" 1>&2
    exit 255
}

[ "$1" != "" ] && fullpath="$(readlink -f $1)"

export ORGCODEDIR="$(cd "$(dirname $(readlink -f "$0"))" && pwd -P)" || reportfailed

if [ "$DATADIR" = "" ]; then
    # Default to putting output in the code directory, which means
    # a separate clone of the repository for each build
    DATADIR="$ORGCODEDIR"
fi
source "$ORGCODEDIR/simple-defaults-for-bashsteps.source"

# avoids errors on first run, but maybe not good to change state
# outside of a step
touch "$DATADIR/datadir.conf"

source "$DATADIR/datadir.conf"
: ${imagesource:=$fullpath}

DATADIR="$DATADIR" "$ORGCODEDIR/ind-steps/build-1box/build-1box.sh"

(
    $starting_group "Set up install Jupyter in VM"
    (
	$starting_group "Set up vmdir"
	[ -x "$DATADIR/vmdir/kvm-boot.sh" ]
	$skip_group_if_unnecessary
	(
	    $starting_step "Make vmdir"
	    [ -d "$DATADIR/vmdir" ]
	    $skip_step_if_already_done ; set -e
	    mkdir "$DATADIR/vmdir"
	    # increase default mem to give room for a wakame instance or two
	    echo ': ${KVMMEM:=4096}' >>"$DATADIR/vmdir/datadir.conf"
	) ; prev_cmd_failed

	DATADIR="$DATADIR/vmdir" \
	       "$ORGCODEDIR/ind-steps/kvmsteps/kvm-setup.sh" \
	       "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz"
    ) ; prev_cmd_failed

    (
	$starting_group "Install Jupyter in the OpenVZ 1box image"
	[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ]
	$skip_group_if_unnecessary

	# TODO: this guard is awkward.
	[ -x "$DATADIR/vmdir/kvm-boot.sh" ] && \
	    "$DATADIR/vmdir/kvm-boot.sh"

	(
	    $starting_step "Do short set of script lines to install jupyter"
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
		[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ] || \
		    [ "$("$DATADIR/vmdir/ssh-to-kvm.sh" which jupyter 2>/dev/null)" = "/home/centos/anaconda3/bin/jupyter" ]
	    }
	    $skip_step_if_already_done ; set -e

	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<'EOF'
wget  --progress=dot:mega \
   https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda3-2.4.1-Linux-x86_64.sh

chmod +x Anaconda3-2.4.1-Linux-x86_64.sh

./Anaconda3-2.4.1-Linux-x86_64.sh -b

echo 'export PATH="/home/centos/anaconda3/bin:$PATH"' >>.bashrc

export PATH="/home/centos/anaconda3/bin:$PATH"

conda install -y jupyter
EOF
	) ; prev_cmd_failed

	(
	    $starting_step "Install bash_kernel"
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
		## TODO: the next -f test is probably covered by the group
		[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ] || \
		    "$DATADIR/vmdir/ssh-to-kvm.sh" '[ -d ./anaconda3/lib/python3.5/site-packages/bash_kernel ]' 2>/dev/null
	    }
	    $skip_step_if_already_done; set -e

	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<'EOF'
pip install bash_kernel
python -m bash_kernel.install
EOF
	) ; prev_cmd_failed

	(
	    $starting_step "Replace bash_kernel's kernel.py with our version"
	    # TODO: make sure this keeps working if the bash_kernel upstream code is updated
	    ## e.g., maybe check that md5 of original has not changed, or maybe use patch....
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] &&
		"$DATADIR/vmdir/ssh-to-kvm.sh" '[ -f ./anaconda3/lib/python3.5/site-packages/bash_kernel/kernel.py.bak ]' 2>/dev/null
	    $skip_step_if_already_done; set -e

	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<'EOF'

mv ./anaconda3/lib/python3.5/site-packages/bash_kernel/kernel.py ./anaconda3/lib/python3.5/site-packages/bash_kernel/kernel.py.bak

cp -al ./bin/kernel.py ./anaconda3/lib/python3.5/site-packages/bash_kernel/kernel.py

EOF
	) ; prev_cmd_failed

	(
	    $starting_step "Set default password for jupyter, plus other easy initial setup"
	    JCFG="/home/centos/.jupyter/jupyter_notebook_config.py"
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
		[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ] || \
		    "$DATADIR/vmdir/ssh-to-kvm.sh" grep sha1 "$JCFG" 2>/dev/null 1>&2
	    }
	    $skip_step_if_already_done ; set -e

	    # http://jupyter-notebook.readthedocs.org/en/latest/public_server.html
	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<EOF
set -x
[ -f "$JCFG" ] || jupyter notebook --generate-config

# set default password
saltpass="\$(echo $'from notebook.auth import passwd\nprint(passwd("${JUPYTER_PASSWORD:=warmwinter}"))' | python)"
echo "c.NotebookApp.password = '\$saltpass'" >>"$JCFG"
echo "c.NotebookApp.ip = '*'" >>"$JCFG"

# move jupyter's default directory away from \$HOME
mkdir notebooks
echo "c.NotebookApp.notebook_dir = 'notebooks'" >>"$JCFG"

# autostart on boot
echo "(setsid su - centos -c '/home/centos/anaconda3/bin/jupyter notebook' > /var/log/jupyter.log 2>&1) &" | \
   sudo bash -c "cat >>/etc/rc.local"
EOF
	) ; prev_cmd_failed


	# function is called remotely in the next step below
	do_register_keypair()
	{
	    cat <<'EOS' > mykeypair
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA6KmXs11l/2WUIBDYmTB0T+BXwwCXT+RP/CTVtxq1Tnq8biwa
pDxHuYgvQWSOOH7DIZq/+GU+P69BBWAbnd1LNkWDOoMmnaIthXQBptZupYFfYiKA
Uh4UH0L0wwenifE2yV+SdWLT6FEiiQ2RTatqK1xiWSwvduWkeMA+dW1NbSk0XmEh
Z76QLsRxrs9JF4jqPXJVulzgjnD9Z5tkNY7MyfD1PNJcM2+MS8XmAApxLQLrfxEl
LZMsgvzvFVec45siOiG+VTWbGADc3lBSHIj2pt6aZDLkOhSnZegmsciVFQk1ulLF
jGjD2LoqYT5/UirpwQsElsjWTEEbBZzV10AVlwIDAQABAoIBAQCdnQ4cv1/ypXC0
TFU/abjRx8wMWWEoCSY6TQXOtjQvByyRgiVGL2PzhxNkPGewVAeCw1/bOVLzN5lX
t+Tdi+WAzZR51hEZ5pzp9E2OJWPtkPf59h9yAdhl2SkQ2iWgaB1STAFermWZ0yUP
LXbK5B3XZA1oFWvOIwHJn4pwaGx0TpOtEjPHiEkJxj1SRAzN377Uu3SNz9UsRrfQ
3v7iLxrPvwqhXIBo1VzQIliWzH5/IQ6xAqAsMLTo0uJ+d1wkoZ6nGkjt+LYD5hyD
Ov76lOjlevkPu3BENwwt3Este2d00gOC2Qt649P/chd9B8vc4ZZ8F3bPVfmfdiJt
fYRPaF5ZAoGBAP5vEA/lWH5xN6dB7j+wFPLAP7+8H2jz4aBcDWCiDjoMA4JRvc8V
gJxaW33b8gbP39byZAfBLNWHPE+4q/95CW7TkXnzdCR9HxeKC77jnBXg6wX5zist
E/cDMPykATtMqUFf/K46lPjaUbn4gmLEkc9lS7V+ySoPMdMUG6zqQf2DAoGBAOoY
OPSHu2Y7R4V3BnzNeGz6PCrohz7IjqjSD74KhAhuFCM7w+ymDmk2xSIR4S4F7qlD
mBodXpncqxQMtkF2pRRGDefbTXW5m+lWOy/DrsYV0bqy5OqA2r7Ukj5M0o97S8D1
vhTxwXCehx8GX8RlbybuMkfpB2NefMxakG+BAX9dAoGASPS/vk8dGOSN+L/G+Swc
VZ8aqHfg6c9Emx7KFzNgsPRQ7UVTD9YykqK2KViwBZQFszS9yhtyJ6gnexSQ/ShP
tB+mTzmny+60w6Mpywqo7v0XZxdCLs82MlYP7eF5GO/aeIx1f9/8Z37ygEjp2jhT
NwzssJYySIUi3Eufw+1IDtECgYEAr3NOJMAiTWH6neZyn1Fkg9EdDU/QJdctTQx7
rgS1ppfSUgH2O0TOIj9hisJ50gOyN3yo4FHI2GrScimA5BmnakWDIJZ2PNjLKRxv
KcJxGJe75EE2XygKSuKJZVYwrkdLpKjKOWpkgCLgxPkDB/C6WSRH3SujVO+5e3QZ
MukulSUCgYBMtuQ6VMrlMTedLW6ryd8VYsVNZaAGuphejFCCuur13M/1wHrRUzqM
hECAngl6fus+weYMiQYx1V8oxz3tBdYO8KKG8pnQySTt5Dln19+vqH2+18RWDKtH
0rwxRJ4Rc3wKFVwK+gz6NsBvftnQAK52qWip71tPY7zt9LeWWJv08g==
-----END RSA PRIVATE KEY-----
EOS
	    chmod 600 mykeypair

	    cat <<'EOS' > mykeypair.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDoqZezXWX/ZZQgENiZMHRP4FfDAJdP5E/8JNW3GrVOerxuLBqkPEe5iC9BZI44fsMhmr/4ZT4/r0EFYBud3Us2RYM6gyadoi2FdAGm1m6lgV9iIoBSHhQfQvTDB6eJ8TbJX5J1YtPoUSKJDZFNq2orXGJZLC925aR4wD51bU1tKTReYSFnvpAuxHGuz0kXiOo9clW6XOCOcP1nm2Q1jszJ8PU80lwzb4xLxeYACnEtAut/ESUtkyyC/O8VV5zjmyI6Ib5VNZsYANzeUFIciPam3ppkMuQ6FKdl6CaxyJUVCTW6UsWMaMPYuiphPn9SKunBCwSWyNZMQRsFnNXXQBWX knoppix@Microknoppix
EOS

	    /opt/axsh/wakame-vdc/dcmgr/bin/vdc-manage keypair add \
						      --uuid ssh-cicddemo \
						      --account-id a-shpoolxx \
						      --private-key mykeypair \
						      --public-key mykeypair.pub \
						      --description cicddemo \
						      --service-type std \
						      --display-name cicddemo
	} # end of register_hva() function

	(
	    $starting_step "Install sshkey into Wakame-vdc database"
	    echo "select * from ssh_key_pairs; " | \
		"$DATADIR/vmdir/ssh-to-kvm.sh" mysql -u root wakame_dcmgr 2>/dev/null | \
		grep cicddemo >/dev/null
	    $skip_step_if_already_done
	    (
		declare -f do_register_keypair
		echo do_register_keypair
	    ) | "$DATADIR/vmdir/ssh-to-kvm.sh"
	    # this step was adapted from code at:
	    # https://github.com/axsh/nii-image-and-enshuu-scripts/blob/changes-for-the-2nd-class/wakame-bootstrap/wakame-vdc-install-hierarchy.sh#L426-L477
	)
	
	(
	    $starting_step "Install security group into Wakame-vdc database"
	    echo "select * from security_groups; " | \
		"$DATADIR/vmdir/ssh-to-kvm.sh" mysql -u root wakame_dcmgr 2>/dev/null | \
		grep cicddemo >/dev/null
	    $skip_step_if_already_done
	    "$DATADIR/vmdir/ssh-to-kvm.sh" \
		/opt/axsh/wakame-vdc/dcmgr/bin/vdc-manage securitygroup add \
					      --uuid sg-cicddemo \
					      --account-id a-shpoolxx \
					      --description cicddemo \
					      --service-type std \
					      --display-name cicddemo \
					      --rule - <<EOS
icmp:-1,-1,ip4:0.0.0.0/0
tcp:22,22,ip4:0.0.0.0/0
tcp:80,80,ip4:0.0.0.0/0
tcp:8080,8080,ip4:0.0.0.0/0
EOS
	    # this step was adapted from code at:
	    # https://github.com/axsh/nii-image-and-enshuu-scripts/blob/changes-for-the-2nd-class/wakame-bootstrap/wakame-vdc-install-hierarchy.sh#L486-L506
	)
	
	(
	    $starting_step "Hack Wakame-vdc to always set openvz's privvmpages to unlimited"
	    rubysource=/opt/axsh/wakame-vdc/dcmgr/lib/dcmgr/drivers/hypervisor/linux_hypervisor/linux_container/openvz.rb
	    "$DATADIR/vmdir/ssh-to-kvm.sh" sudo grep 'privvmpage.*unlimited' "$rubysource" 1>/dev/null 2>&1
	    $skip_step_if_already_done
	    (
		cat <<EOF
	    rubysource='$rubysource'
EOF
		cat <<'EOF'
            sudo cp "$rubysource" /tmp/ # for debugging
	    orgcode="$(sudo cat "$rubysource")"
            # original line: sh("vzctl set %s --privvmpage %s --save",[hc.inst_id, (inst[:memory_size] * 256)])
	    replaceme='vzctl set %s --privvmpage'
	    while IFS= read -r ln; do
		  if [[ "$ln" == *${replaceme}* ]]; then
                     echo "## $ln"
                     echo '        sh("vzctl set %s --privvmpage unlimited --save",[hc.inst_id])'
                     cat # copy the rest unchanged
                     break
		  fi
		  echo "$ln"
	    done <<<"$orgcode" | sudo bash -c "cat >'$rubysource'"
EOF
	    ) | "$DATADIR/vmdir/ssh-to-kvm.sh"
	)
	
	# TODO: this guard is awkward.
	[ -x "$DATADIR/vmdir/kvm-shutdown-via-ssh.sh" ] && \
	    "$DATADIR/vmdir/kvm-shutdown-via-ssh.sh"
	true # needed so the group does not throw an error because of the awkwardness in the previous command
    ) ; prev_cmd_failed

    (
	$starting_step "Make snapshot of image with jupyter installed"
	[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ]
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmdir/"
	tar czSvf 1box-openvz-w-jupyter.raw.tar.gz 1box-openvz.netfilter.x86_64.raw
    ) ; prev_cmd_failed
) ; prev_cmd_failed

(
    $starting_step "Expand fresh image from snapshot of image with Jupyter installed"
    [ -f "$DATADIR/vmdir/1box-openvz.netfilter.x86_64.raw" ]
    $skip_step_if_already_done ; set -e
    cd "$DATADIR/vmdir/"
    tar xzSvf 1box-openvz-w-jupyter.raw.tar.gz
) ; prev_cmd_failed

# TODO: this guard is awkward.
[ -x "$DATADIR/vmdir/kvm-boot.sh" ] && \
    "$DATADIR/vmdir/kvm-boot.sh"

(
    $starting_step "Synchronize notebooks/ to VM"
    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
	"$DATADIR/vmdir/ssh-to-kvm.sh" '[ "$(ls notebooks)" != "" ]' 2>/dev/null
    }
    $skip_step_if_already_done; set -e

    "$DATADIR/notebooks-sync.sh" tovm bin
    "$DATADIR/notebooks-sync.sh" tovm
) ; prev_cmd_failed

(
    $starting_step "Setup .ssh/config and .musselrc"
    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
	"$DATADIR/vmdir/ssh-to-kvm.sh" '[ -f ~/.ssh/config ]' 2>/dev/null
    }
    $skip_step_if_already_done; set -e

	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<'EOF'
sudo chown centos:centos ~/.ssh # fix to bug in vmbuilder??
chmod 700 ~/.ssh
cat >~/.ssh/config <<EEE
Host *
  StrictHostKeyChecking no
  TCPKeepAlive yes
  UserKnownHostsFile /dev/null
  ForwardAgent yes
EEE

cat >~/.musselrc <<EEE
DCMGR_HOST=127.0.0.1
account_id=a-shpoolxx
EEE
EOF
) ; prev_cmd_failed
