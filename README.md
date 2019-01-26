# STunnel Docker Container
From the [stunnel website](https://www.stunnel.org/):
> stunnel is an open-source multi-platform application used to provide a 
> universal TLS/SSL tunneling service. stunnel can be used to provide secure 
> encrypted connections for clients or servers that do not speak TLS or SSL 
> natively

## Supported Tags and Respective Dockerfile Links
- `5.50-beta2`, `5.50`, `5`, `latest`, `stable` ([Dockerfile](https://github.com/GuyPaddock/stunnel/blob/5.50-beta2/Dockerfile))
- `5.50-beta1`, ([Dockerfile](https://github.com/GuyPaddock/stunnel/blob/5.50-beta1/Dockerfile))

## Examples
### Allow Local Insecure Clients to Connect to PKI-Secured SSL/TLS Server
These examples show how you would proxy Redis clients that do not support 
TLS/SSL to a TLS-secured Redis server on Azure (should apply similarly to AWS).

#### Using the Default Root Certificate Chain
This example uses the default trusted root CA chain from Alpine Linux:

```bash
docker run -itd \
    -e STUNNEL_CLIENT=yes \
    -e STUNNEL_SERVICE=redis \
    -e STUNNEL_ACCEPT=6379 \
    -e STUNNEL_CONNECT=myredis.redis.cache.windows.net:6380 \
    -e STUNNEL_CHECK_HOST=myredis.redis.cache.windows.net \
    -e STUNNEL_VERIFY_CHAIN=yes \
    -p 6379:6379 \
    guyelsmorepaddock/stunnel
```

#### Using a Custom Root Certificate Chain
This example shows how to provide your own trusted root certificate chain:

```bash
docker run -itd \
    -e STUNNEL_CLIENT=yes \
    -e STUNNEL_SERVICE=redis \
    -e STUNNEL_ACCEPT=6379 \
    -e STUNNEL_CONNECT=myredis.redis.cache.windows.net:6380 \
    -e STUNNEL_CHECK_HOST=myredis.redis.cache.windows.net \
    -e STUNNEL_VERIFY_CHAIN=yes \
    -p 6379:6379 \
    -v /etc/ssl/private/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro \
    guyelsmorepaddock/stunnel
```

This loads the custom certificate chain from
`/etc/ssl/private/ca-certificates.crt` on the host system into 
`/etc/ssl/certs/ca-certificates.crt` in the container, which is the default 
location the container looks for the certificates. The location within the 
container can be overridden by setting the `STUNNEL_CAFILE` environment 
variable.

### Wrap Local Server for PKI-Secured SSL/TLS Client Connections
These examples show you would secure an LDAP server running in a container 
named `directory` so that clients can connect to it over LDAPS.

#### Self-signed Certificate
```bash
docker run -itd --name ldaps --link directory:ldap \
    -e STUNNEL_SERVICE=ldaps \
    -e STUNNEL_ACCEPT=636 \
    -e STUNNEL_CONNECT=ldap:389 \
    -p 636:636 \
    guyelsmorepaddock/stunnel
```

This will automatically generate a self-signed certificate that expires in 365 
days.

#### Custom Certificate
```bash
docker run -itd --name ldaps --link directory:ldap \
    -e STUNNEL_SERVICE=ldaps \
    -e STUNNEL_ACCEPT=636 \
    -e STUNNEL_CONNECT=ldap:389 \
    -p 636:636 \
    -v /etc/ssl/private/server.key:/etc/stunnel/stunnel.key:ro \
    -v /etc/ssl/private/server.crt:/etc/stunnel/stunnel.pem:ro \
    guyelsmorepaddock/stunnel
```

This accomplishes the following:
- Loads the server private key from `/etc/ssl/private/server.key` on the host 
system into `/etc/stunnel/stunnel.key` in the container, which is the default 
location the container looks for the key. The location within the container can 
be overridden by setting the `STUNNEL_KEY` environment variable.

- Loads the server certificate from `/etc/ssl/private/server.crt` on the host 
system into `/etc/stunnel/stunnel.pem` in the container, which is the default 
location the container looks for the certificate. The location within the 
container can be overridden by setting the `STUNNEL_CRT` environment variable.

### Allow Local Insecure Clients to Connect to PSK-Secured Server
This example demonstrates how to connect to a service that as been secured with 
a pre-shared key (PSK):

```bash
docker run -itd \
    -e STUNNEL_CLIENT=yes \
    -e STUNNEL_SERVICE=myservice \
    -e STUNNEL_CONNECT=myservice.net:1234 \
    -e STUNNEL_ACCEPT=6379 \
    -e STUNNEL_PSK=/etc/stunnel/stunnel.psk \
    -v /etc/ssl/private/server.psk:/etc/stunnel/stunnel.psk:ro \
    -p 6379:6379 \
    guyelsmorepaddock/stunnel
```

### Wrap Local Server for PSK-Secured Client Connections
This example demonstrates how to secure a service with a pre-shared key (PSK):

```bash
docker run -itd \
    -e STUNNEL_SERVICE=myservice \
    -e STUNNEL_CONNECT=myservice.net:1234 \
    -e STUNNEL_ACCEPT=6379 \
    -e STUNNEL_PSK=/etc/stunnel/stunnel.psk \
    -v /etc/ssl/private/server.psk:/etc/stunnel/stunnel.psk:ro \
    -p 6379:6379 \
    guyelsmorepaddock/stunnel
```

## Copyright Notice
>The [MIT License](LICENSE.txt) ([MIT](https://opensource.org/licenses/MIT))
>
> Copyright &copy; 2015-2017 [Jacob Blain Christen](https://github.com/dweomer)  
> Portions Copyright &copy; 2017-2018, Emmanuel Frecon  
> Portions Copyright &copy; 2018, Frederik Weber  
> Portions Copyright &copy; 2018, "The Goofball (goofball222)"  
> Portions Copyright &copy; 2019, Inveniem  
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of
> this software and associated documentation files (the "Software"), to deal in
> the Software without restriction, including without limitation the rights to
> use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
> the Software, and to permit persons to whom the Software is furnished to do so,
> subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
> FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
> COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
> IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
