#!/usr/bin/env bash
branch_prod="master"
branch_develop="develop"
server=YOUR_SSH_ALIAS
distant_path=YOUR_WEBSITE_DISTANT_PATH
drush_alias=YOUR_DRUSH_ALIAS
config_destination=YOUR_CONFIG_FOLDER_DESTINATION


echo -e "\e[36m ";

gitStatus=$(git status)

if echo "$gitStatus" |grep "rien à valider" >/dev/null 2>&1
then
  echo "Rien à commiter";
  echo -e "\033[0m";
else
  git status

  echo -e "\033[0m";
  echo -e "\r\nVoulez-vous \033[104mcommiter vos développements\033[0m avant de publier ? (y/n)"
   read answer
   if [[ $answer =~ ^[Yy]$ ]]
   then
    echo -e "Message de commit :"
    read answer
    git add -u ; git add .;  git commit -m "$answer";
   fi
fi

  echo " "
  echo "Vérification des changement de configuration.................."
  drush $alias cex -n

  echo " "
  echo -e "\033[104mExporter et importer\033[0m la configuration ? (y/n) "
  read answer
  if [[ $answer =~ ^[Yy]$ ]]
  then
    echo "Exporting configuration.................."
   drush $alias cexy -y --ignore-list=~/.drush/config-ignore.yml --skip-modules=devel,kint,dblog --destination=$config_destination
   git status
   echo " "
   echo -e "\033[104mCommiter\033[0m cet export de configuration ? (y/n) "
    read answer
    if [[ $answer =~ ^[Yy]$ ]]
    then
      git add .; git add -u; git commit -m "Export configuration"
    fi
  fi

echo " "
echo -e "Confirmer le déploiement \033[31;1;5;7mEN PRODUCTION\033[0m sur la branche \033[31;1;5;7m$branch_prod\033[0m sur le serveur $server ? (y/n) "
read answer
if [[ $answer =~ ^[Yy]$ ]]
then




  git push origin $branch_develop
  echo "Merge $branch_develop info $branch_prod"
  git checkout $branch_prod
  git merge $branch_develop

  echo "Pushing to $branch_prod "
  git push origin $branch_prod
  echo "Connecting to ssh $server.................."
  echo "Pulling from $branch_prod..................."

  ssh $server << EOF

git pull origin $branch_prod

drush cim -y

drush cr

exit

EOF

  echo "Back to $branch_develop branch......"
  git checkout $branch_develop

fi
echo "Exit"
