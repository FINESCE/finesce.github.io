import lxml.html
import bs4

class DSEData_documentation(object):
    preface = ""
    copyright = ""
    dse_description = ""
    
    def __repr__(self):
        return "{Preface:" + repr(self.preface) + ", Copyright:" + repr(self.copyright) + ", Description:" + repr(self.dse_description)
    
class DSEData(object):
    work_package = ""
    name = ""
    short_description = ""
    open_source = False
    contact_person = ""
    overview = ""
    documentation = DSEData_documentation
    downloads = ""
    instances = ""
    terms = ""
    
    def __repr__(self):
        return "WP:" + repr(self.work_package) + \
               ", Name:" + repr(self.name) + \
               ", Short description:" + repr(self.short_description) + \
               ", Open Source:" + repr(self.open_source) + \
               ", Contact person:" + repr(self.contact_person) + \
               ", Overview:" + repr(self.overview) + \
               ", Documentation:" + repr(self.documentation) + \
               ", Downloads:" + repr(self.downloads) + \
               ", Instances:" + repr(self.instances) + \
               ", Terms and conditions:" + repr(self.terms)

htmlcontent = open("COS.html",'r').read()
soup = bs4.BeautifulSoup(htmlcontent)

content = soup.find("div", {"id": "content"})

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
    return processed_part

dse_data = DSEData()
for h2 in content.find_all("h2"):
    if h2.text.startswith("DSE Description"):
        dse_data.documentation.dse_description = processH2(h2)
print
print "DSE data:"
print dse_data
print dse_data.documentation.dse_description
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