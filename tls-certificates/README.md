# SSL Certificate Generator for AliCloud
This is for generating the AliCloud Ingress certificate to enable the [Mutual Authentication](https://en.wikipedia.org/wiki/Mutual_authentication). The script is tested under macOS Mojave.

### Prerequisites
- Install OpenSSL, please refer to [Wiki](https://wiki.openssl.org/index.php/Compilation_and_Installation) or [GitHub](https://github.com/openssl/openssl/blob/master/INSTALL)

### Generate certificates
- Execute shell command as below:
```sh
chmod +x generate-certificate.sh
./generate-certificate.sh
```
- Follow the prompts and enter the values of:
```sh
Who is the issuer [China AFT]:
Please provide the full domain URL [example.com]: 
Who is the user? [Car Owner]:
```
- Set the password of the certificate keys and finally get a list of keys and certificates from the `ssl` folder
```sh
ca.crt		chain.crt	client.csr	client.p12	server.csr
ca.key		client.crt	client.key	server.crt	server.key
```
### Deploy the server certificates on the Ingress
- You can create a secret containing CA certificate along with the Server Certificate, that can be used for both TLS and Client Auth
```sh
$ kubectl create secret generic ca-secret --from-file=tls.crt=ssl/server.crt --from-file=tls.key=ssl/server.key --from-file=ca.crt=ssl/chain.crt
```
- Referer the yaml code below to create your Kubernetes Ingress
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    # Enable client certificate authentication
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
    # Create the secret containing the trusted ca certificates
    nginx.ingress.kubernetes.io/auth-tls-secret: "default/ca-secret"
    # Specify the verification depth in the client certificates chain
    nginx.ingress.kubernetes.io/auth-tls-verify-depth: "1"
    # Specify an error page to be redirected to verification errors
    nginx.ingress.kubernetes.io/auth-tls-error-page: "http://www.mysite.com/error-cert.html"
    # Specify if certificates are passed to upstream server
    nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "false"
  name: nginx-test
  namespace: default
spec:
  rules:
  - host: ingress.test.com
    http:
      paths:
      - backend:
          serviceName: http-svc:80
          servicePort: 80
        path: /
  tls:
  - hosts:
    - ingress.test.com
    secretName: tls-secret
```

### Test
- Whitelist yourself in case you have enabled the network policy on the LoadBalancer you're testing agaist
- Open the [jMeter Project](test/jmeter-project/tls.jmx) from jMeter 5.0
- Open Option menu on the jMeter UI, select SSL Manager
- Select the `client.p12` file then run the test
- Verify server and client certificates by executing the shell command: 
  ```sh
  openssl verify -CAfile ssl/ca.crt ssl/server.crt
  ```
  The output should be: ```ssl/server.crt: OK```
  ```sh
  openssl verify -CAfile ssl/ca.crt ssl/client.crt
  ```
  The out put should be: ```ssl/client.crt: OK```
- Enter the password of the key file and observe the response from ResultTree node