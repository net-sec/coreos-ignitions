#!/usr/bin/env python3

import base64


string = b'ENV_VAR=hui'

encoded_body = base64.b64encode(string)
print("data:,{}".format(encoded_body.decode()))