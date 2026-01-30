#!/usr/bin/env python3
from statistics import median

TICK_RANGE = 990

def exact(tick):
    return 1e18 / (1 + 1.025 ** (TICK_RANGE / 2 - tick))

def solidity(tick):
    LN = 0.024692612590371501
    def wexp(x):
        if x < 0: return int(1e36) // wexp(-x)
        ln2 = 0.693147180559945309
        q = int((x + ln2 / 2) / ln2)
        r = x - q * ln2
        return int((1 + r + r*r/2 + r*r*r/6) * 1e18) << q
    def divHalfDownUnchecked(x, d): return (x + d // 2) // d
    return divHalfDownUnchecked(divHalfDownUnchecked(int(1e36), int(1e18) + wexp(LN * (TICK_RANGE // 2 - tick))), int(1e13)) * int(1e13)

# Compute all
data = [(t, exact(t), solidity(t)) for t in range(TICK_RANGE + 1)]
errors = [(abs(s-e)/1e18*10000, abs(s-e)/e*100 if e else 0) for t,e,s in data]

# Print
print(f"{'Tick':<6} {'Exact':<22} {'Solidity':<22} {'Abs(bps)':<12} {'Rel(%)':<12}")
print("-" * 70)
for (t,e,s), (ea,er) in zip(data, errors):
    print(f"{t:<6} {e:019.0f}    {s:019}    {ea:<12.4f} {er:<12.4f}")

# Stats
abs_errs, rel_errs = zip(*errors)
print(f"\nMax abs: {max(abs_errs):.4f} bps | Max rel: {max(rel_errs):.4f}%")
print(f"Avg abs: {sum(abs_errs)/len(abs_errs):.4f} bps | Avg rel: {sum(rel_errs)/len(rel_errs):.4f}%")
print(f"Med abs: {median(abs_errs):.4f} bps | Med rel: {median(rel_errs):.6f}%")
