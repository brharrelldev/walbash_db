# walbash_db

**A High-Performance Neuromorphic K/V Store**


## Overview
`walbash_db` is a specialized Key/Value store written in **Zig**, designed to store and retrieve synaptic weights for neuromorphic computing systems. It prioritizes data integrity, spatial locality, and raw performance.

Unlike general-purpose databases, this engine is optimized for the specific access patterns of Spiking Neural Networks (SNNs), utilizing **Morton's Ordering (Z-Curve)** to map multi-dimensional synaptic connections into linear memory for cache-efficient traversal.

## Core Technologies
*   **Language**: Zig
*   **Storage Engine**: Log-Structured Merge-Tree (LSM-Tree)
*   **Indexing**: Z-Order Curve (Morton Code) with AVX-512 optimization
*   **Durability**: Append-Only Write-Ahead Log (WAL)
*   **Architecture**: Event-Driven (inspired by NATS/Kafka)

## Project Status

**Overall Progress:** `[██░░░░░░░░] 20%`

### Roadmap
- [x] **Phase 1: Write-Ahead Log (WAL)** - *Ensuring durability.*
- [ ] **Phase 2: Z-Order Indexing** - *Mapping the synaptic space.*
- [ ] **Phase 3: Memtable** - *In-memory buffering and sorting.*
- [ ] **Phase 4: SSTables & Bloom Filters** - *Immutable on-disk storage.*
- [ ] **Phase 5: Compaction & Recovery** - *Maintenance and reliability.*

---
*Authored by Brandon Harrell (Big Homie)*
