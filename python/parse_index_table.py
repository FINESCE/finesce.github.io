import sys
from subprocess import call
from lxml import etree
import re
import json

def usage():
	print """
	parse_index_table.py [ INPUT_FILE_PATH [ JSON_OUTPUT [ OUTPUT_PATH HTTP_COOKIE ] ] 
	
	Reads the HTML file refered to as INPUT_FILE_PATH or /tmp/redmine_dse_index.html
	if the parameter is missing. It parses the table containing the
	DSE summaries and produces a JSON-formatted output.
	
	JSON_OUTPUT: the path to store the DSO TOC json
	
	OUTPUT_PATH: the path where the individual DSO's JSON files will be
	    stored.
	    
	HTTP_COOKIE: the cookie for accessing Redmine wiki pages, e.g.:
	     _redmine_default=A7hB....4461; path=/redmine; HttpOnly
	"""

file_name = "/tmp/redmine_dse_index.html" if len(sys.argv) <= 1 else sys.argv[1]
json_output = "/tmp/DSEs.json" if len(sys.argv) <= 2 else sys.argv[2]
output_path = "/tmp" if len(sys.argv) <= 3 else sys.argv[3]
cookie = None if len(sys.argv) <= 4 else sys.argv[4]
redmine_url = "https://rm.finesce.tssg.org"

root = etree.parse(file_name, etree.HTMLParser(encoding="utf-8"))
main_content = root.xpath("//div[@id='content']")[0]
table = main_content.xpath(".//table")[0]
rows = table.xpath(".//tr")

output = [ ]

for row in rows[1:]:
	cells = row.getchildren()
	wp = cells[0].text.strip()
	dse_cell = cells[1].getchildren()
	if len(dse_cell) == 0:
		# TODO handle any DSEs with no links
		continue
	else:
		dse_title = dse_cell[0].text
		dse_link = dse_cell[0].get('href')
		m = re.search(r"/[^/]+$", dse_link)
		dse_id = m.group(0)
		if dse_id[0] == '/':
			dse_id = dse_id[1:]

	description = cells[2].text.strip()
	option = cells[3].text.strip()
	site = cells[4].text.strip()

	output.append({
		"id": dse_id,
		"wp": wp,
		"name": dse_title,
		"wiki_link": dse_link,
		"option": option,
		"site": site,
		"description": description,
	})

# export the DSO table of contents
with open(json_output, 'w') as f_json:
	json.dump(output, f_json, indent=4)
print("Written the DSO table of contents to " + json_output)

if not cookie:
	print("No HTTP_COOKIE provided. Stopping here.")
else:
	for dse_line in output:
		html_path = "/tmp/%s.html" % dse_line['id']
		json_path = "%s/%s.json" % (output_path, dse_line['id'])
		url_source = "%s%s" % (redmine_url, dse_line['wiki_link'])
		
		print("Fetching '%s' from %s" % (dse_line['name'], url_source))
		call(['./fetch.sh', cookie, url_source, html_path])
		
		print("Processing '%s'" % dse_line['name'])
		call(['python', 'parseDSE.py', dse_line['name'], html_path, 
			json_path])
