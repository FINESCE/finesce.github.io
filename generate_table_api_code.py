from lxml import etree

file_name = "API_methods_div"

root = etree.parse(file_name, etree.HTMLParser(encoding="utf-8"))
categories = root.xpath("//div[@class='resourceGroup']")
for category in categories:
	category_name = category.xpath("./h1[@class='resourceGroupName']/text()")
	if category_name:
		category_name = category_name[0].replace("\n","").strip()
		methods = category.xpath(".//div[@class='resource2']")
		if methods:
			print "<tr><td rowspan='%d'>%s</td>" % (len(methods), category_name)
			is_first_method = True
			for method in methods:
				method_name = method.xpath(".//h2[@class='resource2Name']/text()")
				if method_name:
					method_name = method_name[0].replace("\n","").strip()
				else:
					method_name = "/"

				method_description = method.xpath(".//div[contains(@class,'resource2Description')]/p/text()")
				if method_description:
					method_description = method_description[0].replace("\n","").strip()
				else:
					method_description = "/"
				if not is_first_method:
					print "<tr>"
				print "<td>%s</td><td>%s</td></tr>" % (method_name, method_description)
		else:
			print "<tr><td>%s</td><td>/</td><td>/</td></tr>" % category_name
