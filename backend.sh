#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d . -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
N="\e[0m"

echo "Please enter DB password:"
read mysql_root_password

if [ $USERID -ne 0 ]
then
   echo "Please run this Script as root access"
   exit 1
else
   echo "You are a Super User"
fi

VALIDATE(){
if [ $1 -ne 0 ]
then 
   echo -e "$2 is $R Failed $N"
   exit 1
else
   echo -e "$2 is $G Success $N"
fi
}

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created.. $C SKIP $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating App Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copied backend-service"

systemctl daemon-reload
VALIDATE $? "Daemon-reload"

systemctl start backend
VALIDATE $? "Starting Backend"

systemctl enable backend
VALIDATE $? "Enabling Backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing Mysql Client"

mysql -h db.iamzaheer.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"
