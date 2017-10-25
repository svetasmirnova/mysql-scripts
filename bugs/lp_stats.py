cachedir="/home/sveta/tmp/lp"

from launchpadlib.launchpad import Launchpad
import datetime as dt

launchpad = Launchpad.login_with('percona-server', 'production')

project = launchpad.projects['percona-server']

first_year=2014
last_year=2018

for y in range(first_year, last_year):
	for m in range(1, 13):
		if 12 == m:
			mm = 1
			yy = y + 1
		else:
			mm = m + 1
			yy = y
		start_date = dt.datetime(y, m, 1) 
		end_date = dt.datetime(yy, mm, 1)
		print (start_date, end_date)
		print len(project.searchTasks(created_since=start_date, created_before=end_date, omit_duplicates=False, status = ['New', 'Opinion', 'Invalid', 'Won\'t Fix', 'Expired', 'Confirmed', 'Triaged', 'In Progress', 'Fix Committed', 'Fix Released', 'Incomplete (with response)', 'Incomplete (without response)']))


