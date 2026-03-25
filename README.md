# lex-webhook

Generic webhook receiving and HMAC signature verification for LegionIO.

## Installation

Add to your Gemfile:

```ruby
gem 'lex-webhook'
```

## Usage

### Standalone client

```ruby
client = Legion::Extensions::Webhook::Client.new

# Receive a webhook (with optional HMAC verification)
result = client.receive(
  path:    '/hooks/github',
  headers: { 'x-hub-signature-256' => 'sha256=abc123...' },
  body:    '{"action":"push"}',
  method:  'POST',
  secret:  'my-secret'
)
# => { received: true, path: '/hooks/github', payload: { action: 'push' }, verified: true }

# Verify a signature
result = client.verify(secret: 'my-secret', signature: 'sha256=abc123...', payload: '{"action":"push"}')
# => { valid: true, algorithm: 'sha256' }

# Compute a signature
result = client.compute_signature(secret: 'my-secret', payload: '{"action":"push"}')
# => { signature: 'abc123...' }

# Endpoint registry
client.register_endpoint(path: '/hooks/github', secret: 'secret1', description: 'GitHub events')
client.list_endpoints
# => { endpoints: [{ path: '/hooks/github', secret: 'secret1', description: 'GitHub events' }] }
client.remove_endpoint(path: '/hooks/github')
```

## Runners

- **Receive** - Parse incoming webhook body, detect HMAC signature from headers, return `{ received:, path:, method:, payload:, verified: }`
- **Verify** - Verify an HMAC signature against a secret and payload; compute a signature for outgoing use
- **Endpoints** - In-memory endpoint registry: register, list, and remove webhook paths with associated secrets

Signature headers checked (in order): `x-hub-signature-256`, `x-hub-signature`, `x-signature`, `x-webhook-signature`.

## Requirements

- Ruby >= 3.4
- [LegionIO](https://github.com/LegionIO/LegionIO) framework

## Related

- [LegionIO](https://github.com/LegionIO/LegionIO) - Framework
- [lex-github](https://github.com/LegionIO/lex-github) - GitHub integration that uses webhook-style event delivery

## License

MIT
