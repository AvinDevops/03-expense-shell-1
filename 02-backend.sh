#!/bin/bash

source ./00-common.sh

echo "please enter root password"
read root_password

#Main code
dnf module disable nodejs:18 -y &>>$LOGFILE
CHECKSTATUS $? "Disabiling nodejs 18 version"

dnf module enable nodejs:20 -y &>>$LOGFILE
CHECKSTATUS $? "Enabiling nodejs 20 version"

dnf install nodejs -y &>>$LOGFILE
CHECKSTATUS $? "Installing nodejs"

id expense &>>$LOGFILE 
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    CHECKSTATUS $? "creating expense user"
else
    echo -e "$Y expense user is$N $G already created $N"
fi

mkdir -p /app &>>$LOGFILE
CHECKSTATUS $? "creating app dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
CHECKSTATUS $? "Downloading file in tmp"

cd /app

rm -rf /app/*

unzip /tmp/backend.zip &>>$LOGFILE
CHECKSTATUS $? "unzipping backend.zip"

npm install &>>$LOGFILE
CHECKSTATUS $? "Installing dependencies"

cp /home/ec2-user/03-expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
CHECKSTATUS $? "copying backend.service to etc dir"

systemctl daemon-reload &>>$LOGFILE
CHECKSTATUS $? "Starting Daemon reloading"

systemctl start backend &>>$LOGFILE
CHECKSTATUS $? "Starting backend service"

systemctl enable backend &>>$LOGFILE
CHECKSTATUS $? "Enabiling backend service"

dnf install mysql -y &>>$LOGFILE
CHECKSTATUS $? "Installing mysql client"

mysql -h db.avinexpense.online -uroot -p${root_password} < /app/schema/backend.sql &>>$LOGFILE
CHECKSTATUS $? "Loading backend.sql schema"

systemctl restart backend &>>$LOGFILE
CHECKSTATUS $? "Restarting backend service"