#!/bin/sh

echo "Installing Kerberos KDC server"
export DEBIAN_FRONTEND=noninteractive
apt-get install -yq krb5-admin-server
apt-get install -yq krb5-kdc

echo "Using default configuration"
REALM="EXAMPLE.COM"

HOSTNAME=`hostname`
cat >/etc/krb5.conf <<EOF
[logging]
    default = FILE:/var/log/krb5libs.log
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmind.log

[libdefaults]
    default_realm = ${REALM}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${REALM} = {
        kdc = ${HOSTNAME}
        admin_server = ${HOSTNAME}
    }

[domain_realm]
    .example.com = ${REALM}
    example.com = ${REALM}
EOF

## update kdc.conf
echo "Updating kdc.conf file ..."
mkdir -p /etc/kerberos/krb5kdc
cat >/etc/kerberos/krb5kdc/kdc.conf <<EOF
[kdcdefaults]
    kdc_ports = 88
    kdc_tcp_ports = 88

[realms]
    ${REALM} = {

    #master_key_type = aes256-cts
    acl_file = /var/kerberos/krb5kdc/kadm5.acl
    dict_file = /usr/share/dict/words
    admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
    supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
    }
EOF
   
echo "Creating KDC database"
/usr/sbin/kdb5_util create -s -P hadoop

echo "Creating kadm5.acl file"
mkdir -p /var/kerberos/krb5kdc/
cat >/var/kerberos/krb5kdc/kadm5.acl <<EOF
*/admin@${REALM}    *
EOF

echo "Creating administriative account. Principal: admin/admin. Password: ambari"
kadmin.local -q "addprinc -pw ambari admin/admin"

echo "Starting kerberos admin services"
service krb5-admin-server start
echo "Kerberos KDC krb5kdc service"
service krb5-kdc start
