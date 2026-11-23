sequenceDiagram
    participant Webapp
    participant Envoy
    participant MongoDB
    participant Server

    Webapp->>Envoy: authenticateWithCredentials(mail, pass, isWeb=true)
    Envoy->>Server: Forward unchanged
    Server->>Server: Authenticate, generate JWT + sessionId
    Server->>MongoDB: Store sessionId -> JWT mapping
    Server->>Envoy: Response with sessionId only
    Envoy->>Envoy: Lua: Set cookie from sessionId
    Envoy->>Webapp: Response + httpOnly cookie

    Note over Webapp,Server: Later API calls
    Webapp->>Envoy: gRPC call + cookie
    Envoy->>MongoDB: Read JWT by sessionId
    Envoy->>Envoy: Inject Authorization header
    Envoy->>Server: gRPC with JWT