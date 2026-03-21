# Changelog

## [0.1.0] - 2026-03-21

### Added
- Initial release
- `Helpers::Signature` with HMAC compute, verify, and constant-time secure_compare
- `Runners::Receive` for webhook ingestion with optional signature verification and JSON body parsing
- `Runners::Verify` for explicit signature validation and computation
- `Runners::Endpoints` for in-memory endpoint registry (list, register, remove)
- Standalone `Client` class including all runner modules
