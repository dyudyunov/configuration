#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import json
import sys
import os
import warnings
warnings.filterwarnings("ignore")

user = os.getenv("ZABBIX_USER")
password = os.getenv("ZABBIX_PASS")
server = os.getenv("ZABBIX_SERVER")

if not user or not password or not server:
    print("Environment vars must be set: ZABBIX_SERVER, ZABBIX_USER, ZABBIX_PASS")
    sys.exit(1)

api_url = server + "/api_jsonrpc.php"

def get_token(api_url):
    data = {'jsonrpc': '2.0', 'method': 'user.login', 'params':
            {'user': user, 'password': password}, 'id': '0'}
    data_json = json.dumps(data).encode()
    try:
        response = requests.post(api_url, headers={'content-type': 'application/json-rpc; charset=utf8'}, data=data_json)
    except requests.exceptions.HTTPError as err:
        print("Error requesting token: {}".format(err))
        sys.exit(1)
    except requests.exceptions.ConnectionError as err:
        print("Error requesting host.get: {}".format(err))
        sys.exit(1)

    return response.json().get('result', None)

def get_host_visual_names(api_url, host_pattern):
    data = {"jsonrpc": "2.0", "method": "host.get", "params":
            {"output": "extend", "search": {"host": [host_pattern]}, "startSearch": 1},
            "auth": token, "id": 0}
    data_json = json.dumps(data).encode()
    try:
        response = requests.post(api_url, headers={'content-type': 'application/json-rpc; charset=utf8'}, data=data_json)
    except requests.exceptions.HTTPError as err:
        print("Error requesting host.get: {}".format(err))
        sys.exit(1)
    except requests.exceptions.ConnectionError as err:
        print("Error requesting host.get: {}".format(err))
        sys.exit(1)

    hosts = []
    try:
        res = json.loads(response.text)
    except:
        res = {}

    for host in res.get('result', []):
        hosts.append(host.get('name', ''))

    return hosts

if len(sys.argv) == 2:
    token = get_token(api_url)
    host_names = get_host_visual_names(api_url, sys.argv[1])
    if host_names:
        print(u"\n".join(host_names).strip())
else:
    print("Usage: ZABBIX_SERVER=https://server ZABBIX_USER=user ZABBIX_PASS=pass " \
          "{} <host_pattern>".format(sys.argv[0]))
    sys.exit(1)
