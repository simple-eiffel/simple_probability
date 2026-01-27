# REQUIREMENTS: simple_probability

## Functional Requirements

| ID | Requirement | Priority | Category | Acceptance Criteria |
|----|-----------|----------|----------|---------------------|
| **FR-001** | Create probability distributions (Normal, Uniform, Beta, Binomial) | **MUST** | MVP | `create {NORMAL_DISTRIBUTION}.make(mu, sigma)` successfully instantiates distribution with valid mean/variance |
| **FR-002** | Compute PDF (probability density function) for any distribution | **MUST** | MVP | `dist.pdf(x)` returns value ∈ [0, ∞); integrates approximately to 1.0 over domain |
| **FR-003** | Compute CDF (cumulative probability) for any distribution | **MUST** | MVP | `dist.cdf(x)` returns value ∈ [0, 1]; strictly increasing; cdf(min)≈0, cdf(max)≈1 |
| **FR-004** | Compute ICDF/quantile (inverse CDF) for any distribution | **MUST** | MVP | `dist.icdf(p)` for p ∈ (0,1) returns x such that cdf(x) ≈ p; icdf(0.5) ≈ median |
| **FR-005** | Sample random values from any distribution | **MUST** | MVP | `dist.sample()` returns value in domain; repeated samples show histogram matches PDF |
| **FR-006** | Provide distribution parameters (mean, variance, etc.) | **MUST** | MVP | `dist.mean`, `dist.variance` return correct values; contracts enforce parameter validity |
| **FR-007** | Support Bayesian prior specification | **SHOULD** | MVP | Developers can create prior distribution and specify it as starting belief |
| **FR-008** | Support Bayesian likelihood specification | **SHOULD** | MVP | Developers can define likelihood via agent/function for custom models |
| **FR-009** | Update posterior from prior + likelihood + data | **SHOULD** | MVP | `prior.update(likelihood_agent, data: ARRAY)` returns posterior distribution |
| **FR-010** | Extract credible intervals from posterior | **SHOULD** | MVP | `posterior.credible_interval(0.95)` returns [lower, upper] bounds containing 95% probability |
| **FR-011** | Support common conjugate prior pairs | **SHOULD** | Phase 1/2 | Beta-Binomial, Normal-InverseGamma pairs have specialized fast updating |
| **FR-012** | Metropolis-Hastings MCMC sampling | **SHOULD** | Phase 2 | `mcmc_sampler.sample(posterior, n_samples)` generates posterior samples for complex models |
| **FR-013** | Maximum Likelihood Estimation (MLE) from data | **SHOULD** | Phase 2 | `NORMAL_DISTRIBUTION.estimate_from_data(data)` returns best-fit distribution |
| **FR-014** | Method of Moments estimation | **SHOULD** | Phase 2 | `dist.estimate_parameters_from_moments(mean, variance)` returns fitted distribution |
| **FR-015** | Support discrete distributions (Binomial, Poisson, Geometric) | **SHOULD** | Phase 1.5 | `dist.pmf(k)` for integer k; sampling produces integers |
| **FR-016** | Support additional continuous distributions (Exponential, Gamma, Lognormal) | **SHOULD** | Phase 2 | Core exponential/gamma support in Phase 2; lognormal Phase 2+ |
| **FR-017** | Multivariate Normal distribution | **COULD** | Phase 2 | Support for mean vector, covariance matrix; sampling returns vectors |
| **FR-018** | Bayesian model comparison via Bayes factors | **COULD** | Phase 2+ | Compare posteriors from competing models |

---

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-----------|----------|---------|--------|
| **NFR-001** | Numerical accuracy (PDF/CDF) | ACCURACY | Error vs gold standard | < 1e-6 relative error vs standard library |
| **NFR-002** | Sampling correctness | CORRECTNESS | KS test (sample distribution vs true) | p-value > 0.05 for samples from any dist |
| **NFR-003** | Contract enforcement | SAFETY | Precondition violations caught | σ > 0, p ∈ [0,1], n > 0 enforced; violations fail at runtime |
| **NFR-004** | Type safety | SAFETY | Compilation errors for misuse | Wrong types (e.g., passing distribution to integer context) rejected at compile time |
| **NFR-005** | Void safety | SAFETY | No null pointer errors | All DISTRIBUTION instances are attached (never detachable) |
| **NFR-006** | SCOOP compatibility | CONCURRENCY | Thread-safe sampling | Multiple agents can call `sample()` simultaneously without data races |
| **NFR-007** | Performance: sampling | PERFORMANCE | Time per sample | < 1ms per sample (including overhead) for all Phase 1 distributions |
| **NFR-008** | Performance: CDF computation | PERFORMANCE | Time per CDF call | < 100μs per call (numerical integration acceptable) |
| **NFR-009** | Memory efficiency | EFFICIENCY | Memory per distribution | < 1KB per distribution instance |
| **NFR-010** | Documentation quality | DOCUMENTATION | Coverage & clarity | Every public feature has contract + documentation; code examples for common tasks |
| **NFR-011** | Compilation time | BUILD | Time to compile library | < 30s full rebuild |
| **NFR-012** | Test coverage | QUALITY | Line coverage | ≥ 90% coverage; critical paths 100% |
| **NFR-013** | Reproducibility | RELIABILITY | Deterministic sampling with seed | Same seed → same sample sequence, even across runs |

---

## Functional Requirements by Phase

### Phase 1: Core MVP (Weeks 1-3)

**Must deliver:**
- DISTRIBUTION abstract class with pdf(), cdf(), icdf(), sample()
- NORMAL_DISTRIBUTION (most important, most used)
- UNIFORM_DISTRIBUTION (trivial, shows pattern)
- BETA_DISTRIBUTION (conjugate prior for Bayesian)
- BINOMIAL_DISTRIBUTION (discrete; conjugate for Beta)
- EXPONENTIAL_DISTRIBUTION (waiting times, reliability)
- SIMPLE_PROBABILITY facade (factory pattern)
- Basic parameter inference (mean/variance estimation)
- Unit tests: ≥ 100 tests covering distributions, sampling, edge cases

**Constraints:**
- No MCMC (deferring to Phase 2)
- No multivariate (single-variable distributions)
- No advanced conjugate pairs (only basic updating)

**Deliverable:** Library compiles, tests pass, all distributions work, basic Bayesian updating works.

### Phase 1.5: Discrete Distributions (Week 3-4)

**Nice-to-have additions:**
- POISSON_DISTRIBUTION (counting events)
- GEOMETRIC_DISTRIBUTION (number of trials to first success)
- NEGATIVE_BINOMIAL_DISTRIBUTION (generalization)

**Deliverable:** All discrete distributions have pmf/cdf/icdf/sample working.

### Phase 2: Inference (Weeks 4-6)

**Should deliver:**
- BAYESIAN_UPDATER for posterior calculation
- CONJUGATE_PAIR registry (Normal-InverseGamma, Beta-Binomial)
- MCMC_SAMPLER (Metropolis-Hastings)
- Credible intervals from posterior samples
- Model comparison (Bayes factors)

**Deliverable:** Can solve real-world Bayesian problems (disease testing, A/B testing).

### Phase 2+: Extended Distributions

**Could deliver:**
- GAMMA_DISTRIBUTION, WEIBULL_DISTRIBUTION, LOGNORMAL_DISTRIBUTION
- STUDENT_T_DISTRIBUTION, CHI_SQUARED_DISTRIBUTION
- MULTIVARIATE_NORMAL_DISTRIBUTION
- DIRICHLET_DISTRIBUTION

**Deliverable:** 20+ distributions available.

---

## Semantic Accessibility Requirements (Developer Pain Points)

These are special requirements focused on making probability accessible to non-mathematicians.

| ID | Pain Point | Requirement | How to Verify |
|----|-----------|-----------|---|
| **PA-001** | Math notation is intimidating | Every API element has plain English name + comment explaining it | Review: `pdf()` has docstring "probability density at x"; contract says what parameter ranges are valid |
| **PA-002** | Unclear what "prior" means | Documentation defines prior/likelihood/posterior in business context (not math) | Example: "Prior = what you believed before seeing data; Posterior = what you believe after" |
| **PA-003** | Hard to specify distributions | API feels natural: `NORMAL_DISTRIBUTION.make(mean, std_dev)` not `NORMAL_DISTRIBUTION.make(mu, sigma_squared)` | Constructor uses intuitive names; tests show common usage patterns |
| **PA-004** | Conjugate pairs are mysterious | Library hides conjugacy when possible; lets us do fast exact updates | User code doesn't mention "conjugate"; just does `prior.update(likelihood, data)` |
| **PA-005** | Numerical stability scary | Library handles numerical edge cases; precision built into contracts | User never computes log-likelihoods manually; library does stable computation internally |
| **PA-006** | MCMC feels black-box | Clear contract on MCMC: how many samples? burn-in? how to verify convergence? | Contracts on `MCMC_SAMPLER.sample(n, burn_in)` explain each parameter; examples show when to worry about convergence |
| **PA-007** | Hard to test probability code | Distributions support deterministic seeding for unit testing | Tests use `dist.set_seed(42)` then verify samples are repeatable |
| **PA-008** | Unclear confidence in predictions | Credible intervals are always available; clear interpretation | `posterior.credible_interval(0.95)` returns easy-to-explain [lower, upper] bounds |

---

## Constraints & Limitations

### Hard Constraints (Cannot Violate)

1. **SCOOP compatibility** — All classes must be SCOOP-compatible
2. **Void safety** — Compilation flag: `void_safety=all`
3. **Design by Contract** — Every feature has require/ensure/invariant
4. **No external C** — No separate .c files; inline C only if needed
5. **Eiffel-first** — Use simple_randomizer, simple_math; avoid ISE stdlib where possible
6. **No file I/O** — Don't load probability tables from disk; compute everything

### Soft Constraints (May Relax in Later Phases)

1. **Performance** — MVP accepts O(n) sampling; Phase 2+ can optimize
2. **Distribution count** — Start with 5-6; can add more later
3. **MCMC algorithm** — Metropolis-Hastings acceptable; HMC can come in Phase 3
4. **Multivariate support** — Can defer to Phase 2 if it's blocking MVP

### Dependencies

| Library | Purpose | simple_* Preference |
|---------|---------|---|
| **simple_randomizer** | RNG base for all sampling | YES (required) |
| **simple_math** | Integration (CDF approx), basic math functions (exp, log) | YES (required) |
| **base** | REAL_64, INTEGER, ARRAY, ARRAY2 | YES (required for Eiffel types) |

### No Dependencies (Avoid)

- `simple_ml` (separate concern)
- `simple_neural` (future optimization only)
- `simple_networks` (Bayesian networks are Phase 3+)
- Any ISE `stat_*` packages (don't exist anyway)

---

## Acceptance Criteria: How to Know We're Done

### Definition of "Phase 1 Complete"

- [ ] All 6 Phase 1 distributions compile without warnings
- [ ] All 100+ unit tests pass on first run
- [ ] PDF/CDF errors < 1e-6 against NumPy/SciPy reference
- [ ] Sampling passes KS test (p > 0.05) against true distribution
- [ ] SCOOP concurrency test: 4 agents sampling simultaneously → no data races
- [ ] Documentation complete: README, API docs, 3+ worked examples
- [ ] Bayesian updating works on 2 real-world examples (disease test, coin flip)
- [ ] Performance: sampling < 1ms per sample, CDF < 100μs
- [ ] Code review passed
- [ ] Ready to ship as v1.0.0

### Definition of "Production Ready"

- [ ] Phase 1 + Phase 2 complete
- [ ] MCMC convergence diagnostics working
- [ ] Credible intervals verified on synthetic data
- [ ] 5+ real-world case studies documented
- [ ] Community feedback incorporated
- [ ] Performance optimized
- [ ] Ready to ship as v2.0.0

---

## Requirements Traceability

| Requirement | Tests | Documentation | Implementation |
|-------------|-------|---|---|
| FR-001 (Create distributions) | test_normal_creation, test_beta_creation, ... | README "Getting Started" | DISTRIBUTION_FACTORY |
| FR-002 (PDF) | test_normal_pdf_accuracy, test_pdf_integrates_to_1 | API docs for pdf() | DISTRIBUTION.pdf() |
| FR-003 (CDF) | test_cdf_monotonic, test_cdf_bounds | API docs for cdf() | DISTRIBUTION.cdf() |
| ... (all 18 FRs) | ... | ... | ... |

