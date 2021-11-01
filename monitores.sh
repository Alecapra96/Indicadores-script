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
sudo mv ~/indicadores-script/.xinitrc ~/.xinitrc



echo "Instalo programas base" 
sudo apt -y install  rdesktop slim rxvt-unicode

echo "Remuevo cosas que ocupan espacio"
sudo apt -y remove snapd
sudo apt -y purge snapd 


echo "Instalo google chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb

echo "Hago el autologin"
sudo rm /etc/slim.conf
sudo cp ~/indicadores-script/slim.conf /etc/

echo "Dependencias para unir al dominio"
sudo apt -y install sssd-ad sssd-tools realmd adcli sed 
sudo apt-get -y install realmd packagekit


echo "Preparando para unir al dominio"
wait 5000
nombreEquipo=hostname
sudo sed -i "1s+.*+${nombreEquipo}.lavoz.local+g" /etc/hostname
sudo sed -i "2s+.*+127.0.1.1       ${nombreEquipo}.lavoz.local+g" /etc/hosts
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

echo "Haciendo ajustes finales..."
wait 2000
echo "Script ejectuado.."
echo "Echo por alejandro Capra."

