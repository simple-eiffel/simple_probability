# Intent: simple_probability

## What

**simple_probability** is a type-safe, Design-by-Contract probability and Bayesian reasoning library for Eiffel developers. It provides accessible probability distributions (Normal, Uniform, Beta, Binomial, Exponential) and basic Bayesian inference via conjugate priors, enabling developers to perform statistical analysis and uncertainty quantification without deep mathematical training.

Core capability: Create a distribution, sample from it, compute probabilities, and update beliefs with data using Bayesian reasoning—all within Eiffel's type system and concurrency model.

## Why

**Problem:** Eiffel developers lack a probability library. The ecosystem has excellent numerical methods (simple_math) but zero probability distributions or Bayesian inference. When developers need probability reasoning:

1. **Option A:** Context-switch to Python/R for PyMC or Stan (breaks type safety, loses SCOOP concurrency)
2. **Option B:** Implement from scratch (inefficient, error-prone)
3. **Option C (new):** Use simple_probability (type-safe, SCOOP-native, production-ready)

**Market validation:** Python's PyMC (50k+ stars), R's Bayesian packages, Julia's Distributions.jl all demonstrate proven demand. Eiffel has none.

**Competitive advantage:** Eiffel's unique strengths (type safety, Design by Contract, SCOOP concurrency) make probability reasoning *more reliable* than Python/R alternatives—probability values are compile-time checked (PROBABILITY_VALUE ∈ [0,1]), Bayesian updates are contract-verified, and MCMC chains run in parallel without GIL.

## Users

1. **Industrial IoT Engineers:** Sensor uncertainty quantification (model noise, measurement error propagation)
2. **Reliability Engineers:** Failure rate analysis, FMEA (Failure Mode and Effects Analysis), safety certification (ASIL D compliance)
3. **QA/Test Engineers:** A/B testing with Bayesian confidence intervals, variant comparison
4. **Medical Device Developers:** Diagnostic algorithms, test result interpretation (disease prevalence + test accuracy → posterior risk)
5. **Manufacturing:** Production capacity planning under demand/supply uncertainty
6. **Data Pipeline Developers:** Build statistical models within Eiffel systems; no Python process spawning

## Acceptance Criteria

### Phase 1 MVP (Weeks 1-3)

- [ ] **Five distributions implemented:** Normal, Uniform, Beta, Binomial, Exponential
  - Each has `pdf(x)`, `cdf(x)`, `icdf(p)`, `sample()`, `mean`, `variance`
  - All operations contract-verified (preconditions on parameters, postconditions on results)
- [ ] **Bayesian updating:** Beta-Binomial conjugate pair (exact posterior update)
  - `BAYESIAN_UPDATER.update_conjugate_beta_binomial(prior_alpha, prior_beta, successes, trials) → BETA_DISTRIBUTION`
- [ ] **Parameter inference:** Estimate distribution from observed data
  - Method of Moments, basic Maximum Likelihood fitting
- [ ] **SIMPLE_PROBABILITY facade:** Factory methods `new_normal()`, `new_uniform()`, etc.
- [ ] **SCOOP concurrency:** 4 independent agents sampling 1000 times each in parallel → zero data races
- [ ] **Numerical accuracy:** ±1e-6 relative error vs SciPy/NumPy reference implementations
- [ ] **Reproducible sampling:** `set_seed(42)` produces identical sequences across runs
- [ ] **100+ tests, 90%+ coverage:** Unit, integration, statistical validation (KS test)
- [ ] **Documentation:**
  - README with getting started (non-math accessible)
  - 3 worked examples (disease test, coin flip, sensor fusion)
  - API reference with contracts explained in plain English
- [ ] **Non-math accessibility:** Every feature named for business context, not mathematical notation
  - `credible_interval(0.95)` not `quantile_function(0.975)`
  - Documentation explains concepts in English first, then math (if needed)

### Phase 1.5 (Optional, Week 3-4)

- [ ] **Three discrete distributions:** Poisson, Geometric, Negative Binomial

### Quality Gates

- [ ] **DBC:** Every public feature has require/ensure/invariant
- [ ] **Void-safe:** All instances attached; no detachable unless explicit
- [ ] **Compilable:** `ec.sh -batch -config simple_probability.ecf -target simple_probability_tests -c_compile` → SUCCESS
- [ ] **Testable:** All critical paths exercisable; agents mockable (for determinism)
- [ ] **Typed:** PROBABILITY_VALUE semantic type prevents mixing probabilities with measurements
- [ ] **SCOOP-ready:** No shared mutable state; independent trials via agents

## Out of Scope

### Phase 1 Excludes

- MCMC sampling (Metropolis-Hastings) — Phase 2
- Extended distributions (Gamma, Weibull, Lognormal, Student's t, Chi-squared) — Phase 2
- Multivariate distributions — Phase 2+
- Model comparison (Bayes factors, evidence) — Phase 2
- Advanced conjugate pairs (Normal-InverseGamma, etc.) — Phase 2
- Graphical models / Bayesian networks — Phase 3+
- Frequentist hypothesis testing — separate library (future: simple_frequentist)

### Never (Out of Scope Entirely)

- Machine learning implementations — separate library (simple_ml will use distributions as components)
- Time series models (ARIMA, Kalman) — future domain
- Causal inference (do-calculus) — future research
- GPU acceleration — not Eiffel's focus
- Python/R bindings — keep library pure Eiffel

## Dependencies (REQUIRED - simple_* First Policy)

**RULE:** Always prefer simple_* libraries over ISE EiffelStudio stdlib and Gobo.

| Need | Library | Justification | Alternative (AVOID) |
|------|---------|---------------|----------------------|
| Random number generation | **simple_randomizer** v1.0+ | Seeding, reproducible sampling; SCOOP-safe | ISE `random` (insufficient) |
| Math functions (exp, log, sqrt, π) | **simple_math** v1.0+ | Computation of PDFs, sampling algorithms | ISE `math` (limited) |
| Summation, integration | **simple_statistics** v1.0+ | Numerical methods for parameter inference | Custom implementation |

**Only ISE allowed (no simple_* equivalent):**
- `base` — fundamental types (REAL_64, INTEGER, ARRAY)
- `time` — DATE, TIME, DATE_TIME (not needed for Phase 1)

**MML Decision (Collections & Verification):**
- **Answer:** YES - Optional (Phase 1.5+)
- **Rationale:** Phase 1 uses fixed internal structures (no user-visible collections); Phase 1.5 may add collection operations requiring MML model queries for precise frame conditions. simple_mml not needed for MVP but reserved for future.

## Design Decisions (From Research)

| Decision | Rationale | Reversibility |
|----------|-----------|---|
| **D-001: BUILD from scratch** | Eiffel-native, type-safe, SCOOP-native (not a wrapper) | Reversible: could add bindings later |
| **D-002: 5 distributions in Phase 1** | Covers 80% of use cases; conjugate pair (Beta-Binomial) included | Reversible: Phase 2 expands |
| **D-003: Object-oriented API** | Type-safe, extensible, contracts on methods (not functions) | Reversible: could add functional layer |
| **D-004: Conjugate priors Phase 1, MCMC Phase 2** | Phase 1 MVP; MCMC added when needed | Reversible: MCMC designed upfront |
| **D-005: Semantic API (credible_interval not quantile_function)** | Accessible for non-math developers | Reversible: add aliases Phase 2 |
| **D-006: Per-distribution seed** | SCOOP-safe; each distribution has local RNG state | Reversible: could add global seeding |
| **D-007: Dual-narrative documentation** | Business semantic + mathematical level | Reversible: reorganize Phase 2 |
| **D-008: Full integration with simple_randomizer & simple_math** | Reuse ecosystem; avoid dependencies | Reversible: unlikely (natural pairing) |
| **D-009: Separate CONTINUOUS/DISCRETE hierarchies** | Type-safe: pdf() only for continuous | Reversible: could unify with runtime checks |
| **D-010: Open architecture (users can extend)** | Users create custom distributions via inheritance | Reversible: could restrict to sealed |

## Innovations

| Innovation | Impact |
|------------|--------|
| **I-001: DBC-Enforced Probability Validity** | Preconditions catch invalid parameters (σ > 0, p ∈ [0,1]); postconditions verify sensible outputs; invariants prevent corruption |
| **I-002: Semantic Accessibility Layer** | Two API levels: business semantic (non-math) + mathematical (statisticians); hides complexity without sacrificing rigor |
| **I-003: Type-Safe Bayesian Reasoning** | Prior ≠ Posterior ≠ Likelihood in type system; compile-time errors prevent misuse |
| **I-004: SCOOP-Native Parallel MCMC** | Phase 2: parallel chains run as independent agents; no locks/deadlocks/GIL |
| **I-005: Semantic Framing for Non-Math** | Business-friendly naming; credible intervals explained in plain English before math |
| **I-006: Verification-Friendly Testing** | Contracts are specification; statistical tests verify contracts hold |
| **I-007: Built-in Parameter Inference** | Forward (pdf, sample) + inverse (fit to data) in every distribution |

## Risks & Mitigations

| Risk | Likelihood | Design Mitigation |
|------|------------|-------------------|
| **Numerical instability** | MEDIUM | Use log-space; test edge cases vs SciPy; document bounds |
| **API too "mathy" for non-math audience** | MEDIUM | Semantic layer design; user testing Phase 0.5; intuitive naming |
| **Scope creep** | HIGH | Clear phase boundaries in contract; design extensibility upfront |
| **SCOOP concurrency bugs** | LOW | Intensive concurrent testing; SCOOP design review |
| **Math errors in implementations** | LOW | Triple-verify formulas; cross-test vs SciPy, Julia, R; peer review |
| **Performance slower than SciPy** | MEDIUM | Set expectations; optimize Phase 2; document tradeoffs |

## Use Cases

### UC-001: Sensor Uncertainty Quantification
**Actor:** IoT developer adding uncertainty to sensor readings
- Sensor has known error distribution (Normal, σ=±10% of reading)
- Model uncertainty in data pipeline
- Query 95th percentile for bounds: `critical_value := dist.icdf(0.95)`

### UC-002: Bayesian Disease Testing
**Actor:** Medical device developer implementing Bayes' theorem
- Prior: 1% disease prevalence
- Test: 90% sensitivity, 3% false positive
- Update posterior: `posterior := prior.update(likelihood, [test_positive])`
- Report: "95% credible interval [0.20, 0.60]: 20-60% chance of disease"

### UC-003: A/B Testing with Bayesian Confidence
**Actor:** QA engineer comparing feature variants
- Control: 920/1000 successes
- Treatment: 940/1000 successes
- Compare posteriors: "Treatment 95% likely better if intervals don't overlap"

## Phase 1 Effort Estimate

- **Core implementation:** 2 weeks (distributions, Bayesian, facade)
- **Testing & validation:** 3-5 days (100+ tests, statistical verification)
- **Documentation:** 3-5 days (README, examples, API docs)
- **Code review & polish:** 2-3 days
- **Total:** 3-4 weeks to v1.0.0

**LOC estimate:** ~1,500 lines
- Bases: 200 LOC
- Concrete distributions: 1,000 LOC (200 each)
- Bayesian: 100 LOC
- Facade: 100 LOC
- Supporting: 100 LOC

## Success Metrics (Ship Readiness)

- [ ] All 5 distributions compile without warnings
- [ ] 100+ unit tests pass; 90%+ code coverage
- [ ] PDF/CDF accurate to ±1e-6 vs SciPy reference
- [ ] Sampling passes KS test (p > 0.05) for all distributions
- [ ] SCOOP: 4 agents, 1000 concurrent samples each, zero failures
- [ ] Documentation complete: README, API docs, 3+ worked examples
- [ ] Bayesian updating demo: disease test + coin flip examples
- [ ] Performance: sampling <1ms, CDF <100μs
- [ ] Code review passed by senior developer + statistician
- [ ] v1.0.0 ready for release

## Design Quality Targets

| Criterion | Target | Rationale |
|-----------|--------|-----------|
| **OOSC2 Compliance** | 5/5 principles | Type-safe, extensible design; proper inheritance |
| **Eiffel Excellence** | 7/7 criteria | DBC, void-safe, genericity-ready, information hiding |
| **Void Safety** | 100% | All instances attached; no null pointer errors |
| **Test Coverage** | 90%+ | Critical paths 100%; all branches tested |
| **Numerical Accuracy** | ±1e-6 | Comparable to SciPy; sufficient for industrial use |
| **Concurrency Safety** | SCOOP-ready | No data races; deterministic with seed |

## Phase Roadmap

### Phase 1 (Weeks 1-3): Core MVP ✓ In Specification
- Normal, Uniform, Beta, Binomial, Exponential distributions
- Bayesian updating via Beta-Binomial conjugate pair
- Parameter inference (Method of Moments, basic fitting)
- 100+ tests, documentation
- **Ship:** v1.0.0

### Phase 1.5 (Week 3-4): Discrete Distributions (Optional)
- Poisson, Geometric, Negative Binomial
- Keep momentum; expand applicability

### Phase 2 (Weeks 4-6): Inference & Extended Distributions
- MCMC sampling (Metropolis-Hastings)
- Extended distributions (Gamma, Weibull, Lognormal, etc.)
- Model comparison (Bayes factors)
- Performance optimization
- **Ship:** v2.0.0

### Phase 3+ (Future)
- Bayesian networks / graphical models
- Probabilistic programming language features
- Multivariate distributions
- Advanced variance reduction techniques

---

**STATUS: Ready for Intent Review**

Intent document created from research + specification phases. This captures WHAT developers need (type-safe probability for non-math developers), WHY (Eiffel gap, market proven), USERS (IoT, reliability, QA), and ACCEPTANCE CRITERIA (5 distributions, 100+ tests, SCOOP-safe, 90%+ coverage).

Next: AI review cycle to surface assumptions and clarify vague language.
