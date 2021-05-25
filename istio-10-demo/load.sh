for i in {1..200}; 
  do kubectl exec -it deploy/sleep -n default -- curl http://web-api.istioinaction:8080/;
  sleep 1;
done

