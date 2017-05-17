output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} '[[ -f /root/rpmbuild/RPMS/x86_64/example-0.1.0-1.el6.x86_64.rpm ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "RPM file exists"

(
    cd .jobs
    taskpat='# Task: *'

    # First, filter down the jobs to only look at ones that
    # have the file name that needs confirming in the output
    # with -l, grep will output lines like: "j-1042/output"
    jobs="$(grep -l "example-0.1.0-1.el6.x86_64.rpm" */output | cut -d / -f 1)"

    # Next, check each jobs and eliminate those that are for other
    # tasks.  Unfortunately, the my-script cells do not give enough
    # information to tell, so keep all my-script cells.
    taskjobs="$(
        for j in $jobs; do
            input="$(cat "$j/input")"
            [[ "$input" == $taskpat ]] && \
                [[ "$input" != *yum-host-confirm-rpm* ]] && continue
            echo "$j"
    done)"

    # Finally, check that the input contains "ls"
    diditjobs="$(
        for j in $taskjobs; do
            input="$(cat "$j/input")"
            [[ "$input" == *ls* ]] && echo "$j"
    done)"

    [ "$diditjobs" != "" ]
    check_message $? "Check for RPM file was performed"
)

# Note: a current limitation of this check is that once a matching job
# appears in the job list, the second check will always pass, even if
# the instance is destroyed.
