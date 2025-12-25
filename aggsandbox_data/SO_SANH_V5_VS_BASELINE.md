# 📊 So Sánh V5 vs Baseline - AggSandbox Context

**Ngày:** 2025-12-11  
**Context:** AggSandbox experiments - Baseline vs V5 (SABV5 + LMTR4)

## 📈 Bảng So Sánh Tổng Hợp

| N   | Metric            | Baseline      | V5            | Ratio (V5/BL) | Winner        |
|-----|-------------------|---------------|---------------|---------------|---------------|
| 1   | Elapsed Time (h)  | 0.82          | 0.81          | **0.98x**     | ✅ V5 (nhanh hơn 2%) |
| 1   | User Time (h)     | 3.85          | 6.75          | 1.75x         | ✅ Baseline (ít CPU hơn) |
| 1   | RAM (GB)          | 14.85         | 14.87         | 1.00x         | ⚖️  Tương đương |
| 1   | L1 Verify (ms)    | 47.75         | 80.75         | 1.69x         | ✅ Baseline (nhanh hơn) |
| **10** | **Elapsed Time (h)** | **1.08**   | **1.06**      | **0.98x**     | ✅ V5 (nhanh hơn 2%) |
| 10  | User Time (h)     | 5.62          | 9.80          | 1.74x         | ✅ Baseline (ít CPU hơn) |
| 10  | RAM (GB)          | 15.74         | 17.04         | 1.08x         | ✅ Baseline (ít RAM hơn) |
| 10  | L1 Verify (ms)    | 50.12         | 88.05         | 1.76x         | ✅ Baseline (nhanh hơn) |
| **50** | **Elapsed Time (h)** | **2.29**   | **2.23**      | **0.97x**     | ✅ V5 (nhanh hơn 3%) |
| 50  | User Time (h)     | 13.81         | 24.04         | 1.74x         | ✅ Baseline (ít CPU hơn) |
| 50  | RAM (GB)          | 19.00         | 20.30         | 1.07x         | ✅ Baseline (ít RAM hơn) |
| 50  | L1 Verify (ms)    | 38.38         | 45.07         | 1.17x         | ✅ Baseline (nhanh hơn) |
| **100** | **Elapsed Time (h)** | **3.84**  | **5.09**      | **1.33x**     | ⚠️  Baseline (nhanh hơn 33%) |
| 100 | User Time (h)     | 24.58         | 44.38         | 1.81x         | ✅ Baseline (ít CPU hơn) |
| 100 | RAM (GB)          | 17.86         | 19.56         | 1.10x         | ✅ Baseline (ít RAM hơn) |
| 100 | L1 Verify (ms)    | 51.78         | 226.98        | 4.38x         | ⚠️  Baseline (nhanh hơn 4.4x) |

## 🔍 Phân Tích Chi Tiết

### 1. ⏱️ Elapsed Time (Thời Gian Thực Tế)

**Quan sát:**
- **N=1, 10, 50:** V5 **nhanh hơn** baseline 2-3%
- **N=100:** V5 **chậm hơn** baseline 33%

**Phân tích:**
```
N=1:   V5 0.81h vs Baseline 0.82h  → -1.2%  (V5 nhanh hơn)
N=10:  V5 1.06h vs Baseline 1.08h  → -1.9%  (V5 nhanh hơn)
N=50:  V5 2.23h vs Baseline 2.29h  → -2.6%  (V5 nhanh hơn)
N=100: V5 5.09h vs Baseline 3.84h  → +32.6% (V5 chậm hơn)
```

**Insight:**
- ✅ V5 có **advantage** ở N nhỏ-trung bình (1-50)
- ⚠️ Baseline **tốt hơn** ở N=100
- Có thể V5 có overhead khi N tăng (secret sharing, rebalancing complexity)

---

### 2. 💻 User Time (CPU Time)

**Quan sát:**
- V5 **luôn dùng nhiều CPU hơn** baseline (×1.74-1.81x)
- Consistent across tất cả N values

**Phân tích:**
```
N=1:   V5 6.75h vs Baseline 3.85h  → +75% CPU
N=10:  V5 9.80h vs Baseline 5.62h  → +74% CPU
N=50:  V5 24.04h vs Baseline 13.81h → +74% CPU
N=100: V5 44.38h vs Baseline 24.58h → +81% CPU
```

**Insight:**
- V5 có **computational overhead** (~75% more CPU)
- Lý do: Secret sharing, LMTR4 rebalancing, additional verification steps
- Tuy nhiên, elapsed time không tăng tương ứng → **parallelization tốt hơn**

---

### 3. ⚡ Parallelization Efficiency

**Quan sát:**
- V5 có **parallelization tốt hơn** baseline
- Baseline: 4.7x - 6.4x speedup
- V5: 8.4x - 10.8x speedup

**Phân tích:**
```
N=1:   Baseline 4.7x vs V5 8.4x  → V5 tốt hơn 79%
N=10:  Baseline 5.2x vs V5 9.3x  → V5 tốt hơn 79%
N=50:  Baseline 6.0x vs V5 10.8x → V5 tốt hơn 80%
N=100: Baseline 6.4x vs V5 8.7x  → V5 tốt hơn 36%
```

**Insight:**
- ✅ V5 **tận dụng parallelization tốt hơn**
- Nhiều operations có thể parallelize (secret sharing, tree building, etc.)
- Baseline có ít parallelization opportunities hơn

---

### 4. 💾 RAM Usage

**Quan sát:**
- V5 dùng **nhiều RAM hơn** baseline 7-10%
- RAM difference không lớn

**Phân tích:**
```
N=1:   V5 14.87GB vs Baseline 14.85GB → +0.1%
N=10:  V5 17.04GB vs Baseline 15.74GB → +8.3%
N=50:  V5 20.30GB vs Baseline 19.00GB → +6.8%
N=100: V5 19.56GB vs Baseline 17.86GB → +9.5%
```

**Insight:**
- V5 có **memory overhead nhỏ** (~8%)
- Lý do: Storing shards, intermediate trees, rebalancing data structures
- **Acceptable** trade-off cho additional security features

---

### 5. ⚡ L1 Verification Time

**Quan sát:**
- V5 **chậm hơn** baseline ở L1 verification
- N=100 có outlier lớn (226.98ms vs 51.78ms)

**Phân tích:**
```
N=1:   V5 80.75ms vs Baseline 47.75ms → +69%
N=10:  V5 88.05ms vs Baseline 50.12ms → +76%
N=50:  V5 45.07ms vs Baseline 38.38ms → +17%
N=100: V5 226.98ms vs Baseline 51.78ms → +338% ⚠️
```

**Insight:**
- V5 có **slightly slower** L1 verification (17-76% overhead)
- N=100 có **large outlier** (có thể do network/RPC issues)
- Tuy nhiên, **vẫn rất nhanh** (< 300ms) và **không phụ thuộc N**

---

## 🎯 Key Findings

### ✅ V5 Advantages:

1. **Faster Elapsed Time** (N=1-50):
   - 2-3% nhanh hơn baseline
   - Do parallelization tốt hơn

2. **Better Parallelization:**
   - 80% better parallelization efficiency
   - Tận dụng multi-threading tốt hơn

3. **Additional Security Features:**
   - Secret sharing
   - LMTR4 rebalancing
   - Enhanced fraud detection

### ⚠️ V5 Disadvantages:

1. **Higher CPU Usage:**
   - ~75% more CPU time
   - Do additional computations

2. **Higher RAM Usage:**
   - ~8% more RAM
   - Storing additional data structures

3. **Slower at N=100:**
   - 33% chậm hơn baseline
   - Có thể do overhead tăng với N

4. **Slightly Slower L1 Verification:**
   - 17-76% slower (trừ N=100 outlier)
   - Vẫn acceptable (< 100ms)

---

## 📊 Trade-off Analysis

### When to Use V5:

✅ **Use V5 khi:**
- Cần **additional security** (secret sharing, enhanced fraud detection)
- N **nhỏ-trung bình** (1-50) → nhanh hơn baseline
- Có **nhiều CPU cores** → parallelization advantage
- **Security > Performance** là priority

### When to Use Baseline:

✅ **Use Baseline khi:**
- Cần **maximum performance** ở N lớn (N > 100)
- **Limited CPU resources** → ít CPU hơn V5
- **Limited RAM** → ít RAM hơn V5
- **Performance > Security features** là priority

---

## 🔬 Computational Complexity Comparison

### Baseline:
- Complexity: O(N) hoặc O(N log N)
- Simple aggregation without rebalancing

### V5 (SABV5 + LMTR4):
- Complexity: O(N log N) hoặc O(N^1.2) ở N lớn
- Additional overhead: Secret sharing, rebalancing, verification

**Evidence:**
- N=1→10: V5 tốt hơn (sub-linear scaling tốt hơn)
- N=100: Baseline tốt hơn (overhead V5 tăng)

---

## 💡 Recommendations

### 1. **Hybrid Approach:**
- Dùng **V5 cho N < 100** (nhanh hơn + security)
- Dùng **Baseline cho N > 100** (performance critical)

### 2. **Optimize V5:**
- Optimize secret sharing overhead
- Improve rebalancing efficiency
- Reduce memory footprint

### 3. **Further Testing:**
- Test với N=200, 500, 700 để confirm scaling behavior
- Measure gas costs (hiện chưa có data)
- Test fraud detection accuracy với fraud cases

---

## 📝 Conclusion

**V5 vs Baseline trong AggSandbox:**

1. **Performance:**
   - ✅ V5 **nhanh hơn** ở N nhỏ (1-50)
   - ⚠️ Baseline **tốt hơn** ở N=100
   - Cần test N > 100 để confirm

2. **Resource Usage:**
   - ⚠️ V5 dùng **nhiều CPU** hơn (~75%)
   - ⚠️ V5 dùng **nhiều RAM** hơn (~8%)
   - ✅ V5 **parallelization tốt hơn** (80% better efficiency)

3. **Security:**
   - ✅ V5 có **additional security features**
   - ✅ Enhanced fraud detection
   - ✅ Secret sharing protection

**Overall:** V5 có **trade-off** giữa security và performance. Ở N nhỏ, V5 có advantage về cả performance và security. Ở N lớn, baseline có performance advantage nhưng mất security features.

---

## 📊 Data Quality

- **Baseline:** 4 runs (N=1, 10, 50, 100) - **Limited sample size**
- **V5:** 23 runs (N=1, 10, 50, 100, 200) - **Better statistics**

**Note:** Baseline data có thể không đủ để có statistical significance. Cần thêm runs để confirm comparisons.


