#!/usr/bin/env python3
from statistics import median

TICK_RANGE = 990

def exact_price(tick):
    return 1e18 / (1 + 1.025 ** (TICK_RANGE / 2 - tick))

def sol_price(tick):
    LN_ONE_PLUS_DELTA = 0.024692612590371501
    def wexp(x):
        if x < 0: return int(1e36) // wexp(-x)
        ln2, quotient = 0.693147180559945309, int((x + 0.346573590279972654) / 0.693147180559945309)
        remainder = x - quotient * ln2
        return int((1 + remainder + remainder*remainder/2 + remainder*remainder*remainder/6) * 1e18) << quotient
    def div_half_down_unchecked(x, divisor): return (x + divisor // 2) // divisor
    return div_half_down_unchecked(div_half_down_unchecked(int(1e36), int(1e18) + wexp(LN_ONE_PLUS_DELTA * (TICK_RANGE // 2 - tick))), int(1e13)) * int(1e13)

# Compute all
data = [(tick, exact_price(tick), sol_price(tick)) for tick in range(TICK_RANGE + 1)]
errors = [(abs(sol - exact) / 1e18 * 10000, abs(sol - exact) / exact * 100 if exact else 0) for tick, exact, sol in data]

# Print
print(f"{'Tick':<6} {'Exact':<22} {'Solidity':<22} {'Abs(bps)':<12} {'Rel(%)':<12}")
print("-" * 70)
for (tick, exact, sol), (abs_err, rel_err) in zip(data, errors):
    print(f"{tick:<6} {exact:019.0f}    {sol:019}    {abs_err:<12.4f} {rel_err:<12.4f}")

# Stats
abs_errors, rel_errors = zip(*errors)
print(f"\nMax abs: {max(abs_errors):.4f} bps | Max rel: {max(rel_errors):.4f}%")
print(f"Avg abs: {sum(abs_errors)/len(abs_errors):.4f} bps | Avg rel: {sum(rel_errors)/len(rel_errors):.4f}%")
print(f"Med abs: {median(abs_errors):.4f} bps | Med rel: {median(rel_errors):.6f}%")
