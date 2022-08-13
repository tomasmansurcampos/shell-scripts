#!/bin/bash
echo | openssl s_client -connect $1:$2 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
