folders=(
    BUILD
    BUILDROOT
    SRPMS
    SPECS
    SOURCES
    RPMS
)

for folder in "${folders[@]}" ; do
    ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} "[[ -d \${HOME}/rpmbuild/$folder ]]" 2> /dev/null
    passed=$?
    check_message $passed "\${HOME}/${folder}"
done
