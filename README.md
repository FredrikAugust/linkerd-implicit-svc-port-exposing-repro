- install just
- `just setup`
- `just test`

-------


essentially:

- creating nginx pod with `containerPort: 80`
- create svc `port: 1234` pointing to `targetPort: 80`
- this allows all ports to be accessed on the svc regardless of what the service
  defines

how this became a bug for us:

we use grpcroute from gateway api which points to the svc at a specific port.
we had the wrong port set in the client — it went to the pod on the "container
port". thus the grpc was delivered OK, but it wasn't going through the grpcroute
as that was attached to the other port.
