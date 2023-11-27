#!/usr/bin/env python3

import collections.abc
import glob
import json
import os
import re
import sys

out_args = []

def add_rsp(filename):
	with open(filename) as f:
		rsp = json.load(f)
		if 'arguments' in rsp:
			add_rsp_args(rsp)
		elif 'options' in rsp:
			add_rsp_opts(rsp)

def add_rsp_args(rsp):
	for arg in rsp['arguments']:
		m = re.match(r'^--std_rsp=(.*)$', arg)
		if m:
			add_rsp(m.group(1))
		else:
			out_args.append(arg)

def add_rsp_opts(rsp):
	for opt in rsp['options']:
		if isinstance(opt, str):
			add_rsp_opt(opt)
		else:
			for (key, value) in opt.items():
				add_rsp_opt(key, value)

def add_rsp_opt(opt, value=None):
	if value != None and not isinstance(opt, collections.abc.Sequence):
		value = [value]
	if opt == "std_rsp":
		for filename in value:
			add_rsp(filename)
	elif value == None:
		out_args.append(opt_as_arg(opt))
	else:
		arg_name = opt_as_arg(opt)
		if opt in ["D", "I", "O", "W"]:
			out_args.extend(map(lambda v: arg_name+v, value))
		else:
			out_args.extend(map(lambda v: arg_name+"="+v, value))

def opt_as_arg(opt):
	if opt in ["help", "target-help", "version", "coverage", "entry", \
		"no-sysroot-suffix", "sysroot", "param"]:
		return "--"+opt
	else:
		return "-"+opt

for arg in sys.argv[1:]:
	m = re.match(r'^--std_rsp=(.*)$', arg)
	if m:
		add_rsp(m.group(1))
	else:
		out_args.append(arg)

out_args = map(glob.escape, out_args)
out_args = map(lambda s: s.replace(' ', '\ '), out_args)
out_args = ' '.join(out_args)
print(out_args)
