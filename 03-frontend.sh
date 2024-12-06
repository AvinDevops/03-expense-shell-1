#!/bin/bash

source ./00-common.sh

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