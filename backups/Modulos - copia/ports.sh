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

mine_port () {
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for porta in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$porta" | awk '{print $1}' | uniq)
    echo -e "\033[1;32mService: \033[1;31m$svcs \033[1;32mPort: \033[1;37m$porta"
done
}

port () {
local portas
local portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas}|grep -w "$var1 $var2")" ]] || {
    portas+="$var1 $var2 $portas"
    echo "$var1 $var2"
    let i++
    }
done <<< "$portas_var"
}

verify_port () {
local SERVICE="$1"
local PORTENTRY="$2"
[[ ! $(echo -e $(port|grep -v ${SERVICE})|grep -w "$PORTENTRY") ]] && return 0 || return 1
}

edit_squid () {
echo -e "\033[1;32mREDEFINIR PORTAS SQUID "
msg -bar
if [[ -e /etc/squid/squid.conf ]]; then
local CONF="/etc/squid/squid.conf"
elif [[ -e /etc/squid3/squid.conf ]]; then
local CONF="/etc/squid3/squid.conf"
fi
NEWCONF="$(cat ${CONF}|grep -v "http_port")"
echo -ne "Novas Portas: "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port squid "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
echo -e "$barra"
exit 1
}
done
rm ${CONF}
while read varline; do
echo -e "${varline}" >> ${CONF}
 if [[ "${varline}" = "#portas" ]]; then
  for NPT in $(echo ${newports}); do
  echo -e "http_port ${NPT}" >> ${CONF}
  done
 fi
done <<< "${NEWCONF}"
echo -e "\033[1;32mAGUARDE "
service squid restart &>/dev/null
service squid3 restart &>/dev/null
sleep 1s
echo -e "$barra"
echo -e "\033[1;32mPORTAS REDEFINIDAS "
echo -e "$barra"
}

edit_apache () {
echo -e "\033[1;32mREDEFINIR PORTAS APACHE "
echo -e "$barra"
local CONF="/etc/apache2/ports.conf"
local NEWCONF="$(cat ${CONF})"
echo -ne "Novas Porta: "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port apache "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
echo -e "$barra"
exit 1
}
done
rm ${CONF}
while read varline; do
if [[ $(echo ${varline}|grep -w "Listen") ]]; then
 if [[ -z ${END} ]]; then
 echo -e "Listen ${newports}" >> ${CONF}
 END="True"
 else
 echo -e "${varline}" >> ${CONF}
 fi
else
echo -e "${varline}" >> ${CONF}
fi
done <<< "${NEWCONF}"
echo -e "\033[1;32mAGUARDE "
service apache2 restart &>/dev/null
sleep 1s
echo -e "$barra"
echo -e "\033[1;32mPORTAS REDEFINIDAS "
echo -e "$barra"
}

edit_openvpn () {
echo -e "\033[1;32mREDEFINIR PORTAS OPENVPN "
echo -e "$barra"
local CONF="/etc/openvpn/server.conf"
local CONF2="/etc/openvpn/client-common.txt"
local NEWCONF="$(cat ${CONF}|grep -v [Pp]ort)"
local NEWCONF2="$(cat ${CONF2})"
echo -ne "Nova Porta: "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port openvpn "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
echo -e "$barra"
exit 1
}
done
rm ${CONF}
while read varline; do
echo -e "${varline}" >> ${CONF}
if [[ ${varline} = "proto tcp" ]]; then
echo -e "port ${newports}" >> ${CONF}
fi
done <<< "${NEWCONF}"
rm ${CONF2}
while read varline; do
if [[ $(echo ${varline}|grep -v "remote-random"|grep "remote") ]]; then
echo -e "$(echo ${varline}|cut -d' ' -f1,2) ${newports} $(echo ${varline}|cut -d' ' -f4)" >> ${CONF2}
else
echo -e "${varline}" >> ${CONF2}
fi
done <<< "${NEWCONF2}"
echo -e "\033[1;32mAGUARDE "
service openvpn restart &>/dev/null
/etc/init.d/openvpn restart &>/dev/null
sleep 1s
echo -e "$barra"
echo -e "\033[1;32mPORTAS REDEFINIDAS "
echo -e "$barra"
}

edit_dropbear () {
echo -e "\033[1;32mREDEFINIR PORTAS DROPBEAR "
echo -e "$barra"
local CONF="/etc/default/dropbear"
local NEWCONF="$(cat ${CONF}|grep -v "DROPBEAR_EXTRA_ARGS")"
echo -ne "Novas Portas: "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port dropbear "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
echo -e "$barra"
exit 1
}
done
rm ${CONF}
while read varline; do
echo -e "${varline}" >> ${CONF}
 if [[ ${varline} = "NO_START=0" ]]; then
 echo -e 'DROPBEAR_EXTRA_ARGS="VAR"' >> ${CONF}
 for NPT in $(echo ${newports}); do
 sed -i "s/VAR/-p ${NPT} VAR/g" ${CONF}
 done
 sed -i "s/VAR//g" ${CONF}
 fi
done <<< "${NEWCONF}"
echo -e "\033[1;32mAGUARDE "
service dropbear restart &>/dev/null
sleep 1s
echo -e "$barra"
echo -e "\033[1;32mPORTAS REDEFINIDAS "
echo -e "$barra"
}

edit_openssh () {
echo -e "\033[1;32mREDEFINIR PORTAS OPENSSH "
echo -e "$barra"
local CONF="/etc/ssh/sshd_config"
local NEWCONF="$(cat ${CONF}|grep -v [Pp]ort)"
echo -ne "Novas Portas: "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port sshd "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
echo -e "$barra"
exit 1
}
done
rm ${CONF}
for NPT in $(echo ${newports}); do
echo -e "Port ${NPT}" >> ${CONF}
done
while read varline; do
echo -e "${varline}" >> ${CONF}
done <<< "${NEWCONF}"
echo -e "\033[1;32mGUARDE"
service ssh restart &>/dev/null
service sshd restart &>/dev/null
sleep 1s
echo -e "$barra"
echo -e "\033[1;32mPORTAS REDEFINIDAS "
echo -e "$barra"
}

main_fun () {
echo -e "$barra"
echo -e "\033[1;32mSERVICOS E PORTAS ATIVAS "
echo -e "$barra"
mine_port
echo -e "$barra"
echo -ne "\033[1;32m [0] > " && echo -e "\033[1;33mVOLTAR"
unset newports
i=0
while read line; do
let i++
          case $line in
          squid|squid3)squid=$i;; 
          apache|apache2)apache=$i;; 
          openvpn)openvpn=$i;; 
          dropbear)dropbear=$i;; 
          sshd)ssh=$i;; 
          esac
done <<< "$(port|cut -d' ' -f1|sort -u)"
for((a=1; a<=$i; a++)); do
[[ $squid = $a ]] && echo -ne "\033[1;32m [$squid] > " && echo -e "\033[1;33mREDEFINIR PORTAS SQUID"
[[ $apache = $a ]] && echo -ne "\033[1;32m [$apache] > " && echo -e "\033[1;33mREDEFINIR PORTA APACHE"
[[ $openvpn = $a ]] && echo -ne "\033[1;32m [$openvpn] > " && echo -e "\033[1;33mREDEFINIR PORTA OPENVPN"
[[ $dropbear = $a ]] && echo -ne "\033[1;32m [$dropbear] > " && echo -e "\033[1;33mREDEFINIR PORTAS DROPBEAR"
[[ $ssh = $a ]] && echo -ne "\033[1;32m [$ssh] > " && echo -e "\033[1;33mREDEFINIR PORTAS SSH"
done
echo -e "$barra"
while true; do
echo -ne "\033[1;37mSelecione: " && read selection
tput cuu1 && tput dl1
[[ ! -z $squid ]] && [[ $squid = $selection ]] && edit_squid && break
[[ ! -z $apache ]] && [[ $apache = $selection ]] && edit_apache && break
[[ ! -z $openvpn ]] && [[ $openvpn = $selection ]] && edit_openvpn && break
[[ ! -z $dropbear ]] && [[ $dropbear = $selection ]] && edit_dropbear && break
[[ ! -z $ssh ]] && [[ $ssh = $selection ]] && edit_openssh && break
[[ "0" = $selection ]] && break
done
#exit 0
}
main_fun