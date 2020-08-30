# Docker Test SAML 2.0 Identity Provider (IdP)

Docker container with a plug and play SAML 2.0 Identity Provider (IdP) for development and testing.

Built with [SimpleSAMLphp](https://simplesamlphp.org). Based on the SignNow Alpine Docker Image with NGINX and PHP7 [images](https://hub.docker.com/signnow/php:7.3-alpine-1.2.0).

**Warning!**: Do not use this container in production! The container is not configured for security and contains static user credentials and SSL keys.

SimpleSAMLphp is logging to stdout on debug log level. NGINX is logs (like on the base image) error and access log to /var/log/nginx/.

The contained version of SimpleSAMLphp is 1.18.7.


## Usage

Make sure that there is a consul server running and accepting connections

```
docker run --name=testsamlidp_idp \
-p 8080:80 \
--name testidp \
-e CONSUL_HTTP_ADDR=172.17.0.1:8500 \
-e CONSUL_HTTP_TOKEN="" \
-e SERVICE_NAME=myidp \
-e SERVICE_KV_PATH="/services/myidp/" \
-e SIMPLESAMLPHP_SECRET_SALT=notsosecretsalt \
-e SIMPLESAMLPHP_ADMIN_PASSWORD=1234 \
-e SIMPLESAMLPHP_ADMIN_CONTACT_NAME=TheTestAdmin \
-e SIMPLESAMLPHP_ADMIN_CONTACT_MAIL=test@admin.com \
-d signnow/test-saml-idp
```


You can configure your own example user by running like this: 

```
curl \
  --request PUT \
  --data 'john.doe' \
  http://127.0.0.1:8500/v1/kv/application/users/john.doe/username

  curl \
  --request PUT \
  --data 'secret' \
  http://127.0.0.1:8500/v1/kv/application/users/john.doe/password

  curl \
  --request PUT \
  --data 'john@doe.com' \
  http://127.0.0.1:8500/v1/kv/application/users/john.doe/attributes/email

  curl \
  --request PUT \
  --data 'john' \
  http://127.0.0.1:8500/v1/kv/application/users/john.doe/attributes/firstname

```


You can access the SimpleSAMLphp web interface of the IdP under `http://localhost:/simplesaml`. The admin password is what you defined under SIMPLESAMLPHP_ADMIN_PASSWORD.

## Metadata Note

The consul configuration for the metadata expects from you that you define strings with an apostrophe and array with the right brackets!

Here an example of some key/values managed over terraform. Note how the strings and brackets are explicitely mentioned.

```
resource "consul_key_prefix" "metadata" {
  path_prefix = "${local.service_kv_path}/metadata/provider/"

  subkeys = {
    "name"                       = "Provider1"
    "configuration/entityid"     = "'myprovider1'"
    "configuration/metadata-set" = "'saml20-sp-remote'"

    "configuration/contacts"                 = "[0 => ['Binding' => 'administrative',]]"
    "configuration/AssertionConsumerService" = "[0 => ['Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST', 'Location' => 'https://sso.my.provider.com/sso/sp/ACS.saml2', 'index' => 0, 'isDefault' => true,]]"
    "configuration/SingleLogoutService"      = "[0 => ['Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect', 'Location' => 'https://sso.my.provider.com/sso/SLO.saml2'], 1 => ['Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST', 'Location' => 'https://sso.my.provider.com/sso/SLO.saml2'] ]"
    "configuration/attributes"               = "[0 => 'fname', 1 => 'lname', 2 => 'email', 3 => 'memberOf', 4 => 'email_address']"
    "configuration/name"                     = "['en' => 'AttributeContract']"
    "configuration/description"              = "[]"
    "configuration/validate.authnrequest"    = "false"
    "configuration/authproc"                 = "[0 => ['class' => 'saml:PersistentNameID', 'attribute' => 'email_address']]"
  }
}
```


## Test the Identity Provider (IdP)

To ensure that the IdP works you can use SimpleSAMLphp as test SP.

Download a fresh installation of [SimpleSAMLphp](https://simplesamlphp.org) and configure it for your favorite web server.

For this test the following is assumed:
- The entity id of the SP is `http://app.example.com`.
- The local development URL of the SP is `http://localhost`.
- The local development URL of the IdP is `http://localhost:8080`.

The entity id is only the name of SP and the contained URL wont be used as part of the auth mechanism.

Add the following entry to the `config/authsources.php` file of SimpleSAMLphp.
```
    'test-sp' => array(
        'saml:SP',
        'entityID' => 'http://app.example.com',
        'idp' => 'http://localhost:8080/simplesaml/saml2/idp/metadata.php',
    ),
```

Add the following entry to the `metadata/saml20-idp-remote.php` file of SimpleSAMLphp.
```
$metadata['http://localhost:8080/simplesaml/saml2/idp/metadata.php'] = array(
    'name' => array(
        'en' => 'Test IdP',
    ),
    'description' => 'Test IdP',
    'SingleSignOnService' => 'http://localhost:8080/simplesaml/saml2/idp/SSOService.php',
    'SingleLogoutService' => 'http://localhost:8080/simplesaml/saml2/idp/SingleLogoutService.php',
    'certFingerprint' => '119b9e027959cdb7c662cfd075d9e2ef384e445f',
);
```

Start the development IdP with the command above (usage) and initiate the login from the development SP under `http://localhost/simplesaml`.

Click under `Authentication` > `Test configured authentication sources` > `test-sp` and login with one of the test credentials.


## License

This project is licensed under the MIT license by Kristoph Junge.
