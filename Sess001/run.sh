#!/bin/bash

API_DIRECTORY=./api/dcloud-v2-api
UI_DIRECTORY=./ui/dcloud-v2-ui
EXPO_DIRECTORY=./expo/dcloud-v2-expo

function build_api {
  cd "$API_DIRECTORY"
  git add .
  git reset --hard
  git checkout $1
  git pull
  mvn -B clean package -DskipTests=true
  cd ../..
  docker-compose build api
}

function build_ui {
  cd "$UI_DIRECTORY"
  git add .
  git reset --hard
  git checkout $1
  git pull
  cd ../..
  docker-compose build ui
}

function build_expo {
  cd "$EXPO_DIRECTORY"
  git add .
  git reset --hard
  git checkout $1
  git pull
  cd ../..
  docker-compose build expo
}

read -p "API Branch [leave blank to skip]: " apib
apibranch=${apib:-none}

read -p "UI Branch [leave blank to skip]: " uib
uibranch=${uib:-none}

read -p "Expo Branch [leave blank to skip]: " expob
expobranch=${expob:-none}

read -p "Database [leave blank to skip]: " db
dbname=${db:-none}

read -p "Username [leave blank to skip]: " un
username=${un:-none}

# Set branches on first time through
if [ $apibranch = "none" ] && [ ! -d "$API_DIRECTORY" ]; then
  apibranch=dev 
fi

if [ $uibranch = "none" ] && [ ! -d "$UI_DIRECTORY" ]; then
  uibranch=dev 
fi

if [ $expobranch = "none" ] && [ ! -d "$EXPO_DIRECTORY" ]; then
  expobranch=dev 
fi

# Clone the dirs
if [ ! -d "$API_DIRECTORY" ] ; then
  git clone ssh://git@dcloud-bld-scm.cisco.com:7999/dcv2/dcloud-v2-api.git "$API_DIRECTORY"
fi

if [ ! -d "$UI_DIRECTORY" ] ; then
  git clone ssh://git@dcloud-bld-scm.cisco.com:7999/dcv2/dcloud-v2-ui.git "$UI_DIRECTORY"
fi

if [ ! -d "$EXPO_DIRECTORY" ] ; then
  git clone --recursive ssh://git@dcloud-bld-scm.cisco.com:7999/dcv2/dcloud-v2-expo.git "$EXPO_DIRECTORY"
fi

# Build the branches
if [ $apibranch != "none" ] || [ $username != "none" ]; then
  if [ $username != "none" ]; then
    sed -i'' -e "s/api.localhost.userid.*/api.localhost.userid = $username/g" ./api/api.properties
  fi
  build_api $apibranch
fi

if [ $uibranch != "none" ] ; then
  build_ui $uibranch
fi

if [ $expobranch != "none" ] ; then
  build_expo $expobranch
fi

# Get the database
if [[ $dbname != "none" && $dbname =~ ^(rtp|uk|chi|ap|sjc|idev)$ ]] ; then
  echo -n "Please Enter Database "
  ssh -o LogLevel=QUIET -A -t $dbname ssh -o LogLevel=QUIET -A -t root@10.1.23.13 "./dump.sh"
  echo "Copying dump to local machine via $dbname"
  ssh -o LogLevel=QUIET -A -t $dbname scp root@10.1.23.13:/root/nubi.gz .
  scp $dbname:~/nubi.gz .
  gunzip nubi.gz -f
  mv nubi ./db/nubi.sql
  echo "Database $dbname added"
fi

# Docker-compose time
docker-compose down
docker-compose up -d
