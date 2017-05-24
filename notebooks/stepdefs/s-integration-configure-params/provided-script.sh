#!/bin/bash

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

write_file_path="$(ssh root@${INSTANCE_IP} -p ${INSTANCE_PORT} -i mykeypair cat /var/lib/jenkins/jobs/tiny_web.imagebuild/workspace/jenkins-tiny_web.imagebuild* | tail -1)"
write_file="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${write_file_path}  2> /dev/null)"
eval echo "${write_file}"

parent_element="name"
child_element="defaultValue"

while read line ; do
  case "$line" in
    *"<$parent>"*)
        inside_parent=true
        parent_value="$(grep -oP '(?<=<'$parent_element'>).*?(?=</'$parent_element'>)' <<< "$line")"
        [[ -n "${!parent_value}" ]] || continue
        ;;
    *"</$parent>"*)
        unset parent_value
        inside_parent=false ;;
  esac

  if $inside_parent ; then
      child_value="$(grep -oP '(?<=<'$child_element'>).*?(?=</'$child_element'>)' <<< "$line")"
      [[ -n "$child_value" ]] && {
          sed -i -e 's/'$child_value'/'${!parent_value}'/g' "${1}"
          unset child_value
      }
  fi
done < "$(dirname $0)"/xml-data/properties.data

[[ -f $(dirname $0)/stepdata.conf ]] && . $(dirname $0)/stepdata.conf
[[ -f $(dirname $0)/pre-exec.sh ]] && . $(dirname $0)/pre-exec.sh

bash
