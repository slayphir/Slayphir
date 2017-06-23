#!/bin/sh
# Script para AirOS Ubiquiti
# Remove o worm MF e atualiza para a ultima versao do AirOS disponivel oficial
#
##### NAO ALTERAR ####

#Verifica se o equipamento eh UBNT por algumas caracteristicas
if [ ! -e "/bin/ubntbox" ] ; then
        echo "Nao Ubiquiti"
	exit
fi

#Mostra info do radio
mca-status | grep deviceName
echo "#################################################"

/bin/sed -ir '/mcad/ c ' /etc/inittab
/bin/sed -ir '/mcuser/ c ' /etc/passwd
/bin/rm -rf /etc/persistent/https
/bin/rm -rf /etc/persistent/mcuser
/bin/rm -rf /etc/persistent/mf.tar
/bin/rm -rf /etc/persistent/.mf
/bin/rm -rf /etc/persistent/rc.poststart
/bin/rm -rf /etc/persistent/rc.prestart
#remove v2
/bin/rm -rf /etc/persistent/mf.tgz
/bin/kill -HUP `/bin/pidof init`
/bin/kill -9 `/bin/pidof mcad`
/bin/kill -9 `/bin/pidof init`
/bin/kill -9 `/bin/pidof search`
/bin/kill -9 `/bin/pidof mother`
/bin/kill -9 `/bin/pidof sleep`
#Para processos v2
/bin/kill -9 `/bin/pidof sprd`
/bin/kill -9 `/bin/pidof infect`
/bin/kill -9 `/bin/pidof scan`
################################
 ALTERACOES DE PORTAS - 
cat /tmp/system.cfg | grep -v http > /tmp/system2.cfg
echo "dhcp6c.1.devname=ppp+" >> /tmp/system2.cfg
echo "dhcp6c.1.stateful.pd.1.devname=eth0" >> /tmp/system2.cfg
echo "dhcp6c.1.stateful.pd.1.prefix.len=64" >> /tmp/system2.cfg
echo "dhcp6c.1.stateful.pd.1.status=enabled" >> /tmp/system2.cfg
echo "dhcp6c.1.stateful.status=enabled" >> /tmp/system2.cfg
echo "dhcp6c.1.stateless.status=disabled" >> /tmp/system2.cfg
echo "dhcp6c.1.status=enabled" >> /tmp/system2.cfg
echo "dhcp6c.status=enabled" >> /tmp/system2.cfg
echo "dhcp6d.1.devname=eth0" >> /tmp/system2.cfg
echo "dhcp6d.1.dns.1.server=" >> /tmp/system2.cfg
echo "dhcp6d.1.dns.1.status=disabled" >> /tmp/system2.cfg
echo "dhcp6d.1.dnsproxy=enabled" >> /tmp/system2.cfg
echo "dhcp6d.1.stateful.status=disabled" >> /tmp/system2.cfg
echo "dhcp6d.1.stateless.status=enabled" >> /tmp/system2.cfg
echo "dhcp6d.1.status=enabled" >> /tmp/system2.cfg
echo "dhcp6d.status=enabled" >> /tmp/system2.cfg
echo "httpd.https.status=disabled" >> /tmp/system2.cfg
echo "httpd.port=81" >> /tmp/system2.cfg
echo "httpd.session.timeout=900" >> /tmp/system2.cfg
echo "sshd.port=2222" >> /tmp/system2.cfg
echo "httpd.status=enabled" >> /tmp/system2.cfg
echo "httpd.status=enabled" >> /tmp/system2.cfg

cat /tmp/system2.cfg | uniq > /tmp/system.cfg
rm /tmp/system2.cfg

# Verificar o uso do Compliance Test
# Compliance Teste Country Code = 511
# Brazil Country code = 76
CCATUAL=$(iwpriv wifi0 getCountryID |  sed 's/wifi0     getCountryID://')
if [ $CCATUAL -eq '511' ]; then
        touch /etc/persistent/ct
        /bin/sed -ir '/radio.1.countrycode/ c radio.1.countrycode=511' /tmp/system.cfg
        /bin/sed -ir '/radio.countrycode/ c radio.countrycode=511' /tmp/system.cfg
fi

#Salva modificacoes...
/bin/cfgmtd -w -p /etc/

fullver=`cat /etc/version | sed 's/XW.v//' | sed 's/XM.v//' | sed 's/TI.v//'`

##if [ "$fullver" == "6.0.4" ]; then
if [ "$fullver" == "6.0.4" ]; then
        echo "Atualizado... Done"
        exit
fi

versao=`cat /etc/version | cut -d'.' -f1`
cd /tmp
rm -rf /tmp/firmware.bin
rm -rf /tmp/X*.bin
rm -rf /tmp/T*.bin

if [ "$versao" == "XM" ]; then
        #URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.6/XM.v5.6.6.29183.160526.1225.bin'        
	URL='https://dl.ubnt.com/firmwares/XN-fw/v6.0.4/XM.v6.0.4.30805.170505.1525.bin'
fi
if [ "$versao" == "XW" ]; then
        #URL='http://dl.ubnt.com/firmwares/XW-fw/v5.6.6/XW.v5.6.6.29183.160526.1205.bin'
	URL='https://dl.ubnt.com/firmwares/XW-fw/v6.0.4/XW.v6.0.4.30805.170505.1510.bin'
fi
if [ "$versao" == "TI" ]; then
        #URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.6/TI.v5.6.6.29183.160526.1144.bin'
	URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.9/TI.v5.6.9.29546.160819.1135.bin'
fi

wget -c $URL -O /tmp/firmware.bin

if [ -e "/tmp/firmware.bin" ] ; then
        ubntbox fwupdate.real -m /tmp/firmware.bin
fi

