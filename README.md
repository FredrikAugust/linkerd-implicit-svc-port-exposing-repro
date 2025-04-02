- install just
- `just setup`
- `just test`

-------


essentially:

- creating nginx pod with `containerPort: 80`
- create svc `port: 1234` pointing to `targetPort: 80`
- this allows all ports to be accessed on the svc regardless of what the service
  defines
