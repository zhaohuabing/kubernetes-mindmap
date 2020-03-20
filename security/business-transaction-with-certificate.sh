#!/bin/bash

runthis(){
    ## print the command to the logfile
    echo "$@"
    ## run the command and redirect it's error output
    ## to the logfile
    eval "$@"
}

read -p "Create private key and self-signed certificate for Root CA..."
echo ""
runthis "openssl req -newkey rsa:2048 -nodes -keyout rootCA.key -x509 -days 365 -out rootCA.crt"
echo ""

read -p "Create private key and CSR(including public key and identity information) for Alice..."
echo ""
runthis "openssl req -new -nodes -keyout Alice.key -out Alice.csr"
echo ""

read -p "Sign Alice's certificate using Root CA's private key,certificate and Alice's CSR..."
echo ""
runthis "openssl x509 -req -in Alice.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out Alice.crt"
echo ""

read -p "Alice signs a business contract with her private key, and send it to Bob..."
echo ""
runthis "echo "A very important business contract to Bob" > Alice-contract"
runthis "openssl dgst -sha256 -sign Alice.key -out Alice-contract-sign.sha256 Alice-contract"
echo ""

read -p "Bob verify Alice's certificate..."
echo ""
runthis "openssl verify Alice.crt"
echo ""

read -p "Bob verify Alice's certificate with Root CA's certificate..."
echo ""
runthis "openssl verify -CAfile rootCA.crt  Alice.crt"
echo ""

read -p "Bob verify Alice's signature with Alice's public key..."
echo ""
runthis "openssl x509 -pubkey -noout -in Alice.crt  > Alice-pub.key"
runthis "openssl dgst -sha256 -verify Alice-pub.key -signature Alice-contract-sign.sha256 Alice-contract"

#Clear up
rm Alice*
rm rootCA*
