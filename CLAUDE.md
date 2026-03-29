# lex-webhook: Generic Webhook Receiver for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-core/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that receives incoming webhooks, verifies HMAC signatures, and dispatches parsed payloads. Provides an endpoint registry for managing webhook paths and secrets, and a standalone client for use without the full framework.

**GitHub**: https://github.com/LegionIO/lex-webhook
**License**: MIT
**Version**: 0.1.2

## Architecture

```
Legion::Extensions::Webhook
├── Runners/
│   ├── Receive      # receive: parse body, verify HMAC signature, return payload
│   ├── Verify       # verify: HMAC signature check; compute_signature: generate HMAC
│   └── Endpoints    # register_endpoint, list_endpoints, remove_endpoint (in-memory registry)
├── Helpers/
│   └── Signature    # HMAC-SHA256 compute and verify (supports sha256/sha1 algorithms)
└── Client           # Standalone client including all three runners
```

No explicit actors directory and no AMQP transport — this extension exposes its runners for framework subscription actors via auto-generation.

## Gem Info

| Field | Value |
|-------|-------|
| Gem name | `lex-webhook` |
| Module | `Legion::Extensions::Webhook` |
| Version | `0.1.2` |
| Ruby | `>= 3.4` |
| Runtime deps | legion sub-gems (cache, crypt, data, json, logging, settings, transport) |
| License | MIT |

## Runner Details

### Receive (`Runners::Receive`)

**`receive(path:, headers: {}, body: '', method: 'POST', secret: nil, **)`**
- Finds the HMAC signature from headers (`x-hub-signature-256`, `x-hub-signature`, `x-signature`, `x-webhook-signature`)
- If `secret:` present and signature header found, calls `Helpers::Signature.verify`
- Parses body as JSON (symbolized keys) when Content-Type includes `json`, otherwise returns raw body
- Returns `{ received: true, path:, method:, payload:, verified: }`

### Verify (`Runners::Verify`)

**`verify(secret:, signature:, payload:, algorithm: 'sha256', **)`**
- Delegates to `Helpers::Signature.verify`
- Returns `{ valid:, algorithm: }`

**`compute_signature(secret:, payload:, algorithm: 'sha256', **)`**
- Delegates to `Helpers::Signature.compute`
- Returns `{ signature: }`

### Endpoints (`Runners::Endpoints`)

In-memory registry (per-process). Not persisted to DB.

**`register_endpoint(path:, secret: nil, description: nil, **)`** — registers or updates an endpoint. Returns `{ registered:, updated:, path: }`.

**`list_endpoints(**)`** — returns `{ endpoints: [...] }`.

**`remove_endpoint(path:, **)`** — removes endpoint. Returns `{ removed:, path: }`.

## Signature Helper

`Helpers::Signature.compute(secret:, payload:, algorithm: 'sha256')` — returns `OpenSSL::HMAC.hexdigest` of `payload` using `secret`.

`Helpers::Signature.verify(secret:, signature:, payload:, algorithm: 'sha256')` — compares computed HMAC with the provided signature using `OpenSSL.fixed_length_secure_compare` for timing-safe comparison. Strips algorithm prefix (`sha256=`) if present before comparing.

## File Structure

```
lex-webhook/
├── lex-webhook.gemspec
├── Gemfile
├── lib/
│   └── legion/
│       └── extensions/
│           ├── webhook.rb                         # Entry point; requires all helpers/runners/client
│           └── webhook/
│               ├── version.rb
│               ├── client.rb                      # Client class; includes all three runners
│               ├── helpers/
│               │   └── signature.rb              # HMAC compute + verify
│               └── runners/
│                   ├── receive.rb                 # Webhook reception + body parsing
│                   ├── verify.rb                  # Signature verification + computation
│                   └── endpoints.rb              # In-memory endpoint registry
└── spec/
    ├── spec_helper.rb
    ├── client_spec.rb
    └── legion/extensions/webhook/
        ├── helpers/signature_spec.rb
        └── runners/{receive,verify,endpoints}_spec.rb
```

## Testing

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

---

**Maintained By**: Matthew Iverson (@Esity)
