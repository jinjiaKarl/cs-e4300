#!/usr/bin/env bash

## NAT traffic going to the internet
route add default gw 172.16.16.1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## Set up virtual network
cat > /etc/eth0 <<EOL
#!/bin/sh
ip link add eth0 type dummy
ip addr add 10.1.0.99/16 dev eth0 label eth0:vpn
EOL
chmod +x /etc/eth0
cat > /etc/cron.d/eth0 <<EOL
@reboot /etc/eth0
EOL
/etc/eth0

## Redirect to cloud with Destination NAT
iptables -t nat -A PREROUTING -p tcp -d 10.1.0.99 --dport 8080 -j DNAT --to 172.30.30.30:8080

## Iptables rules (firewall)
### Accept internal / virtual machine traffic
iptables -A INPUT -i enp0s9 -s 10.1.0.0/16 -j ACCEPT
iptables -A INPUT -i enp0s3 -j ACCEPT
### Accept IKE sessions from the cloud
iptables -A INPUT -m conntrack -i enp0s8 -s 172.30.30.30 --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT
### Drop everything else
iptables -A INPUT -j DROP

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Certificates
cat > /etc/ipsec.d/cacerts/caCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB5jCCAW2gAwIBAgIIKN1tgkU2rL0wCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMjEyMDUwMDU5MTNaFw0zMjEyMDQwMDU5MTNaMDkxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRgwFgYDVQQDEw9DU0U0MzAwIFJvb3QgQ0EwdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAASc8Q/7felpOdR7nLfnXkIz53Knq+AeVDn+TIa/9TbH
X2w7gHas+NClnEDHK1a5BgWOsF1m+MjU8BRe94Oa/MeR7xMT2qIIy/mlHIRpOTc/
B1Msa7CX6B4jIaJTXr8idgGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
BAQDAgEGMB0GA1UdDgQWBBSIXEjItP88lAV7Qtdq7pevRzNEdTAKBggqhkjOPQQD
BANnADBkAjAtZd2Rz0tIb31DS+17jkgFbIgvBf1XHA0e75/Cp3uSo68NsyXipGkB
uX8rhF0mB/oCMGC2SrUaBFX2znWd1tTzfoLTN+GnLoBAVkwdXDKy7Ci3IDHmEic1
RrZOG4C9MBBnOg==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/cacerts/intCaCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICCjCCAZCgAwIBAgIIBkryXpq6KXswCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMjEyMDUwMDU5MTNaFw0yNzEyMDUwMDU5MTNaMDgxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRcwFQYDVQQDEw5DU0U0MzAwIElOVCBDQTB2MBAGByqG
SM49AgEGBSuBBAAiA2IABHLlFzJI6UxPq5HiuYJOcXhhsO02gYw9ov6fOzNklRWF
kMPD00LkVlksZDCsCMAFaNMCikYyaZGV2PapFxHlnEA8PvH5Guh9w4WInhxbnzr5
S5BLHK3KNNpOaUvCZ4zj+6NmMGQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8B
Af8EBAMCAQYwHQYDVR0OBBYEFFvWNjSXJ01k734Y6eDo/umGDpSPMB8GA1UdIwQY
MBaAFIhcSMi0/zyUBXtC12rul69HM0R1MAoGCCqGSM49BAMEA2gAMGUCMCCJKRBN
Ru12yPI+bY7MzZBwmbLOLelLH+QBlDqZ06rrcV/bbW+OKEEih5ZllpjQhwIxAKX7
gjvEr/bwKihlAcoT+3aRzHrLaxs1EhD25Qhq+tHg0zze8d1VucuQpdpOjjOOiA==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteACert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+TCCAX+gAwIBAgIIOnvDkxgfobIwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIyMTIwNTAwNTkxM1oXDTI1MDYwNTAwNTkxM1owRTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxJDAiBgNVBAMTG0NTRTQzMDAgU2l0ZSBBIDE3Mi4xNi4x
Ni4xNjB2MBAGByqGSM49AgEGBSuBBAAiA2IABEjnLhPKue7JQGcgCmyj8hEriQFI
EaRq7vKkmKmev6AWGVnHGCvRFrfO3KRk+G03+gtDjSX/SWIgs6kcb2olEeQQWA6h
nxHMxxbLYu3bqk5Jb9tDR3zRXpa7oUROIP0Xz6NJMEcwHwYDVR0jBBgwFoAUW9Y2
NJcnTWTvfhjp4Oj+6YYOlI8wDwYDVR0RBAgwBocErBAQEDATBgNVHSUEDDAKBggr
BgEFBQcDAjAKBggqhkjOPQQDBANoADBlAjEA+glFd8LPloJfASITJ7qSX8yrO4ZT
hFpu5CU+fVgTjQ7F2jR7DmNWerrDoAI4Nh1xAjBHAUweTg/hZwndL0VbWDuYzdRh
Uum9LEia8lYuoU+VwMo9pKwPWfN3OepgCeK3Otw=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/cloudCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+DCCAX6gAwIBAgIIfnHbZk6FFuMwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIyMTIwNTAwNTkxM1oXDTI1MDYwNTAwNTkxM1owRDELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxIzAhBgNVBAMTGkNTRTQzMDAgQ2xvdWQgMTcyLjMwLjMw
LjMwMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEQAGyaIYhQAWim5Ebyd87gGx5dxIl
gk8aG8SlVftBU3O9jqleCiSZAtJutCstjKoUrUBrMyuJ5y6+15Qc3HASRXiDJFeJ
oovMLPG42J73InwpiFYPh8t1GVBBOWYf6psjo0kwRzAfBgNVHSMEGDAWgBRb1jY0
lydNZO9+GOng6P7phg6UjzAPBgNVHREECDAGhwSsHh4eMBMGA1UdJQQMMAoGCCsG
AQUFBwMBMAoGCCqGSM49BAMEA2gAMGUCMQDUlsq4yUYUmxCx9IO0bgkDTPTSI94B
q9xB/8GWRpGpOsBGoLxo8yTATk6yYZn4Z7sCMChlDqVxhd0LF6asyYr9lFJ5YZxk
N5c8LVn/1tuP6vr8rkUIDVi2ey4wN31nF+m0rw==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/private/siteAKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDAke1xLXlsa1FsCZ0RelkI1hylqow9Y5UkxG7LvHnrqCFi3WNt2A47f
Ok3x+T0rgB6gBwYFK4EEACKhZANiAARI5y4TyrnuyUBnIApso/IRK4kBSBGkau7y
pJipnr+gFhlZxxgr0Ra3ztykZPhtN/oLQ40l/0liILOpHG9qJRHkEFgOoZ8RzMcW
y2Lt26pOSW/bQ0d80V6Wu6FETiD9F88=
-----END EC PRIVATE KEY-----
EOL

## Certificate revocation lists
mv /home/vagrant/crls /etc/ipsec.d

## Ipsec config
echo ": ECDSA siteAKey.pem" >> /etc/ipsec.secrets

cat > /etc/ipsec.conf <<EOL
conn a-to-cloud
        keyexchange=ikev2
        leftfirewall=yes
        rightfirewall=yes
        left=172.16.16.16
        leftsubnet=172.16.16.16/32
        leftid=172.16.16.16
        leftcert=siteACert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Site A 172.16.16.16"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        right=172.30.30.30
        rightsubnet=172.30.30.30/32
        rightcert=cloudCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Cloud 172.30.30.30"
        rightca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        ike=aes256gcm16-prfsha384-ecp384!
        esp=aes256gcm16-ecp384!
        auto=start
        dpdaction=hold
EOL

## Restart ipsec for updates to take effect
ipsec restart
