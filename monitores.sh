#!/bin/sh
echo "Bienvenidos al script para crear los monitores"
echo "_______________________________________________"
echo "Cargando..."
wait 2000
echo "Iniciando"
echo "Actualizo el sistema"
sudo apt -y install && sudo apt -y upgrade
echo $?

echo "Instalo dependencias bases"
sudo apt -y install --no-install-suggests --no-install-recommends xserver-xorg-core software-properties-common broadcom-sta-dkms cmake libfreetype6-dev libfontconfig1-dev xclip build-essential libx11-dev libxft-dev xterm build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev 
echo "Instalo BSPWM"
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git
cd bspwm/
make
sudo make install
cd ../sxhkd/
make
sudo make install
sudo apt -y install bspwm
echo "Creo Los archivos de configuracion"
mkdir ~/.config
mkdir ~/.config/bspwm
mkdir ~/.config/sxhkd
cd ../bspwm/
cp examples/bspwmrc ~/.config/bspwm/
chmod +x ~/.config/bspwm/bspwmrc
cp examples/sxhkdrc ~/.config/sxhkd/

echo "Instalo el script de startx"
sudo apt -y install xinit
echo "Creo el archivo .xinitrc"
#evitar correr procesos con .xinit, hacerlos servicios
#LANZAR GOOGLE CHROME COMO SERVICIO
#LANZAR VNC COMO SERVICIO
mv ~/indicadores-script/.xinitrc ~/.xinitrc



echo "Instalo programas base" 
sudo apt -y install  rdesktop rxvt-unicode

echo "Remuevo cosas que ocupan espacio"
sudo apt -y remove snapd
sudo apt -y purge snapd 

echo "Hago el autologin"
cp ~/indicadores-script/kiosk.sh /opt/ 
sudo chmod +x /opt/kiosk.sh
sudo cp ~/indicadores-script/kiosk.service /etc/systemd/system/
sudo rm /etc/X11/Xwrapper.conf
cp ~/indicadores-script/Xwrapper.conf /etc/X11/
sudo systemctl enable kiosk
sleep 2

echo "Instalo google chrome"
sudo apt -y install ./google-chrome-stable_current_amd64.deb

echo "Creo el servicio google chrome"
cp ~/indicadores-script/chrome.sh /opt/
sudo cp ~/indicadores-script/chrome.service /etc/systemd/system/
sudo chmod +x /opt/chrome.sh
sudo systemctl enable chrome


echo "Instalo ocs"
wget http://old.kali.org/kali/pool/main/o/ocsinventory-agent/ocsinventory-agent_2.4.2-1_i386.deb
sudo dpkg -i ocsinventory-agent_2.4.2-1_i386.deb
sudo apt -y install --fix-broken
sudo cp ~/indicadores-script/ocsinventory-agent.cfg /etc/ocsinventory-agent/
sudo ocsinventory-agent -f

echo "Instalo VNC"
sudo apt -y install x11vnc
sudo x11vnc -storepasswd h4ck3rs /opt/x11vnc.passwd
#Hacer que inicie vnc como servicio, por ahora esta iniciando en xinit
sudo sed -i "8s+.*+ExecStart=/usr/bin/x11vnc -auth /home/${HOSTNAME}/.Xauthority -display WAIT:0 -forever -rfbauth /opt/x11vnc.passwd -rfbport 5900+g" ~/indicadores-script/x11vnc.service
sudo cp ~/indicadores-script/x11vnc.service /etc/systemd/system/
sudo systemctl enable x11vnc




echo "Escriba 1 para si desea cambiarle el nombre al equipo"
read "textoNombre"
if [ "$textoNombre" = "1" ]; then
read -p "Ingrese el nombre del equipo: " nombreEquipoo
sudo hostnamectl set-hostname $nombreEquipoo
fi

echo "Escriba 1 para unir la maquina al dominio, escriba 2 para terminar el script."
read "texto"
if [ "$texto" = "1" ]; then
echo "Dependencias para unir al dominio"
sudo apt -y install sssd-ad sssd-tools realmd adcli sed 
sudo apt-get -y install realmd packagekit

echo "inicio los servicios creados"
sudo systemctl start kiosk

sudo systemctl start x11vnc
sudo systemctl start firefox

echo "Preparando para unir al dominio"
wait 5000
nombreEquipo=hostname
sudo sed -i "1s+.*+${HOSTNAME}.lavoz.local+g" /etc/hostname
sudo sed -i "2s+.*+127.0.1.1       ${HOSTNAME}.lavoz.local+g" /etc/hosts
sudo rm /etc/systemd/timesyncd.conf
sudo rm /etc/systemd/resolved.conf

sudo echo -e "[Resolve] \nDomains=lavoz.local">> ~/resolved.conf
sudo echo -e "[Time] \nNTP=VSRV-DC01.lavoz.local \nFallbackNTP=VSRV-DC02.lavoz.local \n#RootDistanceMaxSec=5 \n#PoolIntervalMinSec=32 \n#PoolIntervalMaxSec=2048">> ~/timesyncd.conf
sudo mv ~/resolved.conf /etc/systemd/resolved.conf
sudo mv  ~/timesyncd.conf /etc/systemd/timesyncd.conf
sudo realm discover lavoz.local
sleep 5
read -p "Ingrese el usuario del dominio: " usuarioAD
sudo realm join -U ${usuarioAD} lavoz.local
sudo realm permit -vR lavoz.local -g gs-soporte@lavoz.local

echo "Haciendo ajustes finales..."
wait 2000
echo "Script ejectuado.."
echo "Echo por alejandro Capra."
sleep 1
echo "Reiniciando."
sleep 1
echo "Reiniciando.."
sleep 1
echo "Reiniciando..."
sleep 1
echo "Reiniciando...."
sudo reboot

else
echo "Haciendo ajustes finales..."
wait 2000
echo "Script ejectuado.."
echo "Echo por alejandro Capra."
sleep 1
echo "Reiniciando."
sleep 1
echo "Reiniciando.."
sleep 1
echo "Reiniciando..."
sleep 1
echo "Reiniciando...."

sudo reboot
fi


