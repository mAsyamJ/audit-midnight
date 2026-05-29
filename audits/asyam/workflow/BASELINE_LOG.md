# Baseline Log

Date: 2026-05-30

## Commands

Initial baseline:

```text
forge build
```

Result: success after a full 57-file Solc 0.8.34 compile. The run emitted a warning for `test/asyamFindings/config.t.sol` because the file contained only a comment and no pragma.

Compatibility cleanup:

- `test/asyamFindings/config.t.sol` now contains a minimal `pragma solidity ^0.8.34;` abstract config contract.
- No production `src/` code was changed.

Post-cleanup build:

```text
forge build
```

Result: success. Incremental compile of 1 file. Remaining notes are lint-level only:

- unused import in `test/BaseTest.sol`
- unused import in `src/periphery/MidnightBundles.sol`
- mixed-case `DOMAIN_SEPARATOR()` in test/vendor token helpers
- unused import in `test/EcrecoverRatifierIntegrationTest.sol`

Full test baseline:

```text
forge test -vvv
```

Result:

```text
Ran 25 test suites in 74.30s (304.92s CPU time): 373 tests passed, 0 failed, 0 skipped (373 total tests)
```

Post-PoC validation:

```text
forge test --match-path 'test/asyamFindings/*.sol' -vvv
```

Result:

```text
Ran 2 test suites: 3 tests passed, 0 failed, 0 skipped (3 total tests)
```

Full suite after adding `test/asyamFindings` PoCs:

```text
forge test -vvv
```

Result:

```text
Ran 27 test suites in 74.56s (375.04s CPU time): 376 tests passed, 0 failed, 0 skipped (376 total tests)
```

## Build Blocker Status

The planned blocker in `test/asyamFindings/config.t.sol` was not a hard compiler failure, but it did produce a missing pragma warning and an AST metadata warning. The file is now valid Solidity and the warnings are gone.
