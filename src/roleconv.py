import sys,os
import re
from xml.dom.minidom import parseString
from xml.etree.ElementTree import Element,SubElement,ElementTree,dump
from os import path
if(len(sys.argv)==1):
    print("the tool to convert gifs to seperate swf and generate a role.xml for RoleX")
    print("""
useage:
    python roleconv.py folder
"""
def indent(elem, level=0):
    i = "\r\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

gif2swf="D:/software/SWFTools/gif2swf.exe"
output=sys.argv[1]+"-swf"
xml=output+"/role.xml"

root=Element("role")
SubElement(root,"name").text="name"
SubElement(root,"sex").text="male"
SubElement(root,"version").text="0.9"

if not path.exists(output):
    os.mkdir(output)
#prepare for role.xml

for item in (os.listdir(sys.argv[1])):
    name=item.split('.')[0]
    #os.system(gif2swf+" -z -o"+output+'\\'+name+".swf"+' '+sys.argv[1]+'\\'+item)
    emo=(re.split('[-.)(]',item))
    el=(root.find("emo[@name='"+emo[1]+"']"))
    if el==None:
        el=SubElement(root,'emo',{'name':emo[1]})
    if(emo[2]=='a'):
        tag='normal'
    elif emo[2]=='b':
        tag='speak'
    else:
        tag='action'
    SubElement(el,tag).text=name+".swf"
indent(root)
ElementTree(root).write(xml)



