#!/usr/bin/python
import os
import base64
import sys

scanName = sys.argv[1]

currentPath = os.getcwd()
responsePath = currentPath + "/temp/response.txt"
fdesc = open(responsePath, "r")
base64Data = fdesc.readlines()
decodedData = base64.b64decode(base64Data[0].strip('\n'))
destinationPath = currentPath + "/reports/" + scanName + ".pdf"
writeFile = open(destinationPath, "wb")
writeFile.write(decodedData)
writeFile.close()

