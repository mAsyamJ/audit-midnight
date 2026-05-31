# Baseline Log

Date: 2026-05-30 (continuation refresh)

## Raw logs

- `audits/asyam/workflow/baseline_build.log` — forge build, exit 0
- `audits/asyam/workflow/baseline_tests.log` — forge test -vvv, 407 passed, 0 failed
- `audits/asyam/workflow/audit_harness_tests.log` — `test/asyam`, 20 passed, 0 failed
- `audits/asyam/workflow/finding_validation_tests.log` — `test/asyamFindings`, 14 passed, 0 failed
- `audits/asyam/workflow/invariant_tests.log` — audit invariant subset, 6 passed, 0 failed
- `audits/asyam/workflow/formal_gap_exploratory.log` — C-36 exploratory PoCs, 2 passed, 0 failed
- `audits/asyam/workflow/formal_gap_validation.log` — C-36 promoted validations, 2 passed, 0 failed

## Continuation refresh (2026-05-30)

```bash
forge build 2>&1 | tee audits/asyam/workflow/baseline_build.log
forge test -vvv 2>&1 | tee audits/asyam/workflow/baseline_tests.log
```

Result: build success; **407 tests passed**, 0 failed, 0 skipped (40 suites).

Priority queue ownership refresh:

```text
forge test --match-path 'test/asyam/**/*.sol' -vvv
20 tests passed, 0 failed, 0 skipped

forge test --match-path 'test/asyamFindings/*.sol' -vvv
14 tests passed, 0 failed, 0 skipped

forge test --match-path 'test/asyam/invariant/*.sol' -vvvv
6 tests passed, 0 failed, 0 skipped
```

Protocol-authored tests remain unchanged. Exploratory attack probes live under `test/asyam`; promoted validation regressions live under `test/asyamFindings`.

---

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
Ran 3 test suites: 8 tests passed, 0 failed, 0 skipped (8 total tests)
```

Full suite after adding `test/asyamFindings` PoCs and live-queue validation:

```text
forge test -vvv
```

Result:

```text
Ran 37 test suites in 70.05s (219.57s CPU time): 396 tests passed, 0 failed, 0 skipped (396 total tests)
```

## Build Blocker Status

The planned blocker in `test/asyamFindings/config.t.sol` was not a hard compiler failure, but it did produce a missing pragma warning and an AST metadata warning. The file is now valid Solidity and the warnings are gone.
