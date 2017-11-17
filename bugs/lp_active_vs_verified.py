#!/usr/bin/python3

from launchpadlib.launchpad import Launchpad
import datetime as dt
import argparse
from pathlib import Path
from prettytable import PrettyTable

import plotly.plotly as py
import plotly.graph_objs as go

def print_table(bugs):
	total_active = 0
	total_not_ver = 0
	t = PrettyTable(['Product', 'Active Bugs', 'Non-Verified Bugs'])
	for b in bugs:
		#print(b)
		t.add_row([b, bugs[b]['Active'], bugs[b]['Not Verified']])
		total_active += bugs[b]['Active']
		total_not_ver += bugs[b]['Not Verified']
	t.add_row(['Total', total_active, total_not_ver])
	t.sortby = 'Active Bugs'
	print(t)

def draw_pie_chart(projects, bugs):
	values = []
	for p in projects:
		values.append(bugs[p]['Not Verified'])
	trace = go.Pie(labels=projects, values=values)
	py.iplot([trace], filename='NotVerifiedByProject')

def draw_bar_chart(projects, bugs):
	active = []
	not_ver = []
	for p in projects:
		active.append(bugs[p]['Active']- bugs[p]['Not Verified'])
		not_ver.append(bugs[p]['Not Verified'])
	
	trace1 = go.Bar(
		x = projects,
		y = active,
		name = 'Verified Bugs'
	)

	trace2 = go.Bar(
		x = projects,
		y = not_ver,
		name = 'Not Verified Bugs'
	)

	data = [trace1, trace2]
	layout = go.Layout(barmode='stack')

	fig = go.Figure(data=data, layout=layout)
	py.iplot(fig, filename='VerifiedVsNotVerified')

parser = argparse.ArgumentParser(description='Outputs statistics of active bugs: overall (in status "New", "Confirmed", "Triaged", "In Progress", "Incomplete") and bugs which are waiting verification (in status "New" or "Incomplete")')
parser.add_argument('--cache', help='cache to store data, retrieved from Launchpad', default=str(Path.home()) + '/tmp/lp')
args = parser.parse_args()

launchpad = Launchpad.login_with('percona-server', 'production')

projects = ['percona-server', 'percona-xtradb-cluster', 'percona-xtrabackup', 'percona-toolkit']

bugs = {}

for p in projects:
	bugs[p] = {}
	project = launchpad.projects[p]
	bugs[p]['Active'] = len(project.searchTasks(status = ['New', 'Confirmed', 'Triaged', 'In Progress', 'Incomplete (with response)', 'Incomplete (without response)']))
	bugs[p]['Not Verified'] = len(project.searchTasks(status = ['New', 'Incomplete (with response)', 'Incomplete (without response)']))

print_table(bugs)
draw_pie_chart(projects, bugs)
draw_bar_chart(projects, bugs)
