#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
    echo: -e "$R ERROR:Please run the script with root access $N"
    exit 1
else
    echo: "Your running with root Access"
fi