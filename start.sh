#!/bin/sh
# SSH
if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

# set password root is root
SSHPASS1=${SSHPASS:-root}
echo "root:$SSHPASS1" | chpasswd
/usr/sbin/sshd

run()
{ 
    chmod 0600 /data/etc/fetchmailrc
    chown fetchmail:fetchmail /data/etc/
    chown fetchmail:fetchmail /data/etc/fetchmailrc
    touch /data/log/fetchmail.log
    chown fetchmail:fetchmail /data/log/fetchmail.log
    # run cron daemon, which executes the logrotate job
    crond
    # collect log informations for docker logs or docker-compose logs
    tail -n 50 -f /data/log/fetchmail.log &
    # run fetchmail as endless loop with reduced permissions
    su -s /bin/sh -c '/bin/sh /bin/fetchmail_daemon.sh' fetchmail
}

run

