#!/bin/bash
# By crazy_vpn
# Pequeno script para permissao de autenticacao root
# Aplicar permissoes de usuario root aos sistemas
# Oracle, Aws, Azure, Google, Amazon e etc
clear
[[ "$(whoami)" != "root" ]] && {
	clear
	echo -e "\033[1;31mEJECUTE COMO USUARIO ROOT, \033[1;32m(\033[1;33msudo -i\033[1;32m)\033[0m"
	exit
}
echo -e "\n\033[1;32mPERMISOS DE AUTENTIFICACION ROOT... \033[0m"
[[ $(grep -c "prohibit-password" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/prohibit-password/yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "without-password" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/without-password/yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "#PermitRootLogin" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "PasswordAuthentication" /etc/ssh/sshd_config) = '0' ]] && {
	echo 'PasswordAuthentication yes' > /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "#PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
} > /dev/null
service ssh restart > /dev/null
iptables -F
iptables -A INPUT -p tcp --dport 81 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 8799 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 1194 -j ACCEPT
sleep 3
echo -e "\n\033[1;31m[ \033[1;33mOK ! \033[1;31m]\033[1;37m - \033[1;32mPERMISOS APLICADOS ! \033[0m"
echo ""
echo -ne "\033[1;32mESCOJA UNA NUEVA CONTRASEÑA ROOT\033[1;37m: "; read senha
[[ -z "$senha" ]] && {
echo -e "\n\033[1;31mCONTRASEÑA INVALIDA !\033[0m"
exit 0
}
echo "root:$senha" | chpasswd
echo -e "\n\033[1;31m[ \033[1;33mOK ! \033[1;31m]\033[1;37m - \033[1;32mNUEVA CONTRASEÑA DEFINIDA ! \033[0m"
