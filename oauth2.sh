#!/bin/bash

client_id=$1
authorization_url=$2
token_endpoint=$3

tmp_file_with_code=$(mktemp)

code_verifier=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-128} | head -n 1)
code_challenge=$(echo -n $code_verifier | openssl dgst -sha256 -binary | basenc --base64url -w0 | tr -d '=')

# Handle callback
echo `python - << EOF
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qsl, urlsplit

class GetHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        code = dict(parse_qsl(
            urlsplit(self.path).query
	))['code']
        print(code)
        self.send_response(200)
        self.end_headers()
        return

server = HTTPServer(('localhost', 9999), GetHandler)
server.handle_request()
EOF` > $tmp_file_with_code &

callback_pid=$!

authorization_request="$authorization_url?response_type=code&client_id=$client_id&code_challenge=$code_challenge&code_challenge_method=S256&redirect_uri=http://localhost:9999"

case "$OSTYPE" in
  solaris*) xdg-open "$authorization_request" ;;
  darwin*)  open "$authorization_request" ;; 
  linux*)   xdg-open "$authorization_request" ;;
  bsd*)     xdg-open "$authorization_request" ;;
  msys*)    start "$authorization_request" ;;
  cygwin*)  start "$authorization_request" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

wait $callback_pid
code=$(cat $tmp_file_with_code)


curl -s \
  "$token_endpoint" \
  -d "grant_type=authorization_code&client_id=$client_id&redirect_uri=http://localhost:9999&code=$code&code_verifier=$code_verifier" | jq '.access_token' -r
