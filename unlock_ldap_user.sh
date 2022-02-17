#!/bin/bash


echo -ne "Введите DN в формате "dc=xxx,dc=yyy"\n"
read ldap


choice_of ()
{
select BUSER
do
  echo
  echo "Вы выбрали $BUSER"
  break
done
}

ou=$(cat /etc/sysconfig/network | grep HOSTNAME | awk -F "=" '{ print $2 }'| awk -F "-" '{ print $1 }' | sed 's/[[:lower:]]/\u&/g')

for USERS in $(ls /home | grep -Ev 'admin|audit|lost') ; do 

#        ldapsearch -x -b 'dc=test,dc=local' -D 'cn=Manager,dc=test,dc=local' -w12345678 uid=$USERS + | grep pwdAccountLockedTime > /dev/null
        ldapsearch -x -b '$ldap' -D 'cn=Manager,$ldap' -w12345678 uid=$USERS + | grep pwdAccountLockedTime > /dev/null

         if [ $? == 0 ] 
        then
echo "*******************************"
echo "Заблокированные пользователи"
PS3="Введите номер, согласно списка: " 
choice_of $USERS

touch /tmp/unlock.ldiff

echo "dn: uid=$USERS,ou=People,ou=$ou,$ldap" > /tmp/unlock.ldiff
echo "changetype: modify" >> /tmp/unlock.ldiff
echo "delete: pwdAccountLockedTime" >> /tmp/unlock.ldiff
echo "-" >> /tmp/unlock.ldiff

ldapmodify -D 'cn=Manager,$ldap' -w12345678 -f /tmp/unlock.ldiff > /dev/null
echo
echo "Успешно разблокирован пользователь $USERS"

        fi


done
