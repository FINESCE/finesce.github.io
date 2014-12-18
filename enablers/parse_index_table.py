from lxml import etree
import re

file_name = "/tmp/redmine_dse_index.html"

root = etree.parse(file_name, etree.HTMLParser(encoding="utf-8"))
main_content = root.xpath("//div[@id='content']")[0]
table = main_content.xpath(".//table")[0]
rows = table.xpath(".//tr")
for row in rows[1:]:
	cells = row.getchildren()
	wp = cells[0].text
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

	option = cells[2].text
	description = cells[3].text
	site = cells[4].text
	
	print('{ "id": "%s", "wp": %s, "name": "%s", "link": "%s", "option": "%s", site: "%s", description: "%s" }' %
		(dse_id, wp, dse_title, dse_link, option, site, description))	

