#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
N="\e[0m"

if [ $USERID -ne 0 ]
then 
    echo "Please run this Script with root access"
    exit 1
else
    echo "You are a Super User"    
fi

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo -e "$2 is: $R Failed $N"
    exit 1
else
    echo -e "$2 is : $G Success $N"
fi

}

dnf install mysql-server -y &>>LOGFILE
VALIDATE $? "Installing Mysql-server"

systemctl enable mysqld &>>LOGFILE
VALIDATE $? "Enabling Mysql-server"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "Starting Mysql-server"


#mysql_secure_installation --set-root-pass ExpenseApp@1
#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"


#Below code will be useful for idempotent nature

mysql -h db.iamzaheer.online -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
     mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
     VALIDATE $? "Mysql Root Password Setup"
else
    echo -e "Mysql Root Password is already setup...$C SKIP $N"
fi
