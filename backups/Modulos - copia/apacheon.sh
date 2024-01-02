#!/bin/bash
barra="\033[0;34m—————————————————————————————————————————————————————— \033[0m"
IP=$(cat /etc/IP)
x="ok"

fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "\033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}

fun_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
}

clear
echo -e "$barra"
echo -e "\033[1;32mGESTIONAR ARCHIVO EN LINEA"
echo -e "$barra"
echo -e "\033[1;32m [1] > \033[1;33mCOLOCAR ARCHIVO EN LINEA"
echo -e "\033[1;32m [2] > \033[1;33mELIMINAR ARCHIVO EN LINEA"
echo -e "\033[1;32m [3] > \033[1;33mVER ENLACES DE ARCHIVOS EN LINEA"
echo -e "\033[1;32m [0] > \033[1;33mVOLVER AL MENU"
echo -e "$barra"
while [[ ${arquivoonlineadm} != @([0-3]) ]]; do
read -p "[0-3]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case ${arquivoonlineadm} in
0)
exit
;;
3)
[[ -z $(ls /var/www/html) ]] && echo -e "$barra"  || {
    for my_arqs in `ls /var/www/html`; do
    [[ "$my_arqs" = "index.html" ]] && continue
    [[ "$my_arqs" = "index.php" ]] && continue
    [[ -d "$my_arqs" ]] && continue
    echo -e "\033[1;31m[$my_arqs] \033[1;36mhttp://$IP:81/$my_arqs\033[0m"
    done
    echo -e "$barra"
    }
echo -ne "\n\033[1;31mENTER \033[1;33mpara volver al \033[1;32mMENU!\033[0m"; read
apacheon.sh
;;
2)
i=1
[[ -z $(ls /var/www/html) ]] && echo -e "$barra"  || {
    for my_arqs in `ls /var/www/html`; do
    [[ "$my_arqs" = "index.html" ]] && continue
    [[ "$my_arqs" = "index.php" ]] && continue
    [[ -d "$my_arqs" ]] && continue
    select_arc[$i]="$my_arqs"
    echo -e "\033[1;31m[$i] > \033[1;33m$my_arqs - \033[1;36mhttp://$IP:81/$my_arqs\033[0m"
    let i++
    done
    echo -e "$barra"
    echo -e "\033[1;32mSeleccione el archivo a eliminar"
    echo -e "$barra"
    while [[ -z ${select_arc[$slct]} ]]; do
    read -p " [1-$i]: " slct
    tput cuu1 && tput dl1
    done
    arquivo_move="${select_arc[$slct]}"
    [[ -d /var/www/html ]] && [[ -e /var/www/html/$arquivo_move ]] && rm -rf /var/www/html/$arquivo_move > /dev/null 2>&1
    [[ -e /var/www/$arquivo_move ]] && rm -rf /var/www/$arquivo_move > /dev/null 2>&1
    echo -e "\033[1;32mARCHIVO ELIMINADO!"
    echo -e "$barra"
    }
echo -ne "\n\033[1;31mENTER \033[1;33mpara volver al \033[1;32mMENU!\033[0m"; read
apacheon.sh
;;    
1)
i="1"
[[ -z $(ls $HOME) ]] && echo -e "$barra"  || {
    for my_arqs in `ls $HOME`; do
    [[ -d "$my_arqs" ]] && continue
    select_arc[$i]="$my_arqs"
    echo -e "\033[1;31m [$i] > \033[1;33m$my_arqs"
    let i++
    done
    i=$(($i - 1))
    echo -e "$barra"
    echo -e "\033[1;32mSeleccione el archivo"
    echo -e "$barra"
    while [[ -z ${select_arc[$slct]} ]]; do
    read -p " [1-$i]: " slct
    tput cuu1 && tput dl1
    done
    arquivo_move="${select_arc[$slct]}"
    [ ! -d /var ] && mkdir /var
    [ ! -d /var/www ] && mkdir /var/www
    [ ! -d /var/www/html ] && mkdir /var/www/html
    [ ! -e /var/www/html/index.html ] && touch /var/www/html/index.html
    [ ! -e /var/www/index.html ] && touch /var/www/index.html
    chmod -R 755 /var/www
    cp $HOME/$arquivo_move /var/www/$arquivo_move
    cp $HOME/$arquivo_move /var/www/html/$arquivo_move
    echo -e "\033[1;36m http://$IP:81/$arquivo_move\033[0m"
    echo -e "$barra"
    echo -e "\033[1;32mARCHIVO ELIMINADO!"
    echo -e "$barra"
    }
echo -ne "\n\033[1;31mENTER \033[1;33mpara volver al \033[1;32mMENU!\033[0m"; read
apacheon.sh
;;
esac
