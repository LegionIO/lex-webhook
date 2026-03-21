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

## License

MIT
