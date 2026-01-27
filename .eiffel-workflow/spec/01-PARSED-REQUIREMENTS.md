# PARSED REQUIREMENTS: simple_probability

## Problem Summary

Developers building data-driven systems in Eiffel lack a simple, accessible probability and Bayesian reasoning library. The Eiffel ecosystem has excellent foundational mathematics (simple_math: vectors, matrices, statistics) but **zero probability distributions, Bayesian inference, or sampling algorithms**.

Non-math engineers especially struggle: probability notation is intimidating, and switching to Python/R for Bayesian reasoning breaks Eiffel's type safety and SCOOP concurrency guarantees. simple_probability solves this by making probability accessible via intuitive APIs while leveraging Eiffel's unique strengths (type safety, contracts, SCOOP).

---

## Scope

### In Scope (Phase 1 MVP)

**Probability Distributions:**
- Normal (μ, σ) — most important, bell-curve
- Uniform (a, b) — flat bounded
- Beta (α, β) — prior for proportions, conjugate for Binomial
- Binomial (n, p) — counting successes, likelihood for Beta
- Exponential (λ) — waiting times, failures, reliability

**Distribution Operations:**
- `pdf(x)` — probability density function
- `cdf(x)` — cumulative probability P(X ≤ x) ∈ [0,1]
- `icdf(p)` — quantile/inverse CDF
- `sample()` — random draw from distribution
- `mean, variance` — distribution moments
- `set_seed()` — reproducible sampling

**Bayesian Reasoning (Conjugate Priors Only):**
- Specify prior distribution (belief before data)
- Specify likelihood via agent (how well model fits data)
- Update posterior (belief after data)
- Extract credible intervals (confidence bounds)
- Beta-Binomial conjugate pair (exact fast updates)

**Parameter Inference:**
- Method of Moments (estimate from mean/variance)
- Basic fitting (estimate distribution from observed data)

**Facade:**
- `SIMPLE_PROBABILITY` — factory for creating distributions, utilities

### In Scope (Phase 1.5, if time permits)

- POISSON_DISTRIBUTION, GEOMETRIC_DISTRIBUTION, NEGATIVE_BINOMIAL_DISTRIBUTION
- Additional discrete distribution support

### In Scope (Phase 2+)

- MCMC sampling (Metropolis-Hastings) for arbitrary posteriors
- Extended distributions (Gamma, Weibull, Lognormal, Student's t, Chi-squared)
- Multivariate distributions (Multivariate Normal, Dirichlet)
- Model comparison (Bayes factors, evidence)
- Advanced conjugate pairs (Normal-InverseGamma, etc.)

### Out of Scope

- Machine learning implementations — separate library (simple_ml)
- Bayesian networks / graphical models — Phase 3+ (simple_networks)
- Time series models (ARIMA, Kalman) — future domain
- Causal inference (do-calculus) — future research
- GPU acceleration — Phase 3+
- Frequentist hypothesis testing — separate library (simple_frequentist)

---

## Functional Requirements (Phase 1 MVP)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| **FR-001** | Create Normal distribution | MUST | `create {NORMAL_DISTRIBUTION}.make(0, 1)` → distribution with mean=0, variance=1 |
| **FR-002** | Create Uniform distribution | MUST | `create {UNIFORM_DISTRIBUTION}.make(-1, 1)` → distribution with bounds [-1,1] |
| **FR-003** | Create Beta distribution | MUST | `create {BETA_DISTRIBUTION}.make(2, 5)` → distribution with shape parameters valid |
| **FR-004** | Create Binomial distribution | MUST | `create {BINOMIAL_DISTRIBUTION}.make(10, 0.5)` → n=10 trials, p=0.5 probability |
| **FR-005** | Create Exponential distribution | MUST | `create {EXPONENTIAL_DISTRIBUTION}.make(1.5)` → rate/lambda parameter set |
| **FR-006** | Compute PDF for continuous | MUST | `dist.pdf(x)` returns density; result ≥ 0; result finite |
| **FR-007** | Compute CDF for continuous | MUST | `dist.cdf(x)` returns value ∈ [0,1]; monotonically increasing |
| **FR-008** | Compute ICDF/quantile | MUST | `dist.icdf(0.5)` returns median; `dist.icdf(0.95)` returns 95th percentile |
| **FR-009** | Sample from distribution | MUST | `dist.sample()` returns random value in domain; repeated samples match PDF histogram |
| **FR-010** | Access distribution parameters | MUST | `dist.mean` returns correct value; `dist.variance` returns correct value |
| **FR-011** | Set random seed | MUST | `dist.set_seed(42)` → repeated sampling with same seed produces identical sequence |
| **FR-012** | Bayesian prior specification | SHOULD | Create Beta prior `prior := create {BETA_DISTRIBUTION}.make(1, 1)` represents belief |
| **FR-013** | Bayesian likelihood | SHOULD | Define likelihood via agent: `likelihood := agent (success: BOOLEAN): REAL_64 do ... end` |
| **FR-014** | Bayesian posterior update | SHOULD | `posterior := prior.update(likelihood, observed_data)` computes posterior distribution |
| **FR-015** | Credible intervals | SHOULD | `posterior.credible_interval(0.95)` returns [lower, upper] bounds for 95% confidence |
| **FR-016** | Parameter estimation | SHOULD | `NORMAL_DISTRIBUTION.estimate_from_moments(mean, variance)` returns fitted distribution |
| **FR-017** | SIMPLE_PROBABILITY facade | MUST | `create {SIMPLE_PROBABILITY}.make` provides factory methods for all distributions |

---

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-----------|----------|---------|--------|
| **NFR-001** | Numerical accuracy (PDF/CDF) | ACCURACY | Error vs reference | < 1e-6 relative error vs SciPy/NumPy |
| **NFR-002** | Sampling distribution correctness | CORRECTNESS | KS test | p-value > 0.05 (samples match true distribution) |
| **NFR-003** | Contract enforcement | SAFETY | Precondition violations | σ > 0, p ∈ [0,1], n > 0 enforced; violations fail at runtime |
| **NFR-004** | Type safety | SAFETY | Compilation errors | Wrong types rejected at compile time (no implicit coercion) |
| **NFR-005** | Void safety | SAFETY | Null pointer errors | All distribution instances attached (never detachable) |
| **NFR-006** | SCOOP concurrency | CONCURRENCY | Data races | Multiple agents sampling concurrently → zero races, deterministic results with seed |
| **NFR-007** | Sampling performance | PERFORMANCE | Time per sample | < 1ms per sample (including overhead) |
| **NFR-008** | CDF performance | PERFORMANCE | Time per CDF call | < 100μs per call |
| **NFR-009** | Memory efficiency | EFFICIENCY | Memory per distribution | < 1KB per instance (no large tables) |
| **NFR-010** | Documentation | DOCUMENTATION | Coverage | Every public feature has contract + plain-English explanation + example |
| **NFR-011** | Build time | BUILD | Compile time | < 30s full rebuild |
| **NFR-012** | Test coverage | QUALITY | Line coverage | ≥ 90% coverage; critical paths 100% |
| **NFR-013** | Reproducibility | RELIABILITY | Deterministic sampling | Same seed → identical samples across runs and machines |

---

## Semantic Accessibility Requirements (Non-Math Developers)

| ID | Pain Point | Requirement | Verification |
|----|-----------|-----------|---|
| **PA-001** | Math notation intimidating | Every API element has plain-English name + comment | `pdf()` docstring explains what it computes in English |
| **PA-002** | Prior/posterior confusing | Documentation defines in business context | Example: "Prior = belief before data; Posterior = belief after" |
| **PA-003** | Hard to specify distributions | API uses intuitive names | `NORMAL_DISTRIBUTION.make(mean, std_dev)` not `make(mu, sigma_squared)` |
| **PA-004** | Conjugate pairs mysterious | Library hides mathematical complexity | User writes `prior.update(likelihood, data)`, not conjugacy math |
| **PA-005** | Numerical stability scary | Library handles edge cases internally | Contracts guarantee stable computation |
| **PA-006** | Credible intervals unclear | API makes interpretation obvious | `posterior.credible_interval(0.95)` returns [lower, upper] with clear meaning |
| **PA-007** | Hard to test probability code | Deterministic seeding for unit tests | Tests use `dist.set_seed(42)` for reproducibility |
| **PA-008** | Confused about confidence | Credible intervals always available | API prioritizes extracting confidence bounds |

---

## Constraints & Immutable Requirements

### Hard Constraints (Cannot Violate)

| Constraint | Type | Reason |
|-----------|------|--------|
| SCOOP-compatible | TECHNICAL | All agents must be able to call `sample()` concurrently without races |
| Void-safe (void_safety=all) | TECHNICAL | Eiffel ecosystem standard; prevents null pointer errors |
| Design by Contract | TECHNICAL | Every feature has require/ensure/invariant |
| No external C files | TECHNICAL | simple_* ecosystem pattern: inline C only if needed |
| Use simple_randomizer for RNG | ECOSYSTEM | Eiffel-first principle; leverage existing library |
| No file I/O | TECHNICAL | Compute all values on-the-fly; no probability tables on disk |

### Soft Constraints (May Relax Later)

| Constraint | Phase | Justification |
|-----------|-------|---|
| Start with 5 distributions, not 100 | Phase 1 | MVP scope; can add later |
| Metropolis-Hastings MCMC acceptable | Phase 2 | Simpler than HMC; sufficient for common use cases |
| Conjugate priors only in Phase 1 | Phase 1 | MCMC complexity deferred to Phase 2 |
| No multivariate distributions Phase 1 | Phase 1 | Reduces scope; can extend Phase 2 |

---

## Decisions Already Made (From Research)

| ID | Decision | Rationale | Phase |
|----|----------|-----------|-------|
| **D-001** | BUILD from scratch (vs wrap PyMC/SciPy) | Eiffel-native, type-safe, SCOOP-compatible | Research |
| **D-002** | 5 distributions in Phase 1 | Covers 80% of use cases; conjugate pair (Beta-Binomial) included | Research |
| **D-003** | Object-oriented API (vs functions) | Type-safe, extensible, contracts on methods | Research |
| **D-004** | Rational approximations for CDF | Fast (<100μs); accurate to 1e-7; can integrate if needed | Research |
| **D-005** | Conjugate priors Phase 1, MCMC Phase 2 | Phase MVP; MCMC added when needed | Research |
| **D-006** | Per-distribution seed + optional randomizer | SCOOP-safe; each distribution has local seed | Research |
| **D-007** | Dual-narrative documentation | Business semantic + mathematical level | Research |
| **D-008** | Full integration with simple_randomizer & simple_math | Reuse exp/log/sqrt; seed RNG properly | Research |
| **D-009** | Separate CONTINUOUS/DISCRETE hierarchies | Type-safe: pdf() only for continuous, pmf() for discrete | Research |
| **D-010** | Open architecture (users can extend) | Extensible; contracts guard correctness | Research |

---

## Innovations to Implement

| ID | Innovation | Design Impact | Priority |
|----|-----------|---------------|----------|
| **I-001** | DBC-Enforced Probability Validity | Preconditions catch invalid parameters; postconditions verify sensible outputs; invariants prevent corruption | HIGH |
| **I-002** | Semantic Accessibility Layer | Two API levels: business semantic (non-math) + mathematical (statisticians); hides complexity | HIGH |
| **I-003** | Type-Safe Bayesian Reasoning | Prior ≠ Posterior ≠ Likelihood in type system; compile-time errors prevent misuse | MEDIUM |
| **I-004** | SCOOP-Native Parallel MCMC | Phase 2: parallel chains run as independent agents; no locks/deadlocks | HIGH (Phase 2) |
| **I-005** | Semantic Framing for Non-Math | Business-friendly naming (credible_interval not quantile_function) | HIGH |
| **I-006** | Verification-Friendly Testing | Contracts are specification; statistical tests verify contracts hold | MEDIUM |
| **I-007** | Built-in Parameter Inference | Forward (pdf, sample) + inverse (fit to data) in every distribution | MEDIUM |

---

## Risks to Address in Design

| ID | Risk | Likelihood | Design Mitigation |
|----|------|-----------|-------------------|
| **RISK-001** | Numerical instability (underflow/overflow) | MEDIUM | Use log-space; test edge cases vs SciPy; document bounds |
| **RISK-002** | API too "mathy" for non-math audience | MEDIUM | Semantic layer design; user testing Phase 0.5; intuitive naming |
| **RISK-003** | Scope creep (wants MCMC, multivariate Phase 1) | HIGH | Clear phase boundaries in contract; design extensibility upfront |
| **RISK-005** | SCOOP concurrency bugs | LOW | Intensive concurrent testing; SCOOP design review |
| **RISK-007** | Performance slower than SciPy | MEDIUM | Set expectations; optimize Phase 2; document tradeoffs |
| **RISK-009** | Mathematical errors in implementations | LOW | Triple-verify formulas; cross-test vs SciPy, Julia, R |

---

## Use Cases (Phase 1 MVP)

### UC-001: Sensor Uncertainty Quantification

**Actor:** IoT Developer adding uncertainty to sensor readings

**Precondition:**
- Sensor has known error distribution (e.g., Normal with σ=±10% of reading)
- Need to model uncertainty in data pipeline

**Main Flow:**
1. Create Normal distribution: `dist := create {NORMAL_DISTRIBUTION}.make(mean, std_dev)`
2. Query distribution properties: `critical_value := dist.icdf(0.95)` (95th percentile)
3. Use in application: "True value is in range [reading - critical_value, reading + critical_value]"

**Postcondition:**
- Uncertainty properly quantified
- Confidence interval calculated

---

### UC-002: Bayesian Disease Testing

**Actor:** Medical device developer implementing Bayes' theorem for test results

**Precondition:**
- Prior probability of disease (1%)
- Test sensitivity (detects 90% of cases)
- Test specificity (3% false positive rate)
- Patient tests positive

**Main Flow:**
1. Create prior: `prior := create {BETA_DISTRIBUTION}.make(0.01, 0.99)` (1% disease rate)
2. Define likelihood: `likelihood := agent (has_disease: BOOLEAN): REAL_64 do ... end`
3. Observe data: `posterior := prior.update(likelihood, [true])`
4. Extract confidence: `interval := posterior.credible_interval(0.95)`
5. Report: "95% credible interval is [0.20, 0.60]: 20-60% chance patient has disease"

**Postcondition:**
- Posterior belief calculated
- Credible interval extracted
- Bayes' theorem applied correctly

---

### UC-003: A/B Testing with Bayesian Confidence

**Actor:** QA engineer validating feature treatment vs control

**Precondition:**
- Control: X successes out of N trials
- Treatment: Y successes out of M trials
- Need to determine if treatment is better

**Main Flow:**
1. Create Beta priors for both: `control_prior := create {BETA_DISTRIBUTION}.make(1, 1)` (uninformed)
2. Update with observations: `control_post := control_prior.update(likelihood, [X, N])`
3. Do same for treatment
4. Extract credible intervals for both
5. Compare: "Treatment is 95% likely to be better if intervals don't overlap"

**Postcondition:**
- Both posteriors calculated
- Intervals computed
- Comparison made

---

## Requirements Traceability (Phase 1 MVP)

| Requirement | Will Be Addressed By | Status |
|----|---|---|
| FR-001 to FR-011 (distributions, operations) | DISTRIBUTION abstract + 5 concrete classes | ✓ Core design |
| FR-012 to FR-016 (Bayesian, estimation) | BAYESIAN_UPDATER (basic), parameter inference methods | ✓ Design planned |
| FR-017 (facade) | SIMPLE_PROBABILITY class | ✓ Design planned |
| NFR-001 to NFR-013 (performance, accuracy, safety) | Contracts, unit tests, stress tests | ✓ Test strategy |
| PA-001 to PA-008 (accessibility) | Semantic API design, documentation structure | ✓ API design |
| I-001 to I-007 (innovations) | Integrated throughout class design | ✓ Design prioritized |

---

## Summary

**Phase 1 MVP will deliver:**
- Type-safe, contract-enforced probability distributions
- Bayesian updating via conjugate priors
- Accessible semantic API (no math notation required)
- 100+ tests, 90%+ coverage
- Full documentation with business + mathematical perspectives
- Ready for production use in data systems

**Known scope:**
- 5 distributions + facade + Bayesian updating
- ~1,500 LOC
- 2-3 weeks development

**Next phase (Phase 2):**
- MCMC for arbitrary posteriors
- 5+ additional distributions
- Performance optimization
- Model comparison

