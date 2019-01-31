#!/usr/bin/python
import os
import base64
import sys
import xml.etree.ElementTree as ET

scanName = sys.argv[1]

currentPath = os.getcwd()
responsePath = currentPath + "/temp/response.txt"
fdesc = open(responsePath, "r")
base64Data = fdesc.readlines()

root = ET.fromstring(base64Data[0].strip('\n'))
pdfContent = root[0].text

decodedData = base64.b64decode(pdfContent)
destinationPath = currentPath + "/reports/" + scanName + ".pdf"
writeFile = open(destinationPath, "wb")
writeFile.write(decodedData)
writeFile.close()

