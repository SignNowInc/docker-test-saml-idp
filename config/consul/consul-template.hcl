template {
  source = "/app/consul-template/authsources.ctmpl"
  destination = "/app/public/simplesamlphp/config/authsources.php"
}

template {
  source = "/app/consul-template/saml20-sp-remote.ctmpl"
  destination = "/app/public/simplesamlphp/metadata/saml20-sp-remote.php"
}
