#!/bin/bash

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
CHECKSTATUS(){
    if [ $1 -ne 0 ]
    then
        echo -e "$Y $2 $N...is $R Failed $N"
        exit 1
    else
        echo -e "$Y $2 $N...is $G Success $N"
    fi
}

#checking whether user is root or not
if [ $USERID -ne 0 ]
then
    echo "Please access with root user access"
    exit 1
else
    echo "you have root access, please proceed"
fi

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

cp /home/ec2-user/02-expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
CHECKSTATUS $? "copying backend.service to etc dir"

systemctl daemon-reload &>>$LOGFILE
CHECKSTATUS $? "Starting Daemon reloading"

systemctl start backend &>>$LOGFILE
CHECKSTATUS $? "Starting backend service"

systemctl enable backend &>>$LOGFILE
CHECKSTATUS $? "Enabiling backend service"

dnf install mysql -y &>>$LOGFILE
CHECKSTATUS $? "Installing mysql client"

mysql -h db.avinexpense.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE
CHECKSTATUS $? "Loading backend.sql schema"

systemctl restart backend &>>$LOGFILE
CHECKSTATUS $? "Restarting backend service"