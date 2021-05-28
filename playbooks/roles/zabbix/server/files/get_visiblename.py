#!/usr/bin/python

import urllib.request, urllib.error, urllib.parse
import json
import sys
import os

user = os.getenv("ZABBIX_USER")
password = os.getenv("ZABBIX_PASS")
server = os.getenv("ZABBIX_SERVER")

if not user or not password or not server:
    print("Environment vars must be set: ZABBIX_SERVER, ZABBIX_USER, ZABBIX_PASS")
    sys.exit(1)

api = server + "/api_jsonrpc.php"

def get_token():
    data = {'jsonrpc': '2.0', 'method': 'user.login', 'params':
            {'user': user, 'password': password}, 'id': '0'}
    req = urllib.request.Request(api)
    data_json = json.dumps(data).encode()
    req.add_header('content-type', 'application/json-rpc')
    try:
        response = urllib.request.urlopen(req, data_json)
    except urllib.error.HTTPError as ue:
        print("Error token: " + str(ue))
        sys.exit(1)
    else:
        authtoken = str(response.read().decode('utf8').split(',')[1].split(':')[1].strip('"'))
        return authtoken

def get_host_visual_names(host_pattern):
    data = {"jsonrpc": "2.0", "method": "host.get", "params":
            {"output": "extend", "search": {"host": [host_pattern]}},
            "startSearch": 1, "auth": token, "id": 0}
    req = urllib.request.Request(api)
    data_json = json.dumps(data).encode()
    req.add_header('content-type', 'application/json-rpc')
    try:
        response = urllib.request.urlopen(req, data_json)
    except urllib.error.HTTPError as ue:
        print("Error host.get: " + str(ue))
    else:
        try:
            res = json.loads(response.read())
        except:
            res = {}
        hosts = [host.get('name', '') for host in res.get('result', [])]
        return hosts

if len(sys.argv) == 2:
    token = get_token()
    host_names = get_host_visual_names(sys.argv[1])
    if host_names:
        print("\n".join(host_names).encode('utf-8').strip())
else:
    print("Usage: ZABBIX_SERVER=https://server ZABBIX_USER=user ZABBIX_PASS=pass " \
          "{} <host_pattern>".format(sys.argv[0]))
    sys.exit(1)
