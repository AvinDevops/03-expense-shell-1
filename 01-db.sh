#!/bin/bash

source ./00-common.sh

echo "please enter DB password :"
read mysql-root-password

#Main code
dnf install mysql-server -y &>>$LOGFILE
CHECKSTATUS $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGFILE
CHECKSTATUS $? "Enabling mysql-server"

systemctl start mysqld &>>$LOGFILE
CHECKSTATUS $? "Starting mysql-server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
mysql -h db.avinexpense.online -uroot -p${mysql-root-password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql-root-password} &>>$LOGFILE
    CHECKSTATUS $? "Setting root password for mysql-server"
else
    echo -e "$R Root password is already set $N"
fi