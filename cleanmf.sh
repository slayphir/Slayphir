#!/bin/sh
# Alexandre Jeronimo Correa - ajcorrea@gmail.com
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
# Verificar o uso do Compliance Test
# Compliance Teste Country Code = 511
# Brazil Country code = 76
fullver=`cat /etc/version | sed 's/XW.v//' | sed 's/XM.v//' | sed 's/TI.v//'`

##if [ "$fullver" == "5.6.9" ]; then
if [ "$fullver" == "6.1.4" ]; then
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
	URL='https://dl.ubnt.com/firmwares/XN-fw/v6.1.4/XM.v6.1.4.32113.180112.0932.bin'
fi
if [ "$versao" == "XW" ]; then
        #URL='http://dl.ubnt.com/firmwares/XW-fw/v5.6.6/XW.v5.6.6.29183.160526.1205.bin'
	URL='https://dl.ubnt.com/firmwares/XW-fw/v6.1.4/XW.v6.1.4.32113.180112.0918.bin'
fi
if [ "$versao" == "TI" ]; then
	URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.9/TI.v5.6.9.29546.160819.1135.bin'
fi

wget -c $URL -O /tmp/firmware.bin

if [ -e "/tmp/firmware.bin" ] ; then
        ubntbox fwupdate.real -m /tmp/firmware.bin
fi

