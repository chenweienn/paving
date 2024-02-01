# Paving AWS for TAS foundation

## provide ALB HTTPS listener via AWS Secret Manager secret

```
## Prepare private key (cert-key.pem), server certificate (cert.pem) and certificate signing chain (cert-chain.pem) for configuring AWS ALB HTTPS listener
## Reference doc:
## - https://docs.vmware.com/en/VMware-Tanzu-Application-Service/3.0/tas-for-vms/security_config.html#create-a-wildcard-certificate-for-ops-manager-deployments-2
## - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html


## Create ASM secret template json

cat > web_lb_https_listener_cert.json.tpl << EOF
{
  "private_key": "",
  "certificate_body": "",
  "certificate_chain": ""
}
EOF


## Populate secret template json with your certificate

cat web_lb_https_listener_cert.json.tpl | \
  jq -c --arg key "$(cat cert-key.pem)" \
     --arg cert_body "$(cat cert.pem)" \
     --arg cert_chain "$(cat cert-chain.pem)" \
     '.private_key = $key | .certificate_body = $cert_body | .certificate_chain = $cert_chain' > web_lb_https_listener_cert.json

## Create the ASM secret

aws --profile svc-user secretsmanager create-secret \
  --region us-east-1 \
  --name /concourse/sandbox/web_lb_https_listener_cert \
  --secret-string file://web_lb_https_listener_cert.json \
  --description "server certificate for Web LB of sandbox TAS"
```

This is the related commit:
- https://github.com/chenweienn/paving/commit/fec52a03b3317717b4ab59bae81cfda8b3d33ec9
