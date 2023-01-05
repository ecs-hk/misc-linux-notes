# Encryption, signatures, keys

## SSH

### Generate new keypair

```bash
# rsa
ssh-keygen -t rsa -a 100 -b 8192

# ed25519 (possibly controversial; RSA 8192 likely safer)
ssh-keygen -t ed25519
```

## Display key signature and artwork

```bash
ssh-keygen -vl -f privkey
```

## Create a public key from a private key

```bash
ssh-keygen -y -f privkey > pubkey
```

## Convert OpenSSH private key to RSA private key

```bash
# This operation overwrites the privkey file
cp privkey privkey.openssh
ssh-keygen -p -N "" -m pem -f privkey
```

## Convert public key to Windows-friendly

You're not really using Windows, right? This is for your less-fortunate acquaintances.

```bash
ssh-keygen -e -m RFC4716 -f pubkey > pubkey.otherformat
```

## openssl

### Prepare new x509 cert

```bash
# Generate private key
openssl genrsa -out server.key 2048

# Generate CSR
openssl req -new -key server.key -out server.csr

# Self-sign cert (or.. submit the CSR to your CA instead)
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.pem
```

### Inspect

```bash
# View CSR contents
openssl req -text -noout -verify -in some.csr

# View PEM cert contents
openssl x509 -text -in some.pem

# View cert on remote system
openssl s_client -host somehost.local -port 443

# View just the expiration date on remote system
openssl s_client -host data.umich.edu -port 443 | openssl x509 -noout -dates
```

### Verify

```bash
# Verify cert chain
openssl verify [-CAfile my-ca.pem] server.pem

# Verify cert matches private key (via matching digest)
openssl x509 -noout -modulus -in server.pem | openssl sha1
openssl rsa -noout -modulus -in server.key | openssl sha1
```

### Create password digests

```bash
# md5 digest
openssl passwd -1 'nice.pass'

# sha512 digest
openssl passwd -salt xxyyzz -6 'nicer.pass'
```

### Create Java keystore

```bash
# First, convert PEM file and key to PKCS12 format
# (will prompt for a new PKCS12 password)
openssl pkcs12 \
  -export \
  -in server.pem \
  -inkey server.key \
  -certfile ca-cert.pem \
  -name 'some.host.local' \
  -out server.p12
```

```bash
# Next, convert PKCS12 file to JKS format
# (will prompt for the PKCS12 password)
keytool \
  -importkeystore \
  -srckeystore server.p12 \
  -destkeystore server.jks \
  -srcstoretype PKCS12 \
  -deststoretype JKS \
  -srcalias 'some.host.local' \
  -destalias 'some.host.local'
```

```bash
# Next, if needed add additional CA certs to JKS file
# (will prompt for the PKCS12 password)
keytool \
  -keystore server.jks \
  -import \
  -alias 'someotherca' \
  -trustcacerts \
  -file some-other-ca.pem
```

### View Java keystore

```bash
keytool -list -v -keystore server.jks -storepass 'JKS password'
```

## GNUPG

### Create a new keypair

```bash
gpg --full-gen-key --expert
```

### Import public key

```bash
# Example keyserver and key ID..
gpg --keyserver pgp.mit.edu --recv-keys 89ccae8b
```

### Back up and restore a keypair

This is a cleaner approach than exporting the public key, private key, and trustdb separately

```bash
gpg --list-secret-keys --keyid-format LONG
 
# Identify the email address associated with the keypair, and then:
gpg -o secret-keep-safe.gpg --export-options backup --export-secret-keys someguy@umich.edu
 
# To restore the keypair:
gpg --import-options restore --import secret-keep-safe.gpg
 
# Set the trust level for the keypair:
gpg --edit-key someguy@umich.edu
gpg> trust
# (enter 5)
gpg> quit
```
