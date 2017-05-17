
output="$(ssh -qi ~/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null | sed 's/&gt;/\>/g')"

save_dbimg_id=false
save_appimg_id=false

if check_find_line_with "echo" "=\${DB_IMAGE_ID}" ">" "\$WRITE_FILE" <<< "$output" ||
        check_find_line_with "echo" "=\${DB_IMAGE_ID}" ">" "\${WRITE_FILE}" <<< "$output" ; then
    save_dbimg_id=true
fi 

if check_find_line_with "echo" "=\${APP_IMAGE_ID}" ">" "\${WRITE_FILE}" <<< "$output" ||
        check_find_line_with "echo" "=\${APP_IMAGE_ID}" ">" "\${WRITE_FILE}" <<< "$output" ; then
    save_appimg_id=true
fi

check_message $save_dbimg_id "Db image id saved to \${WRITE_FILE}"
check_message $save_appimg_id "App image id saved to \${WRTIE_FILE}"


