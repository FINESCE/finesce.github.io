import sys
import lxml.html
import bs4
import json
import re

def usage():
    print("""
Usage: parseDSE.py [NAME INPUT_FILE_PATH OUTPUT_JSON_PATH]

Reads the DSE description from the html file that has been saved
from the Redmine wiki. It extracts the description text and packages
it into a json file.

NAME: the name of the DSO (? ID perhaps?)

INPUT_FILE_PATH: the path to the html containing the Redmine wiki page
    contents
    
OUTPUT_JSON_PATH: the path to the output json file

    """)

class DSEData_documentation(object):
    preface = ""
    copyright = ""
    dse_description = ""
    detailed_specs = ""
    glossary = ""
    references = ""
    
    def __repr__(self):
        return "{Preface:" + repr(self.preface) + ", Copyright:" + repr(self.copyright) + ", Description:" + repr(self.dse_description) + ", Detailed specs:" +repr(self.detailed_specs) + ", Glossary:" +repr(self.glossary) + ", References:" +repr(self.references)
    
    def toJSON(self):
        return {'Preface': self.preface, \
                'Copyright': self.copyright, \
                'Description': self.dse_description, \
                'Details':self.detailed_specs, \
                'Glossary':self.glossary, \
                'References':self.references
                };
        
    
class DSEData(object):
    work_package = ""
    name = ""
    short_description = ""
    open_source = ""    #TODO: this was false
    contact_person = ""
    overview = ""
    target_usage = ""
    documentation = DSEData_documentation()
    downloads = ""
    instances = ""
    terms = ""
    
    def __repr__(self):
        return "WP:" + repr(self.work_package) + \
               ", Name:" + repr(self.name) + \
               ", Short Description:" + repr(self.short_description) + \
               ", Open Source:" + repr(self.open_source) + \
               ", Contact Person:" + repr(self.contact_person) + \
               ", Overview:" + repr(self.overview) + \
               ", Target Usage:" + repr(self.target_usage) + \
               ", Documentation:" + repr(self.documentation) + \
               ", Downloads:" + repr(self.downloads) + \
               ", Instances:" + repr(self.instances) + \
               ", Terms and Conditions:" + repr(self.terms)
               
    def toJSON(self):
        return [{'WP': self.work_package, \
                 'Name': self.name, \
                 'Short Description': self.short_description, \
                 'Contact Person':  self.contact_person, \
                 'Open Source':  self.open_source, \
                 'Overview':  self.overview, \
                 'Target Usage': self.target_usage, \
                 'Documentation':  self.documentation.toJSON(), \
                 'Downloads':  self.downloads, \
                 'Instances':  self.instances, \
                 'Terms and Conditions':  self.terms
               }];
           #"}"
               
class DSEEncoder(json.JSONEncoder):
    def default(self, obj):
        #return "{\"newjson\":12}"
        if isinstance(obj, DSEData):
            return obj.toJSON()
        
        if isinstance(obj, DSEData_documentation):
            return [obj.real, obj.imag]
        # Let the base class default method raise the TypeError
        return json.JSONEncoder.default(self, obj)

name = "COS" if len(sys.argv) <= 1 else sys.argv[1]
input_fname =  name+".html" if len(sys.argv) <= 2 else sys.argv[2]
output_json_path = '../enablers/DSEs.json' if len(sys.argv) <= 3 else sys.argv[3]

images_path = "images/redmine"
attachments_path = "files"

htmlcontent = open(input_fname,'r').read()
soup = bs4.BeautifulSoup(htmlcontent)

content = soup.find("div", {"id": "content"})

def redirect_images(text):
    text = re.sub(r'(<img.+src=\")/redmine/attachments/download/.+/([^/]+)\"', 
            "\\1%s/\\2\"" % images_path, text)
    return text

def redirect_attachments(text):
    pattern = re.compile(r"<a.+href=\"/redmine/attachments/download/.+/([^\"]+)\"")
    for att_url in re.findall(pattern, text):
        print("%s" % att_url)
    text = re.sub(r'(<a.+href=\")/redmine/attachments/download/.+/([^/]+)\"', 
            "\\1%s/\\2\"" % attachments_path, text)
    return text

def processH2(start):
    processed_part = ""
    for sibling in h2.next_siblings:
        try:
            tag_name = sibling.name
        except AttributeError:
            tag_name = ""
        if tag_name != "h2":
            if type(sibling) == bs4.element.NavigableString or sibling.get('class') == None or (not "contextual" in sibling.get('class') and not "wiki-anchor" in sibling.get('class')):
                #if type(sibling) != bs4.element.NavigableString and sibling.get('class') != None:
                #    print sibling.get('class'), ":x: ", sibling
                #else:
                if type(sibling) == bs4.element.Tag:
                    processed_part += sibling.prettify()
                    #print "adding ", sibling.prettify()
                else:
                    processed_part += sibling
                    #print "add ", sibling
        else:
            break
        #if type(sibling) != BeautifulSoup.NavigableString and sibling.tag == "h2":
    
    processed_part = redirect_images(processed_part)
    processed_part = redirect_attachments(processed_part)
    
    return processed_part
    

dse_data = DSEData()
for h2 in content.find_all("h2"):
    h2_text = h2.text.lstrip()
    #print h2_text
    if h2_text.startswith("Copyright"):
        dse_data.documentation.copyright = processH2(h2)
    elif h2_text.startswith("Preface"):
        dse_data.documentation.preface = processH2(h2)
    elif h2_text.startswith("T&Cs") or h2_text.startswith("Terms and Conditions"):
        dse_data.terms = processH2(h2)
    elif h2_text.startswith("Overview"):
        dse_data.overview = processH2(h2)
    elif h2_text.startswith("Target Usage"):
        dse_data.documentation.target_usage = processH2(h2)
    elif h2_text.startswith("DSE Description"):
        dse_data.documentation.dse_description = processH2(h2)
    elif h2_text.startswith("Detailed Specifications"):
        dse_data.documentation.detailed_specs = processH2(h2)
    elif h2_text.startswith("Re-utilised Technologies/Specifications"):
        dse_data.documentation.reutilised_tech = processH2(h2)
    elif h2_text.startswith("Terms and Definitions") or h2_text.startswith("Glossary"):
        dse_data.documentation.glossary = processH2(h2)
    elif h2_text.startswith("References"):
        dse_data.documentation.references = processH2(h2)
#print
dse_data.name = name
"""print "DSE data:"
print dse_data
print dse_data.documentation.dse_description
print dse_data.overview
dse_data.documentation = ""
"""

with open(output_json_path, 'w') as outfile:
    json.dump(dse_data, outfile, indent=4, separators=(',', ': '), cls=DSEEncoder)
#print(content.prettify())

"""
root = lxml.html.parse("COS.html", parser=None, base_url=None)
#print lxml.html.tostring(root)
header = root.findall('.//h1')

startPrinting = False
for content in root.getiterator():
    if startPrinting:
        print content.text
    if content.tag == 'h2' and content.text == "DSE Description":
        startPrinting = True
    elif content.tag == 'h2':
        startPrinting = False
#for title in header:
#    print title.index()
#print len(header)
"""
