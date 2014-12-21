The DSO catalog tools
=====================

This folder contains the tools for transforming the Redmine wiki 
contents describing the DSOs into the public catalog.

Input
-----

The input for the data are the Redmine pages on the FINESCE Domain
Specific Enablers (DSE). The wiki index page contains a table with names
and short descriptions of the DSEs:

https://rm.finesce.tssg.org/redmine/projects/finesce-domain-specific-enablers/wiki

The table also contains the links to the wiki pages of the detailed
descriptions.

Output
------

 * ***DSEs.json*** - contains the summaries of the DSEs to be used in
    the main catalogue selection page.
 * ***individual DSO's content json*** - contains the text information 
    extracted from the detailed DSE descriptions
 * ***download files*** - any files attached to the DSE details 
    description wiki page
 * ***images*** - images embedded into the DSE description and 
    referenced as attachments of the DSE details wiki page
 
Tool usage
----------

```bash
# set the cookie
$ export COOKIE="_redmine_default=A7hB....4461; path=/redmine; HttpOnly"

# fetch the TCO table
$ ./fetch.sh "$COOKIE"
Saved the index to /tmp/redmine_dse_index.html

# process the DSEs (do not forget the quotation marks around the cookie)
$ python parse_index_table.py /tmp/redmine_dse_index.html ../js/json/DSEs.json ../js/json ../attachments ../images/redmine "$COOKIE"
Written the DSO table of contents to /tmp/DSEs.json
Fetching 'Integration kit DSE' from https://rm.finesce.tssg.org/redmine/projects/finesce-domain-specific-enablers/wiki/Integration_kit_DSE
Saved the index to /tmp/Integration_kit_DSE.html
Fetching 'Modbus Connector (ModConn) DSE' from https://rm.finesce.tssg.org/redmine/projects/finesce-domain-specific-enablers/wiki/Modbus_Connector_(ModConn)_DSE
Saved the index to /tmp/Modbus_Connector_(ModConn)_DSE.html
[...]
Fetching 'FINESCE API Mediator (FAM) DSE' from https://rm.finesce.tssg.org/redmine/projects/finesce-domain-specific-enablers/wiki/FINESCE_API_Mediator_(FAM)_DSE
Saved the index to /tmp/FINESCE_API_Mediator_(FAM)_DSE.html
```

Paths
-----

 * ***python/*** - the directory with tools
 * ***js/json/*** - contains the extracted JSONs
 * ***files/*** - the attachment files in the DSE
