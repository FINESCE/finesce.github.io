from lxml import etree

file_name = "API_methods_div"

print "<tr class='top'><th>Category</th><th>Method</th><th>Description</th></tr>"
root = etree.parse(file_name, etree.HTMLParser(encoding="utf-8"))
categories = root.xpath("//div[@class='resourceGroup']")
for category in categories:
	category_name = category.xpath("./h1[@class='resourceGroupName']/text()")
	if category_name:
		category_name = category_name[0].replace("\n","").strip()
		category_description = category.xpath("./div[contains(@class, 'resourceGroupDescription')]/p/text()")
		if category_description:
			category_description = "<br>%s" % (category_description[0].replace("\n", "").strip())
		else:
			category_description = ""
		methods = category.xpath(".//div[@class='resource']")
		if methods:
			print "<tr class=category><td class=left-nonbold rowspan='%d'><b>%s</b>%s</td>" % (
					len(methods), category_name, category_description)
			is_first_method = True
			for method in methods:
				method_name = method.xpath(".//h2[@class='resourceName']/text()")
				if method_name:
					method_name = method_name[0].replace("\n","").strip()
				else:
					method_name = "/"

				method_description = method.xpath(".//div[contains(@class,'resourceDescription')]/p/text()")
				if method_description:
					method_description = method_description[0].replace("\n","").strip()
				else:
					method_description = "/"
				if not is_first_method:
					print "<tr>"
				print "<td>%s</td><td>%s</td></tr>" % (method_name, method_description)
		else:
			print "<tr class=category><td class=left-nonbold><b>%s</b>%s</td><td>/</td><td>/</td></tr>" % (category_name, category_description)
