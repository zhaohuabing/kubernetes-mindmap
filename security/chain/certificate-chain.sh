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

read -p "Create private key and CSR for intermediate CA..."
echo ""
runthis "openssl req -new -nodes -keyout intermediate.key -out intermediate.csr"
echo ""

read -p "Create certificate for intermediate CA..."
echo ""
runthis "mkdir db"
runthis "touch db/index"
runthis "openssl ca -config intermediateCA.conf -days 365 -create_serial -in intermediate.csr -out intermediate.crt -extensions ca_ext -notext"
echo ""

read -p "Create private key and CSR(including public key and identity information) for Alice..."
echo ""
runthis "openssl req -new -nodes -keyout Alice.key -out Alice.csr"
echo ""

read -p "Sign Alice's certificate using intermediate CA's private key,certificate and Alice's CSR..."
echo ""
runthis "openssl x509 -req -in Alice.csr -CA intermediate.crt -CAkey intermediate.key -CAcreateserial -out Alice.crt"
echo ""

read -p "Verify Alice's certificate with Root CA's certificate..."
echo ""
runthis "openssl verify -CAfile rootCA.crt  Alice.crt"
echo ""

read -p "Verify Alice's certificate with Intermediate CA's certificate..."
echo ""
runthis "openssl verify -CAfile intermediate.crt  Alice.crt"
echo ""

read -p "Verify Alice's certificate with Root CA and Intermediate CA's certificate..."
echo ""
runthis "openssl verify -CAfile rootCA.crt -untrusted intermediate.crt Alice.crt"
echo ""

read -p "Verify Alice's certificate with certificate chain ..."
echo ""
runthis "cat rootCA.crt intermediate.crt > chain.crt"
runthis "openssl verify -CAfile chain.crt Alice.crt"
echo ""

#Clear up
rm *.crt
rm *.pem
rm *.key
rm *.srl
rm *.csr
rm -rf db
