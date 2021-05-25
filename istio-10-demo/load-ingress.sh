GATEWAY_IP=$(kubectl get svc -n istio-ingress istio-ingressgateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

for i in {1..200}; 
  do curl -H "Host: istioinaction.io" http://$GATEWAY_IP;
  sleep 1;
done


for i in {1..200}; 
  do curl --cacert ./labs/04/certs/ca/root-ca.crt -H "Host: istioinaction.io" https://istioinaction.io --resolve istioinaction.io:443:$GATEWAY_IP
  sleep 1;
done
