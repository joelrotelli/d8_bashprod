#!/usr/bin/env bash
branch="develop"
server=YOUR_SSH_ALIAS
distant_path=YOUR_WEBSITE_DISTANT_PATH
drush_alias=YOUR_DRUSH_ALIAS


git status
echo -e "\r\nVoulez-vous \033[104mcommiter\033[0m avant de publier ? (y/n)"
 read answer
 if [[ $answer =~ ^[Yy]$ ]]
 then
  echo -e "Message de commit :"
  read answer
  git add -u ; git add .;  git commit -m "$answer";
 fi

  echo " "
  echo -e "\033[104mVérifier\033[0m les changement de configuration ? (y/n) "
  read answer
  if [[ $answer =~ ^[Yy]$ ]]
  then
    echo " "
    echo "Vérification des changement de configuration.................."
    drush $drush_alias cex -n

    echo " "
    echo -e "\033[104mExporter et importer\033[0m la configuration ? (y/n) "
    read answer
    if [[ $answer =~ ^[Yy]$ ]]
    then
      echo "Exporting configuration.................."
     drush $drush_alias cexy -y --ignore-list=~/.drush/config-ignore.yml --skip-modules=update,devel,kint,dblog,stage_file_proxy --destination=$config_destination
     git status
     git diff
     echo " "
     echo -e "\033[104mCommiter\033[0m cet export de configuration ? (y/n) "
      read answer
      if [[ $answer =~ ^[Yy]$ ]]
      then
        git add .; git add -u; git commit -m "Export configuration"
      fi
    fi
  fi


echo -e "Confirmer la publication sur la branche \033[31;1;5;7m$branch\033[0m sur \033[31;1;5;7m$server\033[0m:$distant_path ? (y/n) "
 read answer
 if [[ $answer =~ ^[Yy]$ ]]
 then
  echo "Pushing to $branch "
  git push origin $branch
  echo "Connecting to ssh $server........"
  echo "Pulling from $branch.........."
  ssh $server "cd $distantPath; git checkout $branch; git pull origin $branch; drush cim -y ; drush cr; exit"



fi
echo "Exit"
