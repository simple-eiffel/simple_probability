# Implementation Tasks: simple_probability Phase 1

**Project**: simple_probability
**Phase**: Phase 3 (Task Decomposition)
**Date**: 2026-01-27
**Status**: READY FOR APPROVAL

---

## Overview

Phase 1 MVP: Ship 4 high-quality probability distributions (Normal, Uniform, Binomial, Exponential) with 50+ unit tests, deferred Beta to Phase 1.5.

**Total Estimated Effort**: 57 hours across 3 weeks (with 1.5 days/week slack buffer)
**Critical Path**: Wichura Standard Normal CDF (3 hours - single point of failure)
**Pre-Work Required**: 7 hours (Week 0) before Phase 4 implementation starts

---

## Week 0: Pre-Implementation (MANDATORY - 7 hours)

### TASK-W0-1: Implement Wichura Standard Normal CDF
**Files**: `src/simple_probability.e`
**Features**: `standard_normal_cdf(x: REAL_64): REAL_64`

**Status**: BLOCKING - Must complete before Phase 4
**Effort**: 3 hours
**Complexity**: MEDIUM (well-documented algorithm)

**Acceptance Criteria**
- [ ] Implements Wichura rational approximation for Φ(x)
- [ ] Validated against SciPy scipy.stats.norm.cdf reference
- [ ] Accuracy: ±1e-6 for x ∈ [-6, 6], ±1e-2 for extremes
- [ ] Handles edge cases: x = ±∞, x very large/small
- [ ] No NaN or Infinity output for valid inputs
- [ ] Postcondition: result ∈ [0, 1] and monotonic

**Implementation Notes**
From approach.md: "Rational approximation (Wichura): ±7 decimal places, fast"
- Algorithm: Polynomial rational approximation with split domains
- Reference: Abramowitz & Stegun, or Hart's handbook
- Alternative if time: Use simple_math.erf if available (erf-based formula)

**Dependencies**
- simple_math: exp, sqrt (for computations)
- Test: SciPy reference curve (provide as fixture)

**Risk**: Single point of failure for Normal distribution. Inaccuracy cascades to icdf.

---

### TASK-W0-2: Define Domain Validation Helper Methods
**Files**: `src/distribution.e`, all distribution concrete classes
**Features**: `is_valid_for_pdf(x: REAL_64): BOOLEAN`, `is_valid_for_cdf(x: REAL_64): BOOLEAN`

**Status**: BLOCKING - Preconditions reference these
**Effort**: 1 hour (10 mins per distribution)
**Complexity**: LOW (straightforward domain checks)

**Acceptance Criteria**
- [ ] NORMAL_DISTRIBUTION: is_valid_for_pdf always returns True (unbounded)
- [ ] UNIFORM_DISTRIBUTION: is_valid_for_pdf returns (x >= a and x <= b)
- [ ] EXPONENTIAL_DISTRIBUTION: is_valid_for_pdf returns (x >= 0)
- [ ] BINOMIAL_DISTRIBUTION: is_valid_for_pdf returns (x >= 0 and x <= n and is_integer(x))
- [ ] All classes: cdf accepts slightly wider domain (includes negative infinity)
- [ ] Methods compile and are called in preconditions

**Implementation Notes**
- DISTRIBUTION.pdf requires: `x_valid: is_valid_for_pdf(x)`
- These helpers are currently deferred but not implemented in any concrete class
- Simple implementations (2-3 lines per class)

**Dependencies**
- None (pure domain checks)

---

### TASK-W0-3: Add Edge Case Guards to Prevent Crashes
**Files**: `src/normal_distribution.e`, `src/exponential_distribution.e`, `src/binomial_distribution.e`, `src/beta_distribution.e`
**Features**: Preconditions and guards in sample/pdf methods

**Status**: BLOCKING - Prevents crashes on degenerate inputs
**Effort**: 1 hour
**Complexity**: LOW (add guards/preconditions)

**Acceptance Criteria**
- [ ] NORMAL_DISTRIBUTION.sample: Guard u1 > 0 (avoid ln(0) singularity in Box-Muller)
- [ ] EXPONENTIAL_DISTRIBUTION: Precondition `rate < 100000000.0` (avoid underflow)
- [ ] BINOMIAL_DISTRIBUTION: Precondition `n < 10000` (avoid O(n) timeout)
- [ ] BETA_DISTRIBUTION: Precondition `alpha > 0.1 and beta > 0.1` (avoid Gamma singularity)
- [ ] All guards documented in contracts

**Implementation Notes**
From Phase 2 Grok review: 8 edge cases identified, all preventable via preconditions
- Box-Muller: u1 > 0 guard prevents ln(0) crash
- Exponential: rate cap prevents underflow in exp(-rate*x)
- Binomial: n cap prevents O(n) loop timeout
- Beta: parameter bounds prevent Gamma(α→0) singularity

**Dependencies**
- None (precondition tightening only)

---

### TASK-W0-4: Verify External Dependencies
**Files**: None (verification task)
**Features**: Integration with simple_randomizer and simple_math

**Status**: BLOCKING - Missing functions stop Week 1 start
**Effort**: 2 hours
**Complexity**: LOW (checklist verification)

**Acceptance Criteria**
- [ ] simple_randomizer.random_real_in_range(0.0, 1.0) returns (0, 1) not [0, 1]
- [ ] simple_randomizer.set_seed(s: INTEGER) is deterministic and thread-safe
- [ ] simple_math provides: exp(x), ln(x), sqrt(x), sin(x), cos(x), pi
- [ ] simple_math.ln(0) returns -∞ or sensible value, not error
- [ ] simple_math.sqrt(-1) returns NaN or sensible value, not error
- [ ] simple_math.make is SCOOP thread-safe (no shared state)
- [ ] Document any gaps in separate BLOCKERS.md

**Implementation Notes**
Verification checklist from Phase 2 Gemini review:
- If gaps found: Stop, create workaround OR defer to Phase 2
- If all verified: Proceed to Week 1 with confidence

**Dependencies**
- simple_randomizer (Phase 1 blocker)
- simple_math (Phase 1 blocker)

---

## Week 1: Critical Path (19 hours)

### TASK-W1-1: NORMAL_DISTRIBUTION Complete Implementation
**Files**: `src/normal_distribution.e`
**Features**: `make(mu, sigma)`, `pdf(x)`, `cdf(x)`, `icdf(p)`, `sample()`, `mean`, `variance`, `set_seed(s)`

**Status**: CRITICAL PATH
**Effort**: 5 hours
**Complexity**: MEDIUM (depends on Wichura CDF from W0-1)

**Acceptance Criteria**
- [ ] Constructor validates σ > 0 and σ < 10^10
- [ ] pdf(x) = (1/(σ√(2π))) * exp(-(x-μ)²/(2σ²))
- [ ] cdf(x) = standard_normal_cdf((x-μ)/σ)
- [ ] icdf(p) via inverse error function or Newton-Raphson on cdf
- [ ] sample() uses Box-Muller: θ = 2π*u2, r = √(-2ln(u1))
- [ ] mean returns μ
- [ ] variance returns σ²
- [ ] set_seed deterministically seeds internal randomizer
- [ ] All postconditions verified (result in domain, finite, etc.)
- [ ] 12 unit tests pass (9 functional + 3 statistical)
- [ ] pdf/cdf ±1e-6 accuracy vs SciPy reference

**Implementation Notes**
From approach.md:
- pdf: Standard formula (straightforward)
- cdf: Calls standard_normal_cdf (from W0-1)
- icdf: Requires accurate inverse (Newton-Raphson on cdf, or Hart's algorithm)
- sample: Box-Muller transform (O(1), uses 2 uniform random values)

**Dependencies**
- Blocks: TASK-W1-4 (Test Suite - needs Normal tests)
- Requires: TASK-W0-1 (standard_normal_cdf), TASK-W0-2 (is_valid_for_pdf/cdf), TASK-W0-3 (edge guards)
- Requires: simple_math (exp, sqrt, pi), simple_randomizer

**Risk**: Wichura CDF inaccuracy cascades to icdf tests. Pre-validation (W0-1) critical.

---

### TASK-W1-2: UNIFORM_DISTRIBUTION Complete Implementation
**Files**: `src/uniform_distribution.e`
**Features**: `make(a, b)`, `pdf(x)`, `cdf(x)`, `icdf(p)`, `sample()`, `mean`, `variance`, `set_seed(s)`

**Status**: LOW COMPLEXITY, QUICK WIN
**Effort**: 3 hours
**Complexity**: LOW (analytical formulas)

**Acceptance Criteria**
- [ ] Constructor validates a < b
- [ ] pdf(x) = 1/(b-a) if x ∈ [a,b], else 0
- [ ] cdf(x) = (x-a)/(b-a) if x ∈ [a,b]
- [ ] icdf(p) = a + p*(b-a)
- [ ] sample() = a + u*(b-a) where u ~ U(0,1)
- [ ] mean returns (a+b)/2
- [ ] variance returns (b-a)²/12
- [ ] set_seed deterministically seeds randomizer
- [ ] All postconditions verified
- [ ] 8 unit tests pass
- [ ] Analytical formulas verified

**Implementation Notes**
From approach.md: "Analytical formulas, straightforward"
- No transcendental functions (exp, ln)
- Simple arithmetic: division, multiplication

**Dependencies**
- Blocks: TASK-W1-4 (Test Suite)
- Requires: TASK-W0-2 (is_valid_for_pdf/cdf)
- Requires: simple_randomizer

---

### TASK-W1-3: BINOMIAL_DISTRIBUTION Complete Implementation
**Files**: `src/binomial_distribution.e`
**Features**: `make(n, p)`, `pmf(k)`, `pdf(x)` [wrapper], `cdf(x)`, `icdf(p)`, `sample()`, `mean`, `variance`, `set_seed(s)`, `binomial_coefficient(n, k)`

**Status**: DISCRETE, MEDIUM COMPLEXITY
**Effort**: 3 hours
**Complexity**: MEDIUM (overflow risk, Bernoulli loop)

**Acceptance Criteria**
- [ ] Constructor validates n > 0, n < 10000, p ∈ [0,1]
- [ ] pmf(k) = C(n,k) * p^k * (1-p)^(n-k)
- [ ] binomial_coefficient(n, k) uses iterative formula or log-based computation
- [ ] No overflow for n < 200 (cap checked in precondition)
- [ ] pdf(x) returns pmf(floor(x)) for consistency
- [ ] cdf(x) = sum of pmf from 0 to floor(x)
- [ ] icdf(p) finds smallest k where cdf(k) >= p
- [ ] sample() uses Bernoulli trial loop (O(n), acceptable for n < 10000)
- [ ] mean returns n*p
- [ ] variance returns n*p*(1-p)
- [ ] set_seed deterministically seeds randomizer
- [ ] All postconditions verified
- [ ] 10 unit tests pass
- [ ] chi-squared distribution test passes

**Implementation Notes**
From approach.md: "C(n,k) * p^k * (1-p)^(n-k) using binomial_coefficient"
- Binomial coefficient: Use iterative multiplication or log-based (avoid direct factorial)
- Degenerate cases: p=0 → pmf(0)=1, pmf(k>0)=0; p=1 → pmf(n)=1
- Sample: Count successes in n Bernoulli trials (simple loop)

**Dependencies**
- Blocks: TASK-W1-4 (Test Suite)
- Requires: TASK-W0-2 (is_valid_for_pdf/cdf), TASK-W0-3 (n < 10000 guard)
- Requires: simple_randomizer

---

### TASK-W1-4: Test Suite - Unit Tests for Phase 1 Distributions
**Files**: `test/test_normal_distribution.e`, `test/test_uniform_distribution.e`, `test/test_binomial_distribution.e`

**Status**: PARALLEL WITH IMPLEMENTATIONS
**Effort**: 8 hours
**Complexity**: MEDIUM (comprehensive test coverage)

**Acceptance Criteria**
- [ ] 9 Normal distribution tests pass
  - [ ] Creation and parameter validation
  - [ ] pdf positivity and normalization (integral ≈ 1)
  - [ ] cdf bounds [0,1] and monotonicity
  - [ ] icdf(cdf(x)) ≈ x (within 1e-6)
  - [ ] sample domain check
  - [ ] mean and variance correct
  - [ ] seeding reproducibility
  - [ ] edge cases (very large/small x)
  - [ ] SciPy reference comparison
- [ ] 8 Uniform distribution tests pass
  - [ ] pdf equals 1/(b-a) in domain
  - [ ] cdf linearity
  - [ ] icdf inverse property
  - [ ] sample in [a,b]
  - [ ] mean and variance
  - [ ] boundary handling
  - [ ] seeding
  - [ ] SciPy reference
- [ ] 10 Binomial distribution tests pass
  - [ ] pmf non-negative, sums to 1
  - [ ] cdf monotonicity
  - [ ] icdf inverse property
  - [ ] sample in [0,n]
  - [ ] mean = np, variance = np(1-p)
  - [ ] edge cases (p=0, p=1, n=1)
  - [ ] overflow protection (n < 200)
  - [ ] chi-squared test passes
  - [ ] seeding
  - [ ] SciPy reference
- [ ] **TOTAL**: 27 unit tests pass
- [ ] Code coverage: 90%+ for implemented features

**Implementation Notes**
- Use simple_testing framework (EQA_TEST_SET)
- For each distribution:
  - Unit tests: Creation, pdf/cdf/icdf properties, sampling, statistics
  - Reference tests: Compare vs SciPy using hardcoded reference values
  - Edge case tests: Boundary values, special parameters
- Tests should verify postconditions from contracts

**Dependencies**
- Requires: TASK-W1-1, W1-2, W1-3 (implementations to test)
- Requires: simple_testing framework

**Notes**: Write tests in parallel with implementations (TDD style), not after.

---

## Week 2: Consolidation (23 hours)

### TASK-W2-1: EXPONENTIAL_DISTRIBUTION Complete Implementation
**Files**: `src/exponential_distribution.e`
**Features**: `make(lambda)`, `pdf(x)`, `cdf(x)`, `icdf(p)`, `sample()`, `mean`, `variance`, `set_seed(s)`

**Status**: MEDIUM COMPLEXITY, QUICK FOLLOW-UP
**Effort**: 2 hours
**Complexity**: LOW (analytical formulas with transcendental functions)

**Acceptance Criteria**
- [ ] Constructor validates rate > 0, rate < 10^8 (prevent underflow)
- [ ] pdf(x) = rate * exp(-rate*x) for x ≥ 0
- [ ] cdf(x) = 1 - exp(-rate*x)
- [ ] icdf(p) = -ln(1-p) / rate
- [ ] sample() = -ln(u) / rate where u ~ U(0,1)
- [ ] mean returns 1/rate
- [ ] variance returns 1/rate²
- [ ] set_seed deterministically seeds randomizer
- [ ] All postconditions verified
- [ ] 8 unit tests pass
- [ ] Moment matching verified

**Implementation Notes**
From approach.md: "λ * exp(-λ*x), inverse transform sampling"
- Requires: simple_math.ln, simple_math.exp
- Degenerate case: rate → ∞ results in Dirac delta at 0

**Dependencies**
- Blocks: TASK-W2-4 (Factories)
- Requires: TASK-W0-2 (is_valid_for_pdf/cdf), TASK-W0-3 (rate < 10^8 guard)
- Requires: simple_math (ln, exp), simple_randomizer

---

### TASK-W2-2: SIMPLE_PROBABILITY Facade - Factory Methods
**Files**: `src/simple_probability.e`
**Features**: `new_normal(mu, sigma): NORMAL_DISTRIBUTION`, `new_uniform(a, b): UNIFORM_DISTRIBUTION`, `new_binomial(n, p): BINOMIAL_DISTRIBUTION`, `new_exponential(lambda): EXPONENTIAL_DISTRIBUTION`

**Status**: STRAIGHTFORWARD
**Effort**: 1 hour
**Complexity**: LOW (simple delegation)

**Acceptance Criteria**
- [ ] new_normal(mu, sigma) creates and returns NORMAL_DISTRIBUTION
- [ ] new_uniform(a, b) creates and returns UNIFORM_DISTRIBUTION
- [ ] new_binomial(n, p) creates and returns BINOMIAL_DISTRIBUTION
- [ ] new_exponential(lambda) creates and returns EXPONENTIAL_DISTRIBUTION
- [ ] All factories validate parameters (delegate to constructors)
- [ ] 5 integration tests pass (each factory)
- [ ] SCOOP-compatible (each factory returns separate object)

**Implementation Notes**
From approach.md: "Factory methods for all distributions"
- Pattern: Facade delegates to constructors
- No caching (each call creates new instance)
- Proper SCOOP semantics (no shared state)

**Dependencies**
- Requires: TASK-W1-1, W1-2, W1-3, W2-1 (all distributions)

---

### TASK-W2-3: Test Suite Expansion - Exponential + Integration Tests
**Files**: `test/test_exponential_distribution.e`, `test/test_simple_probability.e`

**Status**: PARALLEL WITH W2-1, W2-2
**Effort**: 10 hours
**Complexity**: MEDIUM

**Acceptance Criteria**
- [ ] 8 Exponential distribution tests pass
  - [ ] pdf definition and bounds
  - [ ] cdf monotonicity [0,1]
  - [ ] icdf inverse property
  - [ ] sample domain [0,∞)
  - [ ] mean = 1/rate, variance = 1/rate²
  - [ ] memoryless property (optional)
  - [ ] seeding
  - [ ] SciPy reference
- [ ] 5 SIMPLE_PROBABILITY factory tests pass
  - [ ] new_normal creates valid distribution
  - [ ] new_uniform creates valid distribution
  - [ ] new_binomial creates valid distribution
  - [ ] new_exponential creates valid distribution
  - [ ] All factories with valid and invalid parameters
- [ ] **TOTAL**: 40+ unit tests pass (13 new + 27 from Week 1)
- [ ] Code coverage: 90%+

**Implementation Notes**
- Follow same pattern as W1-4 (unit tests + reference tests)
- Factory tests: Verify creation, basic operations, error handling

**Dependencies**
- Requires: TASK-W2-1 (Exponential), TASK-W2-2 (Factories)

---

### TASK-W2-4: Iteration & Debugging (Slack Time)
**Files**: All
**Features**: Bug fixes, contract refinement, documentation

**Status**: BUFFER
**Effort**: 10 hours (SLACK - do not plan to use)
**Complexity**: VARIABLE

**Acceptance Criteria**
- [ ] All 40+ tests pass
- [ ] No compilation warnings
- [ ] Postconditions verified by tests
- [ ] Contract violations caught by test suite

**Implementation Notes**
This is **emergency buffer** for:
- Unexpected test failures
- Numerical accuracy issues
- Contract refinements
- Debugging integration issues

**DO NOT PLAN TO USE THIS TIME.** It's a safety net. If Week 2 completes cleanly, move directly to Week 3.

**Dependencies**
- Requires: TASK-W1-4, W2-3 (test suite complete)

---

## Week 3: Polish & Release (15 hours)

### TASK-W3-1: BAYESIAN_UPDATER Implementation (Optional for Phase 1.0)
**Files**: `src/bayesian_updater.e`
**Features**: `update_conjugate_beta_binomial(prior_alpha, prior_beta, successes, trials): TUPLE[alpha, beta]`, `credible_interval_from_posterior(alpha, beta, confidence): TUPLE[lower, upper]`

**Status**: DEFERRED TO PHASE 1.5 (Beta.cdf not ready)
**Effort**: 4 hours (deferred)
**Complexity**: MEDIUM (conjugacy formula)

**Acceptance Criteria**
- [ ] ✗ DEFERRED - Beta distribution not complete in Phase 1
- [ ] Will implement in Phase 1.5 when Beta.cdf available

**Implementation Notes**
Depends on Beta.cdf, which is deferred to Phase 1.5 per Phase 2 review.
For Phase 1.0: Ship without Bayesian inference, add in v1.1.0

**Dependencies**
- Blocks: Phase 1.5
- Requires: BETA_DISTRIBUTION (deferred)

---

### TASK-W3-2: Documentation
**Files**: `README.md`, `docs/api.md`, examples

**Status**: PHASE 1 FINAL
**Effort**: 5 hours
**Complexity**: LOW

**Acceptance Criteria**
- [ ] README.md: Overview, quick start, basic examples
- [ ] API documentation: Feature descriptions, parameter validation
- [ ] Examples: Normal sampling, Uniform sampling, Binomial pmf
- [ ] Accuracy documentation: ±1e-6 vs SciPy, sampling validation
- [ ] Dependencies documented: simple_randomizer, simple_math versions
- [ ] SCOOP safety documented: No shared state, concurrent sampling safe

**Implementation Notes**
- Reference: simple_* ecosystem documentation standards
- Include accuracy targets and statistical validation results
- Document Beta deferral and Phase 1.5 plan

**Dependencies**
- Requires: TASK-W1-1 through W2-3 (implementations complete)

---

### TASK-W3-3: Final Bug Fixes & Performance Validation
**Files**: All
**Features**: Testing, refinement, performance checks

**Status**: PHASE 1 FINAL
**Effort**: 5 hours
**Complexity**: VARIABLE

**Acceptance Criteria**
- [ ] All 40+ tests pass without warnings
- [ ] pdf/cdf accuracy verified (±1e-6)
- [ ] Sampling performance: <1ms per sample
- [ ] pdf/cdf performance: <100μs per call
- [ ] No Eiffel compiler warnings
- [ ] Postconditions verified
- [ ] SCOOP compatibility checked

**Implementation Notes**
- Run test suite multiple times
- Profile sampling performance if slow
- Verify accuracy against SciPy for all distributions
- Check for edge cases missed by tests

**Dependencies**
- Requires: TASK-W1-4, W2-3, W2-4 (test suite)

---

### TASK-W3-4: Release v1.0.0
**Files**: Git tags, ECF config, GitHub release

**Status**: PHASE 1 COMPLETION
**Effort**: 2 hours
**Complexity**: LOW

**Acceptance Criteria**
- [ ] All tests passing (40+ tests)
- [ ] No compilation warnings
- [ ] Git tag: v1.0.0
- [ ] GitHub release created with notes
- [ ] Commit history clean and descriptive
- [ ] .ecf configured for library target + test target

**Implementation Notes**
- Tag message: "v1.0.0: Normal, Uniform, Binomial, Exponential distributions with 40+ tests"
- Release notes: Features, known limitations (Beta deferred), next steps (Phase 1.5)

**Dependencies**
- Requires: TASK-W3-1, W3-2, W3-3 (all work complete)

---

## BETA_DISTRIBUTION & Phase 1.5 (DEFERRED)

### TASK-PHASE-1.5-1: BETA_DISTRIBUTION Complete Implementation
**Files**: `src/beta_distribution.e`
**Features**: `make(alpha, beta)`, `pdf(x)`, `cdf(x)`, `icdf(p)`, `sample()`, `mean`, `variance`, `set_seed(s)`, `beta_function(a, b)`, `regularized_incomplete_beta(a, b, x)`

**Status**: PHASE 1.5 (NOT Phase 1)
**Effort**: 6 hours
**Complexity**: HIGH (numerical integration, Gamma function)

**Acceptance Criteria** (When Phase 1.5 starts)
- [ ] Constructor validates α > 0.1, β > 0.1 (singularity protection)
- [ ] pdf(x) = [x^(α-1) * (1-x)^(β-1)] / B(α,β)
- [ ] cdf(x) = regularized incomplete beta I(x; α, β)
- [ ] icdf(p) via Newton-Raphson on cdf
- [ ] sample() uses Gamma-ratio: Gamma(α) / (Gamma(α) + Gamma(β))
- [ ] beta_function(a, b) = Γ(a)*Γ(b)/Γ(a+b) or log-based
- [ ] regularized_incomplete_beta via numerical integration
- [ ] mean returns α/(α+β)
- [ ] variance returns αβ/((α+β)²(α+β+1))
- [ ] All postconditions verified
- [ ] 10+ tests pass
- [ ] Beta-Binomial conjugacy validated

**Implementation Notes**
From approach.md: "High complexity, Bayesian critical"
- Requires: simple_math.gamma function
- Requires: Numerical integration (Simpson's rule) or series approximation
- Alternative: Use continued fraction for incomplete beta (more stable)

**Dependencies**
- Requires: simple_math (gamma, integration)
- Blocks: BAYESIAN_UPDATER (Phase 1.5)

---

## TASK SUMMARY

| Task | Week | Effort | Dependency Chain | Status |
|------|------|--------|-------------------|--------|
| **W0-1**: Wichura CDF | 0 | 3h | None (blocker) | CRITICAL |
| **W0-2**: Domain helpers | 0 | 1h | None (blocker) | CRITICAL |
| **W0-3**: Edge guards | 0 | 1h | None (blocker) | CRITICAL |
| **W0-4**: Verify deps | 0 | 2h | None (blocker) | CRITICAL |
| **W1-1**: Normal | 1 | 5h | W0-1, W0-2, W0-3 | CRITICAL PATH |
| **W1-2**: Uniform | 1 | 3h | W0-2 | ON CRITICAL PATH |
| **W1-3**: Binomial | 1 | 3h | W0-2, W0-3 | ON CRITICAL PATH |
| **W1-4**: Tests | 1 | 8h | W1-1, W1-2, W1-3 | PARALLEL |
| **W2-1**: Exponential | 2 | 2h | W0-2, W0-3 | NORMAL |
| **W2-2**: Factories | 2 | 1h | W1-1, W1-2, W1-3, W2-1 | NORMAL |
| **W2-3**: Tests | 2 | 10h | W2-1, W2-2 | PARALLEL |
| **W2-4**: Debug/slack | 2 | 10h | (emergency buffer) | SLACK |
| **W3-1**: Bayesian | 3 | 0h | (deferred Phase 1.5) | DEFERRED |
| **W3-2**: Docs | 3 | 5h | All impls complete | FINAL |
| **W3-3**: Bug fixes | 3 | 5h | W2-3, W2-4 | FINAL |
| **W3-4**: Release | 3 | 2h | W3-2, W3-3 | FINAL |
| **PHASE-1.5-1**: Beta | 1.5 | 6h | simple_math.gamma | DEFERRED |

**CRITICAL PATH**: W0-1 (3h) → W1-1 (5h) → W1-4 (8h) → W2-3/4 (10h) → W3 (12h) = **38 hours core work**

**TOTAL PHASE 1**: 57 hours (includes 10h slack in Week 2)

---

## Quality Gates (MUST PASS)

Before Phase 4 implementation starts:

| Gate | Criterion | Evidence |
|------|-----------|----------|
| **G1: Contracts** | All critical issues fixed (W0) | Phase 2 issues resolved |
| **G2: Dependencies** | simple_math/randomizer verified (W0-4) | Dependency verification passed |
| **G3: Accuracy** | Wichura CDF ±1e-6 validated (W0-1) | Test vs SciPy fixture |
| **G4: Unit Tests** | 40+ tests passing (W1-4, W2-3) | Test suite output |
| **G5: SCOOP** | No data races, concurrent sampling OK | SCOOP tests (Phase 5) |
| **G6: Compilation** | Zero warnings | ec.sh -batch clean compile |

---

## Risk & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Wichura CDF inaccuracy | MEDIUM | CRITICAL | Pre-validate W0-1 vs SciPy |
| Missing simple_math functions | MEDIUM | MAJOR | Verify dependencies W0-4 early |
| Box-Muller crashes | MEDIUM | CRITICAL | Add u1 > 0 guard (W0-3) |
| Binomial overflow | HIGH | MAJOR | Cap n < 200 in precondition (W0-3) |
| Tests fail mid-week | MEDIUM | MAJOR | 10h slack buffer in W2-4 |
| Beta blocks Phase 1.0 | LOW | MAJOR | Already deferred to Phase 1.5 |

---

## Success Criteria (Phase 1.0 Ship)

- [ ] All Week 0 pre-work complete (7 hours)
- [ ] All Week 1 distributions + tests done (19 hours)
- [ ] All Week 2 distribution + tests done (12 hours, no slack used)
- [ ] All 40+ unit tests PASS
- [ ] Code compiles with zero warnings
- [ ] PDF/CDF accurate ±1e-6 vs SciPy
- [ ] Sampling performance <1ms per sample
- [ ] Documentation complete
- [ ] v1.0.0 tagged and released
- [ ] Beta deferred to v1.1.0

---

## Approval & Next Steps

**This task breakdown requires user approval before Phase 4 implementation begins.**

**QUESTIONS FOR APPROVAL**:
1. ✅ Is 7-hour Week 0 pre-work non-negotiable?
2. ✅ Is deferring Beta to Phase 1.5 acceptable?
3. ✅ Are the task effort estimates reasonable?
4. ✅ Are dependencies and blocking relationships clear?

**WHEN APPROVED**: Run `/eiffel.implement /d/prod/simple_probability` to begin Phase 4 implementation.

---

**Phase 3 Status**: COMPLETE - Ready for Human Approval
**Generated**: 2026-01-27
**Next**: Phase 4 Implementation (when approved)
