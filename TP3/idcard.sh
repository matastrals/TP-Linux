#!/bin/bash
#Note a moi meme : utilise des variables comme ci dessous pour que se soit plus propre est ensuite tu les appelles. Tu as les exemples avec les 2 lignes qui suit celle la :)
machine_name="$(hostnamectl | head -n 1 | cut -d':' -f2)"
OS_name="$(cat /etc/os-release | head -n 1 | cut -d'"' -f2)"
OS_version="$(uname -r)"
My_IP="$(hostname -I | cut -d' ' -f2)"
Free_memory="$(free -mh | tr -s ' ' | grep "Mem:" | cut -d' ' -f4)"
Total_memory="$(free -mh | tr -s ' ' | grep "Mem:" | cut -d' ' -f2)"
Space_unuse="$(df -h | grep -F -w "/" | tr -s ' ' | cut -d' ' -f3)"

echo "Machine name :${machine_name}"
echo "OS ${OS_name} and kernel version is ${OS_version}"
echo "IP : ${My_IP}"
echo "RAM : ${Free_memory} memory avaiable on ${Total_memory} total memory"
echo "Disk : ${Space_unuse} space left"

ligne_ps=2
while [[ ${ligne_ps} -ne 7 ]]
do
  ps_nom="$(ps aux --sort=-%mem | tr -s ' ' | cut -d' ' -f11 | sed -n ${ligne_ps}p)"
  ps_ram="$(ps aux --sort=-%mem | tr -s ' ' | cut -d' ' -f4 | sed -n ${ligne_ps}p)"
  echo "  - $ps_nom (RAM utilisé : $ps_ram)"
  ligne_ps=$((ligne_ps + 1))
done
echo "Listening ports :"
while read ligne
do
  ss_port_num=$(echo ${ligne} | tr -s ' ' | cut -d' ' -f5 | cut -d':' -f2)
  ss_port_type=$(echo ${ligne} | tr -s ' ' | cut -d' ' -f1)
  ss_port_service=$(echo ${ligne} | tr -s ' ' | cut -d' ' -f7 | cut -d'"' -f2)
  echo "  - $ss_port_num $ss_port_type : $ss_port_service"
done <<< "$(sudo ss -lnp4H)"

cat_screen=$(curl -s https://cataas.com/cat > chat)
cat_file=$(file --extension chat | cut -d' ' -f2 | cut -d'/' -f1)
if [[ $cat_file == "jpeg" ]]
then
  cat_sour="cat.${cat_file}"
elif [[ $cat_file == "png" ]]
then
  cat_sour="cat.${cat_file}"
else
  cat_sour="cat.gif"
fi
mv chat ${cat_sour}
chmod +x ${cat_sour}
echo "Here is your random cat : ./${cat_sour}"

