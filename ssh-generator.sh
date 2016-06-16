#!/usr/bin/env bash

files=($HOME/.ssh/*.pub);

addSSH () {
   eval "$(ssh-agent -s)";

   local private=${1%.*}; # Get Private Key
   ssh-add $private;

   pbcopy < $1;
   echo;
   echo '=============================================================';
   echo "   Key copied into the clipboard, opening github settings.";
   echo '=============================================================';
   sleep 2;
   open https://github.com/settings/keys;
}

createSSH () {
   if [ $(git config user.email) ];
   then
      email=$(git config user.email);
   else
      read -p "Provide an email address for ssh-keygen: " email
   fi;

   ssh-keygen -t rsa -b 4096 -C $email
   local filename=$(ls -Art $HOME/.ssh/*\.pub | tail -n 1 | xargs basename);

   addSSH $filename
}

chooseFilePrompt () {
   while true; do
      read -n1 -p "Choose the file you want to use? " index
      echo;
      if [[ $index =~ ^[0-9] ]];
      then
         # Public Key
         public=${files[$index]}
         addSSH $public
         exit
      fi;
   done;
}

newOrExistingPropt () {
   while true; do
      read -n1 -p "Do you want to use an existing file?(y/n) " yn
      echo;
      case $yn in
         [Yy]* )
            listAvailableSSHFiles
            chooseFilePrompt
         ;;
         [Nn]* )
            createSSH
            exit
         ;;
         * ) echo "Please answer yes or no.";;
      esac
   done
}

listAvailableSSHFiles () {
   let count=0;
   for file in "${files[@]}"; do
      echo "[$count] $(basename $file)"
      let count=$count+1;
   done;
   echo;
}


if [[ $(ls -A ${files[@]} 2> /dev/null) ]];
then
   newOrExistingPropt
else
   createSSH
fi;
