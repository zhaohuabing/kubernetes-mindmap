#!/bin/bash

runthis(){
    ## print the command to the logfile
    echo "$@"
    ## run the command and redirect it's error output
    ## to the logfile
    eval "$@"
}

read -p "Generate a private key..."
echo ""
runthis "openssl genpkey -algorithm  RSA  -outform PEM -out private_key.pem"
runthis "cat private_key.pem"
echo ""
read -p "Generate the corresponding public key..."
runthis "openssl rsa -in private_key.pem -outform PEM -pubout -out public_key.pem"
echo ""
runthis "cat public_key.pem"

read -p  "Create a test file..."
runthis "echo 'Hello world' > plain_text"
echo ""

read -p "Encrypt plain_text with public key..." 
runthis "openssl rsautl -encrypt -inkey public_key.pem -pubin -in plain_text -out encrypted_text"
echo ""
runthis "cat encrypted_text"
echo ""

read -p "Decrypt encrypted_text with private  key..." 
runthis "openssl rsautl -decrypt -inkey private_key.pem -in encrypted_text -out decrypted_text"
echo ""
runthis "cat  decrypted_text"
