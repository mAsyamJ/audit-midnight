#!/usr/bin/env python3
import sys

TICK_RANGE = 990

def exact_price(tick):
    """Reference tick to price implementation."""
    return int(1e18 / (1 + 1.025 ** (TICK_RANGE / 2 - tick)))

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <tick>", file=sys.stderr)
        sys.exit(1)
    # ABI-encode as uint256 (32 bytes, big-endian)
    print("0x" + format(exact_price(int(sys.argv[1])), '064x'), end='')
