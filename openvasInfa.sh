#!/bin/bash

# Author : Kunal Pachauri
# Script follows here:


#Openvas Credentials
openvas_username="admin"
openvas_password="admin"

if [ "$#" -ne 4 ]; then
    echo "Usage: ./openvasInfa.sh <IP> <SSH_USERNAME> <SSH_PASSWORD> <SCAN_NAME>"
    exit	
fi

#Initialising Required Parameters
ip=$1
ssh_username=$2
ssh_password=$3
scan_name=$4


# Step1: Create Credentials
credentialID=`omp -u $openvas_username -w $openvas_password -iX "<CREATE_CREDENTIAL><name>$scan_name</name><login>$ssh_username</login><password>$ssh_password</password></CREATE_CREDENTIAL>" | grep id`
credentialID=`echo $credentialID | cut -d "\"" -f2`


# Step2: Create Target and add Credentials to it
targetID=`omp -u $openvas_username -w $openvas_password -iX "<CREATE_TARGET><name>$scan_name</name><hosts>$ip</hosts><ssh_lsc_credential id='$credentialID'><port>22</port></ssh_lsc_credential></CREATE_TARGET>"`
targetID=`echo $targetID | cut -d "\"" -f2`

# Scan Config ID of Full and Fast Ultimate Scan: 698f691e-7489-11df-9d8c-002264764cea
# Step3: Create Task and provide target and scan config id
#8715c877-47a0-438d-98a3-27c7a6ab2196  Discovery
#085569ce-73ed-11df-83c3-002264764cea  empty
#daba56c8-73ec-11df-a475-002264764cea  Full and fast
#698f691e-7489-11df-9d8c-002264764cea  Full and fast ultimate
#708f25c4-7489-11df-8094-002264764cea  Full and very deep
#74db13d6-7489-11df-91b9-002264764cea  Full and very deep ultimate
#2d3f051c-55ba-11e3-bf43-406186ea4fc5  Host Discovery
#bbca7412-a950-11e3-9109-406186ea4fc5  System Discovery

#scanConfigID="698f691e-7489-11df-9d8c-002264764cea" #Full and Fast Ultimate
scanConfigID="bbca7412-a950-11e3-9109-406186ea4fc5" #System Discovery

taskID=`omp -u $openvas_username -w $openvas_password -iX "<CREATE_TASK><name>$scan_name</name><Comment>Deep Scan on $ip</Comment><target id='$targetID'/><config id='$scanConfigID'/></CREATE_TASK>"`
taskID=`echo $taskID | cut -d "\"" -f2`


# Step4: Running the task and get report ID
reportID=`omp -u $openvas_username -w $openvas_password -iX "<start_task task_id='$taskID'/>"`
reportID=`echo $reportID | cut -d ">" -f3 | cut -d "<" -f1`
echo $reportID

scanCompleted=0
# Loop till we get our scan in the status as done
while [ "$scanCompleted" -ne "1" ]
do
	sleep 2s
	isRunningTask=`omp -u $openvas_username -w $openvas_password -G | grep "$scan_name" | grep "Running" `
	isCompletedTask=`omp -u $openvas_username -w $openvas_password -G | grep "$scan_name" | grep "Done" `
	#Check status

	if [ -z "$isCompletedTask" ]; then
		echo $isRunningTask;sleep 1m
	else
		scanCompleted=1
	fi

done

# Step5: Define Format and Fetch Report
#5057e5cc-b825-11e4-9d0e-28d24461215b  Anonymous XML
#910200ca-dc05-11e1-954f-406186ea4fc5  ARF
#5ceff8ba-1f62-11e1-ab9f-406186ea4fc5  CPE
#9087b18c-626c-11e3-8892-406186ea4fc5  CSV Hosts
#c1645568-627a-11e3-a660-406186ea4fc5  CSV Results
#6c248850-1f62-11e1-b082-406186ea4fc5  HTML
#77bd6c4a-1f62-11e1-abf0-406186ea4fc5  ITG
#a684c02c-b531-11e1-bdc2-406186ea4fc5  LaTeX
#9ca6fe72-1f62-11e1-9e7c-406186ea4fc5  NBE
#c402cc3e-b531-11e1-9163-406186ea4fc5  PDF
#9e5e5deb-879e-4ecc-8be6-a71cd0875cdd  Topology SVG
#a3810a62-1f62-11e1-9219-406186ea4fc5  TXT
#c15ad349-bd8d-457a-880a-c7056532ee15  Verinice ISM
#50c9950a-f326-11e4-800c-28d24461215b  Verinice ITG
#a994b278-1f62-11e1-96ac-406186ea4fc5  XML

formatID="c402cc3e-b531-11e1-9163-406186ea4fc5" #PDF Format
fetchReport=`omp -u $openvas_username -w $openvas_password -iX "<get_reports report_id='$reportID' format_id='$formatID'/>"`
echo $fetchReport > ./temp/response.txt

# Step6: Parse Data and save it to PDF
python parseResponseAndSaveFile.py $scan_name
