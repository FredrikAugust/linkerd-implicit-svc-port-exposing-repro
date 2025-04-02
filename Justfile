@_default:
  just --list

@_log message:
  echo "\033[1m\033[31m[*] {{message}}\033[0m"

# setup cluster
setup:
  k3d cluster create linkerd-test
  linkerd check --pre
  linkerd install --crds | kubectl apply -f -
  linkerd install | kubectl apply -f -
  linkerd check
  kubectl apply -f nginx.yaml
  kubectl wait --for=condition=ready pod --all --namespace=default
  kubectl apply -f ./tmp-shell.yaml
  kubectl wait --for=condition=ready pod --all --namespace=default
  @just _log "Svc exposes port 80 on port 1234. Port 80 is _not_ exposed in svc.

# display unexpected behaviour
test:
  kubectl apply -f ./tmp-shell.yaml
  kubectl wait --for=condition=ready pod --all --namespace=default
  @just _log "Curling on port 1234 (exposed)"
  kubectl exec -c tmp-shell pod/tmp-shell -- curl nginx.default.svc.cluster.local:1234
  @just _log "Curling on port 80 (the one 1234 targets, but not exposed)"
  kubectl exec -c tmp-shell pod/tmp-shell -- curl nginx.default.svc.cluster.local:80
  @just _log "Curling on port 4321 (random one not in svc or pod) (verbose)"
  kubectl exec -c tmp-shell pod/tmp-shell -- curl nginx.default.svc.cluster.local:4321 -v
  @just _log "Showing logs from tmp-shell proxy"
  kubectl logs tmp-shell -c linkerd-proxy
  # @just _log "Dropping you into shell for further testing:)"
  # kubectl attach -c tmp-shell po/tmp-shell -it
  kubectl delete po tmp-shell
  @just _log "Showing logs from nginx proxy"
  kubectl logs -l app=nginx -c linkerd-proxy
