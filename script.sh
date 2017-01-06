#!binsh
# Alexandre Jeronimo Correa - ajcorrea@gmail.com
# Script para AirOS Ubiquiti
# Remove o worm MF e atualiza para a ultima versao do AirOS disponivel oficial
#
##### NAO ALTERAR ####
binsed -ir 'mcad c ' etcinittab
binsed -ir 'mcuser c ' etcpasswd
binrm -rf etcpersistenthttps
binrm -rf etcpersistentmcuser
binrm -rf etcpersistentmf.tar
binrm -rf etcpersistent.mf
binrm -rf etcpersistentrc.poststart
binrm -rf etcpersistentrc.prestart
binkill -HUP `binpidof init`
binkill -9 `binpidof mcad`
binkill -9 `binpidof init`
binkill -9 `binpidof search`
binkill -9 `binpidof mother`
binkill -9 `binpidof sleep`
# ALTERACOES DE PORTAS - Diego Canton
cat tmpsystem.cfg  grep -v http  tmpsystem2.cfg
echo httpd.https.status=disabled  tmpsystem2.cfg
echo httpd.port=81  tmpsystem2.cfg
echo httpd.session.timeout=900  tmpsystem2.cfg
echo httpd.status=enabled  tmpsystem2.cfg
cat tmpsystem2.cfg  uniq  tmpsystem.cfg
rm tmpsystem2.cfg

#ativa Compliance TEST
touch etcpersistentct

bincfgmtd -w -p etc

fullver=`cat etcversion`
if [ $fullver == XM.v6.0 ]; then
        echo Atualizado... Done
        exit
fi
if [ $fullver == XW.v6.0 ]; then
        echo Atualizado... Done
        exit
fi

versao=`cat etcversion  cut -d'.' -f1`
cd tmp
rm -rf tmpX.bin
if [ $versao == XM ]; then
        #URL='http189.125.44.254ubntXM.v5.6.5.29033.160515.2119.bin'
	#URL='http189.125.44.254ubntXM.v5.6.6.29183.160526.1225.bin'
        URL='httpdl.ubnt.comfirmwaresXN-fwv6.0XM.v6.0.30097.161219.1716.bin'
        wget -c $URL
        ubntbox fwupdate.real -m tmpXM.v6.0.30097.161219.1716.bin
	
else
        #URL='http189.125.44.254ubntXW.v5.6.5.29033.160515.2108.bin'
        #URL='http189.125.44.254ubntXW.v5.6.6.29183.160526.1205.bin'
	URL='httpdl.ubnt.comfirmwaresXW-fwv6.0XW.v6.0.30097.161219.1705.bin'
        wget -c $URL
        ubntbox fwupdate.real -m tmpXW.v6.0.30097.161219.1705.bin
	
fi