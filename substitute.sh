#!/bin/bash

if [ $# -ne 2 ]
then
  echo "usage: substitute.sh username password"
  exit 1
fi

function change_bashrc_credentials {
  ssh $1 "rm -f ~/.bashrc.tmp"
  ssh $1 "cat ~/.bashrc | sed '/export http/d' > ~/.bashrc.tmp"
  ssh $1 "echo export http_proxy=http://$2:$3@172.25.66.1:8080 >> ~/.bashrc.tmp"
  ssh $1 "echo export https_proxy=http://$2:$3@172.25.66.1:8080 >> ~/.bashrc.tmp"
  ssh $1 "mv ~/.bashrc.tmp ~/.bashrc"
  echo bashrc credentials changed for $1
}

function change_zshrc_credentials {
  ssh $1 "rm -f ~/.zshrc.tmp"
  ssh $1 "cat ~/.zshrc | sed '/export http/d' > ~/.zshrc.tmp"
  ssh $1 "echo export http_proxy=http://$2:$3@172.25.66.1:8080 >> ~/.zshrc.tmp"
  ssh $1 "echo export https_proxy=http://$2:$3@172.25.66.1:8080 >> ~/.zshrc.tmp"
  ssh $1 "mv ~/.zshrc.tmp ~/.zshrc"
  echo zshrc credentials changed for $1
}

function change_curlrc_credentials {
  ssh $1 "rm -f ~/.curlrc.tmp"
  ssh $1 "cat ~/.curlrc | sed '/proxy/d' > ~/.curlrc.tmp"
  ssh $1 "echo proxy = $2:$3@172.25.66.1:8080 >> ~/.curlrc.tmp"
  ssh $1 "rm ~/.curlrc.tmp"
  echo curlrc credentials changed for $1
}

function change_apt_credentials {
  ssh $1 "rm -f ~/00aptitude.tmp"
  ssh $1 "cat /etc/apt/apt.conf.d/00aptitude | sed '/Proxy/d' >  ~/00aptitude.tmp"
  ssh $1 "echo 'Acquire::http::Proxy \"http://$2:$3@172.25.66.1:8080\";' >> ~/00aptitude.tmp"
  ssh root@$1 "mv /home/dev/00aptitude.tmp /etc/apt/apt.conf.d/00aptitude"
  echo apt credentials changed for $1
}

servers=`cat servers.list | cut -d" " -f1`

for server in $servers 
do
  change_bashrc_credentials $server $1 $2
  change_zshrc_credentials $server $1 $2
  change_curlrc_credentials $server $1 $2
  change_apt_credentials $server $1 $2
done

