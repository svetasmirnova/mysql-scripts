#!/usr/bin/python3

from launchpadlib.launchpad import Launchpad
import datetime as dt
import argparse
import re

def print_stats(projects):
	tasks = project.searchTasks(status = ['New', 'Opinion', 'Invalid', 'Won\'t Fix', 'Expired', 'Confirmed', 'Triaged', 'In Progress', 'Fix Committed', 'Fix Released', 'Incomplete (with response)', 'Incomplete (without response)'])
	itag = re.compile(r"^i\d+")
	
	customer_tasks=[]
	
	fixed_tasks = 0
	confirmed_tasks = 0
	open_tasks = 0

	for t in tasks:
		b=launchpad.bugs[t.bug_link.rsplit('/', 1)[-1]]
		tags = b.tags
		for tag in tags:
			if(itag.search(tag)):
				if (t.status in ['Fix Committed', 'Fix Released']):
					fixed_tasks += 1;
				if (t.status in [ 'Confirmed', 'T    riaged', 'In Progress']):
					confirmed_tasks += 1;
				if (t.status in ['New', 'Incomplete (with response)', 'Incomplete (without res    ponse)']):
					open_tasks += 1;
				customer_tasks.append(b)
	
	print("Tasks total: ", len(customer_tasks))
	print("Fixed: ", fixed_tasks)
	print("Open (needs to be verified): ", open_tasks)

	print("Details")
	print("====")

	for c in customer_tasks:
		print("Bug #", c.id, " ", c.title)
		print(c.tags)
		print(c.web_link)
		print("====")

launchpad = Launchpad.login_with('percona-server', 'production')

projects = ['percona-server', 'percona-xtradb-cluster', 'percona-xtrabackup', 'percona-toolkit']

for p in projects:
	print(p)
	print("====")
	project = launchpad.projects[p]
	print_stats(project)
