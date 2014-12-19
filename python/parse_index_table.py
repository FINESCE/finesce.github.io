import sys
from lxml import etree
import re
import json

def usage():
	print """
	parse_index_table.py [ INPUT_FILE_PATH [ JSON_OUTPUT [ OUTPUT_PATH ] ] 
	
	Reads the HTML file refered to as INPUT_FILE_PATH or /tmp/redmine_dse_index.html
	if the parameter is missing. It parses the table containing the
	DSE summaries and produces a JSON-formatted output.
	
	JSON_OUTPUT: the path to store the DSO TOC json
	
	OUTPUT_PATH: the path where the individual DSO's JSON files will be
	    stored.
	"""

file_name = "/tmp/redmine_dse_index.html" if len(sys.argv) <= 1 else sys.argv[1]

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

print(json.dumps(output, indent=4))

