#!/usr/bin/env python3
import json
import os
import random
import base64
from typing import List, Dict

# Deterministic seed for reproducibility
random.seed(42)

# Simple hex address generator
def rand_address() -> str:
    return "0x" + "".join(random.choice("0123456789abcdef") for _ in range(40))

# Generate a single DepositEventData item
# Fields follow event_data::DepositEventData schema
# - leaf_type: u8
# - origin_network: u32
# - origin_address: string (hex)
# - destination_network: u32
# - destination_address: string (hex)
# - amount: decimal string for U256
# - metadata: base64-encoded arbitrary data
# - deposit_count: u32

def gen_deposit(origin_network: int, dest_network: int, deposit_idx: int) -> Dict:
    amount = str(random.randint(10**15, 10**18))  # wei-like scale
    metadata = base64.b64encode(f"note-{origin_network}-{dest_network}-{deposit_idx}".encode()).decode()
    return {
        "leafType": 1,
        "originNetwork": origin_network,
        "originAddress": rand_address(),
        "destinationNetwork": dest_network,
        "destinationAddress": rand_address(),
        "amount": amount,
        "metadata": metadata,
        "depositCount": deposit_idx,
    }

# Generate a dataset per L2
# l2_id: NetworkId (u32)
# size: number of deposit items

def gen_l2_dataset(l2_id: int, size: int, dest_pool: List[int]) -> List[Dict]:
    out = []
    for i in range(size):
        dest = random.choice(dest_pool)
        if dest == l2_id:
            dest = (dest + 1) % len(dest_pool)
        out.append(gen_deposit(l2_id, dest, i + 1))
    return out

# Write multiple files into test-suite data folder
# Output files:
#   data/l2_{id}_withdrawals.json

def main():
    repo_root = "/home/ubuntu/thanhhuyen/agglayer"
    data_dir = os.path.join(repo_root, "crates/pessimistic-proof-test-suite/data")
    os.makedirs(data_dir, exist_ok=True)

    # Configure L2s and sizes here
    l2_ids = [0, 1, 2, 3]  # four L2s
    size_per_l2 = {
        0: 200,
        1: 200,
        2: 200,
        3: 200,
    }

    for l2 in l2_ids:
        items = gen_l2_dataset(l2, size_per_l2[l2], dest_pool=l2_ids)
        out_path = os.path.join(data_dir, f"l2_{l2}_withdrawals.json")
        with open(out_path, "w") as f:
            json.dump(items, f)
        print(f"Wrote {len(items)} items -> {out_path}")

if __name__ == "__main__":
    main()
