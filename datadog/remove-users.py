#!/bin/python

from datadog import initialize, api
import argparse

options = {
    'api_key': '2fqsdfsdqfsdfsfsffdfsdfsdfsb7c3d816',
    'app_key': '027f36605d98fdsfsdfsdfsdfsdf fsds qdf sqdf de7'
}

initialize(**options)
parser = argparse.ArgumentParser(description="Add description to security groups")
parser.add_argument("-u", "--username", dest="username", required=True, help='the username you want to delete')
parser.add_argument("-m", "--mail-extention", dest="mail", required=True, help='organization mail extention')

args = parser.parse_args()
username = str(args.username)
mail = str(args.mail)
full_username = username + '@' + mail

# Disable user
r = api.User.delete(full_username)
message = str(r.items()[0][1])
print full_username + " " + message
