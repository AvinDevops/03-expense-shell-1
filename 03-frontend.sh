#!/bin/bash

#creating user variables
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

#creating colors user variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#checking user is whether root or not
if [ $USERID -ne 0 ]
then
    echo "please access with root user"
    exit 1
else
    echo "you have root access"
fi

CHECKSTATUS(){
    if [ $1 -ne 0 ]
    then
        echo -e "$Y $2...is$N $R Failed $N"
        exit 1
    else
        echo -e "$Y $2...is$N $G Success $N"
    fi
}

#Main code
dnf install nginx -y &>>$LOGFILE
CHECKSTATUS $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
CHECKSTATUS $? "Enabiling nginx"

systemctl start nginx &>>$LOGFILE
CHECKSTATUS $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
CHECKSTATUS $? "Removing all files in html dir"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
CHECKSTATUS $? "Downlaoding frontend.zip in tmp"

cd /usr/share/nginx/html &>>$LOGFILE
CHECKSTATUS $? "changing to html dir"

unzip /tmp/frontend.zip &>>$LOGFILE
CHECKSTATUS $? "unzipping frontend.zip in html dir"

cp /home/ec2-user/02-expense-shell/expense.conf  /etc/nginx/default.d/expense.conf &>>$LOGFILE
CHECKSTATUS $? "copying expense.conf to etc dir "

systemctl restart nginx &>>$LOGFILE
CHECKSTATUS $? "Restarting nginx"