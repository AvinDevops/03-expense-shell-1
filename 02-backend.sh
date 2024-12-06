#!/bin/bash

source ./00-common.sh

echo "please enter root password"
read root_password

#Main code
dnf module disable nodejs:18 -y &>>$LOGFILE


dnf module enable nodejs:20 -y &>>$LOGFILE


dnf install nodejs -y &>>$LOGFILE


id expense &>>$LOGFILE 
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    
else
    echo -e "$Y expense user is$N $G already created $N"
fi

mkdir -p /app &>>$LOGFILE


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE


cd /app

rm -rf /app/*

unzip /tmp/backend.zip &>>$LOGFILE


npm install &>>$LOGFILE


cp /home/ec2-user/03-expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE


systemctl daemon-reload &>>$LOGFILE


systemctl start backend &>>$LOGFILE


systemctl enable backend &>>$LOGFILE


dnf install mysql -y &>>$LOGFILE


mysql -h db.avinexpense.online -uroot -p${root_password} < /app/schema/backend.sql &>>$LOGFILE


systemctl restart backend &>>$LOGFILE
