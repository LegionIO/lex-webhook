# Changelog

## [0.1.3] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.1.2] - 2026-03-22

### Changed
- Add runtime dependencies on legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport (TIER 1 sub-gem migration)
- Replace `require 'json'` / `::JSON.parse` in `Runners::Receive` with `Legion::JSON.load`
- Update spec_helper to load real sub-gem helpers and stub `Helpers::Lex` and actor classes

## [0.1.0] - 2026-03-21

### Added
- Initial release
- `Helpers::Signature` with HMAC compute, verify, and constant-time secure_compare
- `Runners::Receive` for webhook ingestion with optional signature verification and JSON body parsing
- `Runners::Verify` for explicit signature validation and computation
- `Runners::Endpoints` for in-memory endpoint registry (list, register, remove)
- Standalone `Client` class including all runner modules
