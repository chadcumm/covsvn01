#!/usr/bin/ksh
#
###########################################
#     Author: 		Mike Layman           #
#     Date Written: 05/16/18              #
#     Purpose: 		This script will      #
#	  copy a data file from a Cerner      #
#	  directory, archive a copy, and      #
#	  create a log entry and ftp the file.# 
###########################################



#HNAM env setup
# only needed if calling the ccl from the shell script
./cerner/mgr/p19_environment.ksh
ccl>>!
kmt_sch_census_ict2 "mine" go
!>>
fname='ls companya_ivr*'

log="$cer_data/data/ftplogs/ictlog"
backupdir="$cer_data/data/ict"
user=$1
pwd=$2
server=$3

if [[-f fname]]
then
	echo "File exists. CCL executed without errors.">>$log
	cp -p $fname $backupdir /$fname
	if [$?=0]
		then
		echo "File successfully backed up.">>$log

#set up ftp
			$FTPFILE="ftp.$$"
			echo "open $server">$FTPFILE
			echo "user $user $pwd">>$FTPFILE
			echo "ascii">>$FTPFILE
			echo "passive">>$FTPFILE
			echo "put $fname">>$FTPFILE
			echo "quit">>$FTPFILE
			
			ftp -n<$FTPFILE
			rm $FTPFILE
			
	else
		echo "An error occurred with copying the file.">>$log
		
	fi
fi

	if [[$?=0]]
		then echo "File successfully transferred to foreign system.">>$log
		else
		echo "An error occurred with the file transfer.">>$log
	fi
rm $fname

