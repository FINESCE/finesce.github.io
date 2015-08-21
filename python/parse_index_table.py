import sys
import os.path
from subprocess import call
from lxml import etree
import urllib
import re
import json
import argparse
import datetime


def query_cleanup(text):
	return re.sub('\\+', '_', text)
	
parser = argparse.ArgumentParser(
	description="Extractor and parser of Redmine DSE descriptions. "
		"Reads the HTML file refered to as INPUT_FILE_PATH or /tmp/redmine_dse_index.html "
		"if the parameter is missing. It parses the table containing the "
		"DSE summaries and produces a JSON-formatted output."
	)

parser.add_argument('-i', '--input', action='store', 
	metavar='INPUT_FILE_PATH', 
	default="/tmp/redmine_dse_index.html", 
	help='input file containing the DSE index')
parser.add_argument('-t', '--toc', action='store', 
	metavar='JSON_TOC_OUTPUT', 
	default='../js/json/DSEs.json',
	help='the path to store the DSO TOC json')
parser.add_argument('-o', '--outputpath', action='store',
	metavar='OUTPUT_PATH', 
	default='../js/json',
	help="the path where the individual DSO's JSON files will be stored")
parser.add_argument('-a', '--attachments', action='store',
	metavar='ATTACHMENTS_PATH', 
	default='../files',
	help='the path where the attachments (non-image ones) should be stored')
parser.add_argument('-m', '--images', action='store',
	metavar='IMAGES_PATH',
	default='../images/redmine',
	help='the path where the image attachments should be stored')
parser.add_argument('-c', '--cookie', action='store',
	metavar='HTTP_COOKIE',
	help='the cookie for accessing Redmine wiki pages, e.g.:\n'
	     '"_redmine_default=A7hB....4461; path=/redmine; HttpOnly"')

args = parser.parse_args()

file_name = args.input
json_output = args.toc
output_path = args.outputpath
attachments_path = args.attachments
images_path = args.images
cookie = args.cookie
redmine_url = "https://rm.finesce.tssg.org"

root = etree.parse(file_name, etree.HTMLParser(encoding="utf-8"))
main_content = root.xpath("//div[@id='content']")[0]
table = main_content.xpath(".//table")[0]
rows = table.xpath(".//tr")

output = []

for row in rows[1:]:
	cells = row.getchildren()
	work_package = cells[0].text.strip()
	dse_cell = cells[1].getchildren()
	if len(dse_cell) == 0:
		# TODO handle any DSEs with no links
		continue
	else:
		dse_title = dse_cell[0].text
		dse_link = dse_cell[0].get('href')
		m = re.search(r"/[^/]+$", dse_link)
		dse_id = query_cleanup(m.group(0))
		if dse_id[0] == '/':
			dse_id = dse_id[1:]

	description = " ".join([si.strip() for si in cells[2].itertext()])
	option = cells[3].text.strip()
	site = cells[4].text.strip()
	categories = cells[5].text.strip()
	do_publish = cells[6].text.strip()
	if do_publish[0:3].lower() != "yes":
		continue
	
	if site == "":
		site = "(no site specified)" 

	output.append({
		"id": dse_id,
		"work_package": work_package,
		"name": dse_title,
		"wiki_link": dse_link,
		"option": option,
		"site": site,
		"description": description,
		"categories": categories
	})

# reorder output accoring to the previous order
oldOrder = []
orderedOutput = []
with open(json_output, 'r') as f_json:
	j = f_json.read()
	oldData = json.loads(j)['dse']
	oldOrder = [d['id'] for d in oldData]

for itemId in oldOrder:
	prev = [d for d in output if d['id'] == itemId]
	if len(prev) > 0:
		prev = prev[0]
		output.remove(prev)
		orderedOutput.append(prev)

# append any new item to orderedOutput
orderedOutput = orderedOutput + output

# Add the updated timestamp
output = {
	'updated': datetime.datetime.now().isoformat(),
	'dse': orderedOutput
}

# export the DSO table of contents
with open(json_output, 'w') as f_json:
	json.dump(output, f_json, indent=4)
print("Written the DSO table of contents to " + json_output)

if not cookie:
	print("No HTTP_COOKIE provided. Stopping here.")
else:
	for dse_line in output['dse']:
		html_path = "/tmp/%s.html" % dse_line['id']
		json_path = "%s/%s.json" % (output_path, dse_line['id'])
		url_source = "%s%s" % (redmine_url, dse_line['wiki_link'])
		
		print("Fetching '%s' from %s" % (dse_line['name'], url_source))
		call(['./fetch.sh', cookie, url_source, html_path])
		
		print("Processing '%s'" % dse_line['name'])
		call(['python', 'parseDSE.py', dse_line['name'], html_path, 
			json_path])
			
		print("Downloading any attachments")
		with open(json_path, 'r') as jf:
			j = jf.read()
			dse_data_result = json.loads(j)[0]
			
		for att_path in dse_data_result.get('wiki_attachments', [ ]):
			att_fname = os.path.basename(att_path)
			att_fname = urllib.unquote(att_fname)	#save files unescaped, otherwise there might be 404 errors when downloading
			att_url = "%s%s" % (redmine_url, att_path)
			file_ext = os.path.splitext(att_path)[1].lower()
			if file_ext in [ '.jpg', '.jpeg', '.png', '.gif' ]:
				dl_path = images_path
			else:
				dl_path = attachments_path
								
			#print("    %s -> %s" % (att_fname, dl_path))
			call(['./fetch.sh', cookie, att_url, 
				"%s/%s" % (dl_path, att_fname)])
