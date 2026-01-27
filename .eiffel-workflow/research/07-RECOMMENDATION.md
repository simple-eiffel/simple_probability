# RECOMMENDATION: simple_probability

## Executive Summary

**Build simple_probability as a core Eiffel ecosystem library.** It fills a genuine gap (zero probability/Bayesian support), solves real developer pain points (making probability accessible without deep math), and leverages Eiffel's unique strengths (type safety, SCOOP, DBC). The market is proven (successful implementations in Python, R, Julia); we're applying Eiffel's advantages to an established domain.

**Phase 1 MVP:** 6 distributions + basic Bayesian updating via conjugate priors (2-3 weeks). Phase 2: MCMC + extended distributions (2-3 weeks). Roadmap: Bayesian networks, graphical models (Phase 3+).

---

## Recommendation

**Action:** **BUILD** (with phased approach)

**Confidence:** **HIGH** (market proven, architecture clear, risk manageable)

**Timeline:**
- **Phase 1 (MVP):** Weeks 1-3 → v1.0.0 with 5 distributions + basic Bayesian
- **Phase 1.5 (Optional):** Week 3-4 → Add discrete distributions (Poisson, Geometric)
- **Phase 2 (Inference):** Weeks 4-6 → MCMC + model selection
- **Maintenance:** Ongoing → Bug fixes, performance optimization, community contributions

---

## Rationale

### 1. Market Validation

**Proven demand:**
- Python's PyMC (50k+ GitHub stars, industrial use)
- R's base stats + Bayesian packages (standard in data science)
- Julia's Distributions.jl (mature, widely used)
- All three languages have probability as core capability

**Eiffel gap:**
- Zero probability/Bayesian libraries
- simple_math has numerics but no distributions
- Data engineers, reliability engineers, sensor developers have no Eiffel solution
- Either switch to Python/R or implement from scratch (inefficient)

**Opportunity:**
- Fill ecosystem gap
- Attract users from other languages ("I can do Bayesian reasoning in Eiffel now")
- Differentiate (type-safe, SCOOP-native probability is unique)

### 2. Eiffel Advantage

| Aspect | Why Eiffel Wins |
|--------|---|
| **Type Safety** | Probability values are PROBABILITY_VALUE ∈ [0,1], not generic REAL_64 |
| **Design by Contract** | Contracts enforce mathematical properties (PDF integrates to 1, parameters valid) |
| **SCOOP Concurrency** | Parallel MCMC chains without locks/deadlocks/GIL |
| **Production Ready** | Compiled, void-safe, type-checked → fewer runtime surprises |
| **Embedded** | Probability reasoning stays in Eiffel; no Python/R process spawning |

**Competitive positioning:** "Type-safe probability for production systems"

### 3. Technical Feasibility

**Clear architecture:**
- `DISTRIBUTION` abstract class (pdf, cdf, icdf, sample)
- `DISTRIBUTION_CONTINUOUS` / `DISTRIBUTION_DISCRETE` hierarchies
- `SIMPLE_PROBABILITY` facade (factory pattern, like simple_math)
- `BAYESIAN_UPDATER` for inference

**Well-understood algorithms:**
- Box-Muller transform (Normal sampling)
- Inverse transform (general sampling)
- Rejection sampling (complex distributions)
- Rational approximations (fast CDF computation)
- Metropolis-Hastings (Phase 2 MCMC)

**Integration path:**
- Reuse `simple_randomizer` for RNG
- Reuse `simple_math` for exp/log/sqrt
- Reuse `simple_statistics` for parameter estimation

**No dependencies on unproven libraries** — all existing Eiffel ecosystem.

### 4. Risk Mitigation

**Critical risks addressed:**
- Numerical instability: Use log-space computation, test vs SciPy
- API accessibility: Dual-narrative docs (business + math), user testing Phase 0.5
- Scope creep: Clear phase boundaries, reject features for Phase 2
- SCOOP bugs: Design review, intensive concurrent testing
- Math errors: Triple-check formulas, peer review by statistician

**All blocking risks mitigated** (see RISK-006-RISKS.md).

### 5. Ecosystem Fit

**Aligns with simple_* philosophy:**
- Simple (5-6 core distributions, not 100+)
- Safe (contracts on every feature, void-safe, SCOOP-compatible)
- Single responsibility (probability/Bayesian, not ML/networks)

**Complements existing libraries:**
- `simple_math` — numerical methods (foundation)
- `simple_statistics` — summarization (reused)
- `simple_probability` — **distributions & inference** (NEW)
- `simple_ml` (future) — machine learning uses distributions as components
- `simple_networks` (future) — Bayesian networks use distributions

**Phase 3+ roadmap:** Graphical models, probabilistic programming language features.

---

## Proposed Approach

### Phase 1: Core MVP (Weeks 1-3)

**Deliverables:**
1. **DISTRIBUTION abstract class** (150 LOC)
   - Features: pdf, cdf, icdf, sample
   - Contracts: pdf ≥ 0, cdf ∈ [0,1], monotonicity, etc.

2. **Five distributions** (1,000 LOC total)
   - NORMAL_DISTRIBUTION (μ, σ)
   - UNIFORM_DISTRIBUTION (a, b)
   - BETA_DISTRIBUTION (α, β) — conjugate prior
   - BINOMIAL_DISTRIBUTION (n, p) — likelihood for Beta
   - EXPONENTIAL_DISTRIBUTION (λ) — waiting times

3. **SIMPLE_PROBABILITY facade** (100 LOC)
   - Factory methods: new_normal, new_uniform, etc.
   - Utilities: normal_cdf, inverse_normal_cdf (reusable)

4. **Basic Bayesian updating** (150 LOC)
   - BAYESIAN_UPDATER for conjugate pairs
   - Beta-Binomial exact update
   - Posterior sampling via rejection

5. **Documentation & examples** (150 LOC + 1000 words)
   - README with getting started
   - 3+ worked examples (disease testing, coin flips, sensor fusion)
   - API reference with contracts explained

6. **Test suite** (400+ tests, 90%+ coverage)
   - Unit tests: PDF accuracy, CDF correctness, sampling
   - Integration tests: Bayesian updating end-to-end
   - Statistical tests: KS test, chi-squared
   - SCOOP: Parallel sampling, thread-safety

**Milestones:**
- Week 1: Architecture + NORMAL_DISTRIBUTION complete; tests pass
- Week 2: All 5 distributions + facade + Bayesian updating complete
- Week 3: Documentation, examples, full test suite; ship v1.0.0

### Phase 1.5: Discrete Distributions (Week 3-4, optional)

**If time permits:**
- POISSON_DISTRIBUTION (λ)
- GEOMETRIC_DISTRIBUTION (p)
- NEGATIVE_BINOMIAL_DISTRIBUTION (r, p)

**Keeps momentum; expands applicability.**

### Phase 2: Inference & Extended Distributions (Weeks 4-6)

**Deliverables:**
1. **MCMC_SAMPLER (Metropolis-Hastings)** (250 LOC)
   - Generic posterior sampling for custom likelihoods
   - Convergence diagnostics (Gelman-Rubin R̂)
   - Burn-in, thinning, chain diagnostics

2. **Extended distributions** (500+ LOC)
   - GAMMA_DISTRIBUTION, WEIBULL_DISTRIBUTION, LOGNORMAL_DISTRIBUTION
   - STUDENT_T_DISTRIBUTION, CHI_SQUARED_DISTRIBUTION

3. **Advanced inference** (200 LOC)
   - Bayesian model comparison (Bayes factors, evidence)
   - Parameter estimation (MLE, Bayesian)
   - Multivariate Normal (mean vector, covariance matrix)

4. **Performance optimization**
   - Profile Phase 1; optimize hot paths
   - Consider SIMD / inline C if needed

5. **Expanded test suite & examples**
   - Complex Bayesian models
   - A/B testing example
   - Reliability prediction example

---

## Key Features

### MVP Features (Phase 1)

1. **Probability Distributions**
   - Normal (continuous, bell-curve, foundational)
   - Uniform (flat, bounded, reference)
   - Beta (prior for proportions, conjugate)
   - Binomial (counting successes, likelihood for Beta)
   - Exponential (waiting times, failures)

2. **Distribution Methods**
   - `pdf(x): REAL_64` — probability density
   - `cdf(x): REAL_64` — cumulative probability P(X ≤ x)
   - `icdf(p): REAL_64` — quantile/percentile
   - `sample: REAL_64` — random draw
   - `mean, variance: REAL_64` — distribution moments
   - `set_seed, set_random` — reproducible sampling

3. **Bayesian Reasoning**
   - Specify priors (belief before data)
   - Specify likelihoods (model fit)
   - Update posteriors (belief after data)
   - Extract credible intervals (confidence bounds)
   - Exact updates via conjugate pairs

4. **Parameter Inference**
   - Method of Moments (estimate from mean/variance)
   - Basic Maximum Likelihood (curve fitting)
   - Fit distribution to observed data

5. **Safety & Verification**
   - Design by Contract on all features
   - Void safety (no null pointers)
   - SCOOP concurrency support
   - Type-safe probability values

### Extended Features (Phase 2+)

6. **Advanced Inference**
   - MCMC sampling (Metropolis-Hastings)
   - Convergence diagnostics
   - Model comparison (Bayes factors)

7. **More Distributions**
   - Discrete: Poisson, Geometric, Negative Binomial
   - Continuous: Gamma, Exponential, Weibull, Lognormal, Student's t, Chi-squared
   - Multivariate: Normal, Dirichlet

---

## Success Criteria

### Phase 1 Ship Readiness

- [ ] All 5 distributions compile without warnings
- [ ] 100+ unit tests pass; 90%+ code coverage
- [ ] PDF/CDF accurate to ±1e-6 vs SciPy reference
- [ ] Sampling passes KS test (p > 0.05) for all distributions
- [ ] SCOOP concurrency test: 4 agents, 1000 concurrent samples each, zero failures
- [ ] Documentation complete: README, API docs, 3+ worked examples
- [ ] Bayesian updating demo: disease test + coin flip examples work correctly
- [ ] Performance: sampling <1ms, CDF <100μs
- [ ] Code review passed by senior developer + statistician
- [ ] Ready: v1.0.0 shipped, tagged, announced

### Phase 1 Adoption Metrics (3 months post-ship)

- [ ] 50+ GitHub stars
- [ ] 2+ external projects using library
- [ ] 10+ downloads/uses logged
- [ ] 0 critical bugs reported
- [ ] Positive community feedback ("This is useful")

### Phase 2 Goals

- [ ] MCMC working for arbitrary posteriors
- [ ] 10+ distributions available
- [ ] Real-world projects (POS, sensors, reliability) using library
- [ ] v2.0.0 shipped with confidence

---

## Dependencies

| Library | Version | Why | Optional? |
|---------|---------|-----|-----------|
| **simple_randomizer** | v1.0+ | RNG for all sampling | NO (required) |
| **simple_math** | v1.0+ | Integration, exp/log, statistics | NO (required) |
| **base** | (ISE stdlib) | REAL_64, INTEGER, ARRAY | NO (required for Eiffel) |

**No other dependencies.** Standalone library, pure Eiffel (except ISE base).

---

## Next Steps

### Immediate (This Week)

1. **Get approval** on this research phase (via oracle or manual review)
2. **User interviews** (Phase 0.5) — Ask 3-5 potential users: "Would you use this?"
3. **Allocate resources** — Assign lead developer, statistician reviewer, tech writer

### Week 1 (Phase Spec)

Run `/eiffel.spec /d/prod/simple_probability` to transform this research into formal specification:
- Class hierarchy design
- Contract specifications
- API details
- ECF configuration

### Week 1-2 (Phase Intent)

Run `/eiffel.intent /d/prod/simple_probability` to capture refined requirements and design patterns.

### Week 2+ (Phase Implementation)

Begin Phase 1 development:
- Create DISTRIBUTION abstract class
- Implement NORMAL_DISTRIBUTION
- Build test infrastructure
- Iterate on remaining distributions

---

## Open Questions for Spec Phase

1. **Multivariate support in Phase 1 or Phase 2?** (Currently deferred to Phase 2)
2. **MCMC interface:** How to design so Phase 1 extension to Phase 2 is seamless?
3. **Conjugate pair registry:** How to represent Beta-Binomial, Normal-InverseGamma pairs?
4. **Custom distributions:** Should users be able to create new distribution classes easily?
5. **Documentation format:** Jupyter notebooks (Eiffel-compatible?) or plain Eiffel examples?

---

## Recommendation Sign-Off

**Recommendation: PROCEED WITH BUILD**

**Confidence Level: HIGH** (85%+)

**Decision Gate:** This research phase is complete. Awaiting approval to proceed to Specification phase.

**Next Tool:** After approval → Run `/eiffel.spec /d/prod/simple_probability`

