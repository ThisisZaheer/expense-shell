#!/bin/bash

SCRIPT_NAME=$(echo $0 | cut -d . -f1)
TIMESTAMP=$(date +%F-%H-%M-%S)
USERID=$(id -u)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

echo "Please enter DB Password"
read -s PASSWORD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
   echo -e "$R Please run this script as root access$N"
   exit 1
else 
   echo -e "$G You are a Super-User$N"
fi

VALIDATE(){
     if [ $1 -ne 0 ]
     then 
       echo -e "$2 is $R Failed$N"
       exit 1
    else
       echo -e "$2 is $G Success$N"
    fi
}

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the Frontend Code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting the frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied Expense Configuration"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting Nginx"