# Openvas-Automation
The instructions provide a simpler way to install and run openvas docker container. The script automates the process of scanning a host provided with (IP, SSH Username and SSH Password). This automatically generates the report for further analysis. It can be easily integrated in CI pipeline provided the report analysis has to be done manually. Future implementation contain providing a REST api wrapper around the script and use Vulnerability Scanning As A Service Feature

<b><u><h2>Automated Authenticated Vulnerability Assessment using Openvas</h2></u></b>

<b>Installation:</b><br>
<b>1.	Docker should be installed</b><br> 
<i>sudo apt-get install docker.io</i><br>
<b>2.	Pull and run openvas docker by mapping required ports </b><br>
<i>docker run -d -p 443:443 -p 9390:9390 -e OV_PASSWORD=admin  --name openvas mikesplain/openvas</i><br>
<b>3.	Check if docker is running</b><br>
<i>docker container ls</i><br>
<b>4.	Add openvas to /etc/hosts</b><br>
<b>5.	Inside docker shell, change password of openvas</b><br>
<i>openvasmd --user=admin --new-password=new_password</i><br>


<b>Description:</b><br>
(OMP) Together, OpenVAS Scanner (openvassd(8)) and OpenVAS Manager (openvasmd(8)) provide the core functionality of the Open Vulnerability Assessment System (OpenVAS), with OpenVAS Scanner handling the actual scan process and OpenVAS Manager adding various management functionalities to handle and organise scan results.
The omp binary is a command line client which uses the OMP protocol to connect to the OpenVAS Manager and makes it easy to access the full functionality provided by the OpenVAS Manager conveniently from the command line and allows quick integration in a scripted environment.<br>

<b>Check if OMP is installed</b><br>
<i>1.	Get docker shell (docker exec -it  <container ID>  /bin/bash)<br>
2.	Connect to omp to check if it is working (omp    -h   <IP>   -u   <username>   -w   <password> -g)<br>
  3.	This should give a list of scan types available</i><br>


<b>Creating Credentials</b><br>
<i>omp -u admin -w admin -iX "<CREATE_CREDENTIAL><name>kali login</name><login>root</login><password>toor</password></CREATE_CREDENTIAL>"<br></i>

<b>Add Target and add credentials to it</b><br>
<i>omp -u admin -w admin -iX "<CREATE_TARGET><name>Base Image test9</name><hosts>192.168.213.133</hosts><ssh_lsc_credential id='f34aae8f-0c2a-43dd-b0a4-18b7e45d7c3f'><port>22</port></ssh_lsc_credential></CREATE_TARGET>"</i><br>


<b>Create Task with Target and Scan Config( -g in omp can show all supported config)</b><br>
<i>omp -u admin -w admin -iX "<CREATE_TASK><name>KALI Full Scan</name><Comment>Deep Scan on Kali Image</Comment><target id='fa1721ea-9ae2-41c1-8349-447cd5d4451e'/><config id='698f691e-7489-11df-9d8c-002264764cea'/></CREATE_TASK>"</i><br>

<b>Running a Task:</b><br>
<i>omp -u admin -w admin -iX "<start_task task_id='9b771df4-5f99-4906-bd6d-776defa0ca4a'/>"</i><br>

<b>Fetching Report<br></b>
<i>omp -u admin -w admin -iX "<get_reports report_id='03bd6238-9d27-4a8c-adf3-b5a93f1ce41a' format_id='c402cc3e-b531-11e1-9163-406186ea4fc5'/>"</i><br>

<b>Then covert the base 64 string to obtain type of report (PDF in this case)<br>

Checking status of tasks</b><br>
<i>omp -u admin -w admin -G</i><br>
