# RISKS: simple_probability

## Risk Register

| ID | Risk | Likelihood | Impact | Status | Mitigation |
|----|------|-----------|--------|--------|-----------|
| **RISK-001** | Numerical instability (underflow/overflow in CDF) | MEDIUM | HIGH | Open | Use log-space computation; test edge cases vs SciPy |
| **RISK-002** | API becomes too "mathy" for non-math audience | MEDIUM | MEDIUM | Open | Semantic layer + user testing in Phase 0.5 |
| **RISK-003** | Phase 1 scope creep (wants MCMC, multivariate, etc.) | HIGH | MEDIUM | Open | Clear Phase 1 boundaries; defer to Phase 2 |
| **RISK-004** | Adoption too niche (nobody uses probability lib) | MEDIUM | HIGH | Open | Early user interviews; build real-world examples |
| **RISK-005** | SCOOP concurrency introduces subtle bugs | LOW | HIGH | Open | Extensive concurrent testing; Eiffel semantics guard |
| **RISK-006** | Simple_randomizer RNG inadequate (poor distribution of seeds) | LOW | MEDIUM | Open | Use cryptographic RNG; test randomness quality |
| **RISK-007** | Performance slower than SciPy (users disappointed) | MEDIUM | MEDIUM | Open | Set expectations; optimize Phase 2; document tradeoffs |
| **RISK-008** | Contracts too strict (reject valid edge cases) | MEDIUM | LOW | Open | Relaxable contracts; error bounds documented |
| **RISK-009** | Mathematical errors in distribution implementations | LOW | HIGH | Open | Cross-verify with 3 references (SciPy, Julia, R) |
| **RISK-010** | Documentation poor (users can't figure out API) | MEDIUM | HIGH | Open | Invest in examples, tutorials, dual narratives |

---

## Technical Risks

### RISK-001: Numerical Instability

**Description:** Computing PDF/CDF for extreme values (far from mean) can cause underflow/overflow.

Example:
```eiffel
dist := create {NORMAL_DISTRIBUTION}.make(0, 1)
dist.pdf(20)  -- exp(-200) underflows to 0; should be ~1e-88
dist.cdf(-100)  -- Integration numerically unstable
```

**Likelihood:** MEDIUM (affects edge cases, not common use)

**Impact:** HIGH (users get wrong results, lose confidence in library)

**Indicators:**
- User reports "distribution returns 0 for all large values"
- Posterior doesn't converge in MCMC (numerical problems)
- Test failures on extreme values

**Mitigation:**
1. Use log-space computation internally (compute log-pdf, log-likelihood)
2. Test all distributions at extreme values vs NumPy/SciPy reference
3. Document numerical limits (e.g., "reliable for μ ± 10σ")
4. Add guards in contracts: `ensure pdf_not_zero_unless_extreme: (x - mu).abs < 10 * sigma implies Result > 0`

**Contingency:** Phase 2, switch to arbitrary-precision arithmetic (simple_decimal) for critical paths.

---

### RISK-002: API Accessibility Failure

**Description:** API becomes too "mathy" despite intentions, alienating non-math developers.

**Failure Mode:** Users read documentation, see "conjugate prior," "hyperparameter," "posterior," and assume it's not for them.

**Likelihood:** MEDIUM (semantic layer hard to get right)

**Impact:** MEDIUM (adoption stalls, library becomes niche tool for statisticians)

**Indicators:**
- User feedback: "Feels like a math library"
- Low adoption outside academic/research
- GitHub issues asking "how do I do X without learning Bayesian stats?"

**Mitigation:**
1. Conduct user testing in Phase 0.5 (show non-math developer the API, watch them use it)
2. Dual-narrative documentation (business + math)
3. "Getting Started" guide with real-world examples (disease testing, coin flips, sensor uncertainty)
4. Provide "Simple mode" API for common 80% cases
5. Hide advanced features behind subclasses (BAYESIAN_UPDATER_ADVANCED for MCMC)

**Contingency:** Phase 1.5, pivot to business-domain libraries (e.g., SENSOR_UNCERTAINTY, A_B_TESTING_UTILS) that hide probability machinery.

---

### RISK-003: Scope Creep in Phase 1

**Description:** Stakeholders demand MCMC, multivariate distributions, and advanced features in Phase 1, causing overscope and delays.

**Likelihood:** HIGH (always happens; probability is complex)

**Impact:** MEDIUM (Phase 1 extends from 3 weeks to 6-8 weeks; slips schedule)

**Indicators:**
- "Can't we just add Metropolis-Hastings while we're at it?"
- "Do we really need separate phases? Build it all now"
- Feature creep in issues/PRs

**Mitigation:**
1. **Clear Phase 1 charter:** Signed off: "Phase 1 is 5 distributions + basic Bayesian updating. MCMC is Phase 2."
2. **Reject feature requests:** Track in backlog with explicit "Phase 2" label
3. **MVP mindset:** Ship Phase 1 early (by Week 2), get feedback before Phase 2
4. **Architecture design:** Design for Phase 2 extensibility upfront (MCMC interface stubbed)

**Contingency:** If demand very high, do "Phase 1.5" (Week 3-4) for additional distributions or MCMC sketch.

---

### RISK-004: Adoption Risk (Too Niche)

**Description:** Library is mathematically sound but nobody uses it. Ends up a esoteric research tool.

**Failure Mode:** Shipped library; no uptake in commercial/industrial Eiffel projects.

**Likelihood:** MEDIUM (probability is specialized; adoption is hard)

**Impact:** HIGH (wasted engineering; ecosystem credibility damage)

**Indicators:**
- No downloads after v1.0 release
- No GitHub stars/forks
- No community contributions
- Questions: "Why should I use this vs Python?"

**Mitigation:**
1. **Early user research (Phase 0.5):** Interview 3-5 potential users: "Would you use this? What barriers?"
2. **Build real-world examples:** Not toy examples (die rolls), but production scenarios:
   - Sensor fusion with uncertainty quantification
   - A/B testing with Bayesian confidence intervals
   - Reliability prediction (failure rates)
3. **Partner with teams:** Offer library to internal projects (POS, monitoring systems) for early feedback
4. **Documentation roadshows:** Blog posts, conference talks on "Why Bayesian reasoning in Eiffel?"
5. **Clear diff from Python:** Marketing: "Type-safe probability in Eiffel, not Python"

**Contingency:** If adoption low, pivot to embedded domain (IoT, sensors, reliability) where Eiffel strength + probability combination is unique.

---

### RISK-005: SCOOP Concurrency Bugs

**Description:** SCOOP concurrency introduces subtle bugs (race conditions, deadlocks) not caught in Phase 1.

**Scenario:** Parallel MCMC chains have hidden data races in RNG seed state, causing non-deterministic bugs.

**Likelihood:** LOW (Eiffel's SCOOP prevents races by design; not like threading)

**Impact:** HIGH (concurrency bugs are hardest to debug)

**Indicators:**
- Intermittent test failures in `test_parallel_sampling`
- Different results on different hardware (race condition signature)
- Deadlock on 8-core machine but not 4-core

**Mitigation:**
1. **SCOOP semantics review:** Have experienced SCOOP developer review architecture
2. **Intensive concurrent testing:** Test with 2, 4, 8, 16 parallel chains; repeat 1000x
3. **Thread-safety contracts:** Document which features are reentrant
4. **Reproduce bugs systematically:** Use stress tools to force race conditions
5. **Simple_container lessons:** Learn from simple_container's SCOOP work

**Contingency:** Fallback to sequential sampling if parallel doesn't work (lose performance, gain correctness).

---

### RISK-006: Simple_randomizer RNG Quality

**Description:** Simple_randomizer's underlying RNG (ISE's RANDOM) has poor statistical properties or inadequate seed space.

**Failure Mode:** Pseudo-random samples fail statistical tests (KS test, chi-squared). Inference results are biased.

**Likelihood:** LOW (ISE's RANDOM is Mersenne Twister, known to be good)

**Impact:** MEDIUM (biased inference; loses user trust)

**Indicators:**
- KS test p-values suspiciously low (< 0.01) for many samples
- Sample histograms don't match expected distributions
- Bayesian inference converges to wrong posteriors

**Mitigation:**
1. **Validate simple_randomizer:** Test its RNG quality independently (diehard tests, visual inspection)
2. **Seed appropriately:** Use cryptographic seed (current time + machine state, not just clock)
3. **Document RNG quality:** "Uses Mersenne Twister; suitable for statistical, not cryptographic, use"
4. **Fallback:** If RNG inadequate, integrate cryptographic RNG in Phase 2

**Contingency:** Replace simple_randomizer with better RNG library (or use system /dev/urandom).

---

### RISK-007: Performance vs SciPy

**Description:** Eiffel version is noticeably slower than SciPy, disappointing users who compare.

**Comparison:**
- SciPy: 10,000 Normal samples in 0.5ms (highly optimized C)
- Our Eiffel: 10,000 Normal samples in 50ms (Box-Muller implementation)
- User reaction: "This is 100x slower!"

**Likelihood:** MEDIUM (Eiffel is compiled, not interpreted; but not heavily optimized yet)

**Impact:** MEDIUM (performance expectations misaligned; users might not adopt)

**Indicators:**
- Benchmark comparisons show 10-100x slower
- User feedback: "Too slow for real-time sampling"
- Profiling shows algorithm bottleneck, not Eiffel overhead

**Mitigation:**
1. **Set expectations:** Documentation: "Phase 1 prioritizes correctness, Phase 2 optimizes"
2. **Benchmark early:** Compare to SciPy Phase 1 Week 1 (know the gap early)
3. **Optimize critical paths:** Box-Muller, inverse-transform should be tight
4. **Profile ruthlessly:** Find where time is spent (algorithm vs language)
5. **Consider caching:** Precompute CDF table for common ranges (space-time tradeoff)

**Contingency:** Phase 2, implement SIMD vectorization or inline C for hot paths.

---

## Ecosystem Risks

### RISK-008: Contract Strictness Backfire

**Description:** Preconditions/postconditions too strict, rejecting valid edge cases, frustrating users.

**Example:**
```eiffel
-- Precondition: alpha > 0
-- User tries: create {BETA_DISTRIBUTION}.make(0.0001, 0.0001)
-- Error: "alpha must be > 0" [but 0.0001 IS > 0...]
-- Actually 0.0001 is fine, but contract was too aggressive
```

**Likelihood:** MEDIUM (contracts often too strict initially)

**Impact:** LOW (easy to relax in patch release)

**Mitigation:**
1. **Relaxable contracts:** Use "reasonable bounds" checks, not strict mathematics
2. **Document bounds:** "alpha ∈ (0, 1e10]; values outside this range may have numerical issues"
3. **Allow edge cases:** Don't reject 0.0001; only reject truly invalid (alpha ≤ 0)
4. **User feedback loop:** Collect complaints about contracts; relax in Phase 1.5

**Contingency:** Remove overly strict contracts; replace with warnings in documentation.

---

### RISK-009: Mathematical Errors

**Description:** Distribution implementations have subtle bugs (wrong formula, off-by-one in binomial coefficient).

**Example:** Beta distribution PDF computed incorrectly, leading to wrong Bayesian inference.

**Likelihood:** LOW (math is peer-reviewed, cross-checked)

**Impact:** HIGH (silently produces wrong results; devastating for Bayesian applications)

**Indicators:**
- Unexpected posterior beliefs
- Unit tests pass but posterior is biased
- Comparison to SciPy shows systematic error

**Mitigation:**
1. **Triple-check formulas:** Cross-reference SciPy, Julia, R, Wolfram Alpha
2. **Numerical comparison tests:** Every distribution tested against reference library
3. **Code review by statistician:** Have math expert review each distribution class
4. **Differential testing:** Generate samples from both ours + SciPy, compare histograms
5. **Publication record:** Document derivation; cite sources

**Contingency:** Phase 1, do thorough code review before ship.

---

## Resource Risks

### RISK-010: Documentation Burden

**Description:** Dual-narrative documentation (business + math) requires 2x writing effort, may not be sustainable.

**Likelihood:** MEDIUM (writing is expensive)

**Impact:** HIGH (poor documentation → users confused → adoption stalls)

**Indicators:**
- Incomplete documentation at v1.0
- GitHub issues: "How do I use this?"
- User confusion about API

**Mitigation:**
1. **Template-driven docs:** Create reusable structure for each distribution
2. **Hire technical writer:** Not just developer writing; invest in clarity
3. **Example-driven:** Show working code examples more than prose
4. **Community contributions:** Accept PRs for documentation
5. **Iterative docs:** Ship Phase 1 docs minimum viable; enhance Phase 2

**Contingency:** Focus on math-only documentation Phase 1; business layer Phase 2.

---

## Risk Mitigation Summary Table

| Phase | Action | Owner | Timeline |
|-------|--------|-------|----------|
| **Phase 0.5** | User research interviews (adoption risk) | UX lead | Week 0 |
| **Phase 1 Week 1** | SCOOP design review | Senior Eiffel dev | Day 2 |
| **Phase 1 Week 1** | Benchmark vs SciPy (performance gap) | Performance engineer | Day 3 |
| **Phase 1 Week 2** | Numerical accuracy testing | Math expert | Day 7 |
| **Phase 1 Week 3** | Code review (mathematical correctness) | Statistician | Day 15 |
| **Phase 1 Week 3** | Stress testing concurrent MCMC (100x runs) | QA | Day 18 |
| **Phase 1 Week 3** | Documentation user testing | UX lead | Day 19 |
| **Phase 2 Week 1** | Adoption metrics review | Product | Week 4 |

---

## Risk Acceptance

| Risk ID | Accept? | If Yes, Mitigation | If No, Action |
|---------|---------|---|---|
| RISK-001 (Numerical) | **YES** | Document edge cases; bounds in contracts | Not blocking |
| RISK-002 (Accessibility) | **YES** | User research; semantic layer design | Not blocking; design carefully |
| RISK-003 (Scope creep) | **YES** | Clear phase boundaries; reject features | Phase 1 gate review |
| RISK-004 (Adoption) | **YES** | Real-world examples; early partnerships | Not blocking; market later |
| RISK-005 (SCOOP bugs) | **NO** | Design review + stress testing required | Blocking; must resolve Phase 1 |
| RISK-006 (RNG quality) | **YES** | Validate ISE's RANDOM; document | Not blocking; can upgrade Phase 2 |
| RISK-007 (Performance) | **YES** | Set expectations; benchmark early | Not blocking; optimize Phase 2 |
| RISK-008 (Contracts) | **YES** | Relaxable bounds; user feedback | Not blocking; easy to patch |
| RISK-009 (Math errors) | **NO** | Triple-check; peer review required | Blocking; ship delays until verified |
| RISK-010 (Docs) | **YES** | Template-driven; example-focused | Not blocking; iterate |

