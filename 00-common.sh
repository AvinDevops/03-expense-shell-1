#!/bin/bash

set -e

#creating/declaring user variables
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

#creating colors user variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating CHECKSTATUS function
#CHECKSTATUS(){
#    if [ $1 -ne 0 ]
#    then
#       echo -e "$Y $2 $N...is $R Failed $N"
#        exit 1
#    else
#        echo -e "$Y $2 $N...is $G Success $N"
#    fi
#}

#checking whether user is root or not
if [ $USERID -ne 0 ]
then
    echo "Please access with root user access"
    exit 1
else
    echo "you have root access, please proceed"
fi