# LANDSCAPE: simple_probability

## Executive Summary

The probability/Bayesian inference space is mature in Python (PyMC, Stan), R (built-in stats + rstanarm), and Julia (Distributions.jl, Turing.jl), but **completely absent from Eiffel**. Other languages' solutions reveal patterns: accessible APIs hide mathematical detail, distribution objects are first-class, and sampling is unified. This is an **opportunity to fill a genuine gap** while learning from proven designs.

---

## Existing Solutions: Competitive Landscape

### Solution 1: PyMC (Python)

| Aspect | Assessment |
|--------|-----------|
| **Type** | Probabilistic programming framework |
| **Platform** | Python + NumPy/Theano/JAX |
| **URL** | https://www.pymc.io/ |
| **Maturity** | MATURE (v4+, used in production) |
| **License** | Apache 2.0 |
| **Lines of Code** | 50,000+ |

**Strengths:**
- Minimal math notation: `pm.Normal('mu', mu=0, sigma=1)` is readable
- Automatic posterior sampling via NUTS (No-U-Turn Sampler)
- Rich ecosystem: ArviZ for visualization, other libs integrate
- "Bayesian Methods for Hackers" teaches via computation-first approach
- Active community

**Weaknesses:**
- Heavy dependencies (NumPy, Theano/JAX, Arviz)
- Steep learning curve for model specification
- Slow for moderate-scale problems
- Overkill for simple conjugate priors

**Relevance to Eiffel:** 80% — Shows how to make distributions first-class, but Eiffel's strict typing prevents direct translation.

**Key Insight:** PyMC uses _explicit model declarations_ (`pm.Normal(...)`) rather than object construction. Could adapt to Eiffel via agents or factory methods.

---

### Solution 2: Stan (Multi-language)

| Aspect | Assessment |
|--------|-----------|
| **Type** | Probabilistic programming language |
| **Platform** | C++ core, interfaces for R/Python/Julia/Shell |
| **URL** | https://mc-stan.org/ |
| **Maturity** | MATURE (v2.30+, industrial use) |
| **License** | BSD 3-Clause |

**Strengths:**
- Dedicated language for probability models (HMC sampling, automatic differentiation)
- Handles complex hierarchical models
- Excellent documentation for non-statisticians
- Proven at scale (epidemiology, economics, neuroscience)

**Weaknesses:**
- Requires external compilation (separate .stan file)
- Steep learning curve (new language to learn)
- Not embeddable in application code
- Slow feedback loop

**Relevance to Eiffel:** 40% — Shows how to handle complex posteriors, but Eiffel doesn't need external compilation. We want embedded inference.

**Key Insight:** Stan's distinction between _model specification_ and _inference_ is valuable. Separating "what's your prior?" from "how do we sample?" simplifies both.

---

### Solution 3: R Base Stats + Bayesian Packages

| Aspect | Assessment |
|--------|-----------|
| **Type** | Language built-in + ecosystem |
| **Platform** | R |
| **URL** | https://www.r-project.org/ (base); rstanarm, bayesm, MCMCpack |
| **Maturity** | MATURE (R 4.0+) |
| **License** | GPL |

**Strengths:**
- Distribution functions built into core: `dnorm()`, `pnorm()`, `qnorm()`, `rnorm()`
- Intuitive naming: d=density (PDF), p=probability (CDF), q=quantile (ICDF), r=random
- Rich ecosystem of Bayesian packages
- Excellent for statistical modeling

**Weaknesses:**
- Slower for non-vectorized operations
- Type system is weak (easy to confuse scalars/vectors)
- Not suitable for building production systems

**Relevance to Eiffel:** 60% — The d/p/q/r naming convention is gold. Could adapt to: `pdf()`, `cdf()`, `icdf()`, `sample()`.

**Key Insight:** Unifying distribution API (every distribution has pdf, cdf, quantile, random sample) is powerful. Eiffel's type system lets us enforce this via abstract classes.

---

### Solution 4: Julia Distributions.jl

| Aspect | Assessment |
|--------|-----------|
| **Type** | Distribution library |
| **Platform** | Julia |
| **URL** | https://juliastats.org/Distributions.jl/ |
| **Maturity** | MATURE (stable API) |
| **License** | MIT |

**Strengths:**
- Clean, uniform API: `pdf(dist, x)`, `cdf(dist, x)`, `rand(dist)`
- Multiple dispatch lets distributions compose elegantly
- Type hierarchy: `ContinuousUnivariateDistribution`, `DiscreteUnivariateDistribution`, etc.
- Separation of concerns: distributions are pure (no side effects), random sampling is orthogonal

**Weaknesses:**
- Julia is niche language
- Less educational material than PyMC/Stan
- Assumes statistical knowledge

**Relevance to Eiffel:** 85% — Type hierarchy + unified API is directly applicable. This is our model.

**Key Insight:** Eiffel's inheritance + contracts can replicate Julia's multiple dispatch elegantly. Design distribution hierarchy early.

---

### Solution 5: SciPy (Python)

| Aspect | Assessment |
|--------|-----------|
| **Type** | Scientific computing library |
| **Platform** | Python + NumPy |
| **URL** | https://scipy.org/ |
| **Maturity** | MATURE (v1.0+) |
| **License** | BSD |

**Strengths:**
- 100+ distributions already implemented
- Consistent API: `scipy.stats.norm.pdf()`, `.cdf()`, `.rvs()`
- Well-tested numerical algorithms
- Good documentation

**Weaknesses:**
- Heavy NumPy dependency
- Not designed for Bayesian inference (just distributions)
- Hard to extend with custom distributions

**Relevance to Eiffel:** 50% — Good reference for numerical algorithms, but Eiffel needs lighter weight.

**Key Insight:** We don't need 100 distributions in MVP. Start with 5-6, extend later.

---

## Eiffel Ecosystem: Current State

### simple_math
**Status:** ✓ Exists (2,000 LOC, 4 classes)

**Capabilities:**
- Numerical methods (integration, interpolation, root-finding)
- Basic statistics (mean, variance, correlation)
- Linear algebra (vectors, matrices, LU decomposition)

**Gap:** No probability distributions, no sampling, no Bayesian inference.

**Alignment:** Perfect foundation. Will reuse integration for CDF approximation, statistics for parameter estimation.

### simple_randomizer
**Status:** ✓ Exists (485 LOC, 1 class)

**Capabilities:**
- Uniform random integers, reals, strings
- Seeded reproducibility
- No distribution sampling

**Gap:** Only uniform distribution; no Box-Muller, rejection sampling, etc.

**Alignment:** Perfect RNG base. Will build all sampling algorithms on top of `random_real_in_range(0.0, 1.0)`.

### simple_statistics
**Status:** ✓ Part of simple_math

**Capabilities:**
- Descriptive statistics (mean, median, percentile)
- Correlation, covariance, regression

**Gap:** No likelihood, no posterior calculation, no conjugate priors.

**Alignment:** Good for estimating distribution parameters. Will extend.

### ISE Base Library
**Status:** ✓ Available

**Used For:**
- ARRAY, LIST, HASH_TABLE (data structures)
- REAL_64, INTEGER (numeric types)
- Creation/destruction semantics

**Constraint:** Prefer simple_* alternatives. Only use ISE for foundational types and where no simple_* alternative exists.

---

## Competitive Solutions Summary

| Feature | PyMC | Stan | R Base | Julia Dists | SciPy | **Our Need** |
|---------|------|------|--------|------------|-------|------------|
| **API simplicity** | High | Medium | High | High | Medium | MUST: High |
| **Type safety** | Low | Medium | Low | High | Low | MUST: High (Eiffel) |
| **Distributions** | 50+ | Custom | 100+ | 100+ | 100+ | SHOULD: Start 6, extend to 30+ |
| **Sampling** | Automatic (NUTS) | Automatic (HMC) | Manual | Explicit | Explicit | SHOULD: Box-Muller, rejection, inverse transform |
| **Bayesian inference** | First-class | First-class | Via packages | First-class | No | SHOULD: Conjugate priors, MCMC |
| **Embeddable** | Yes (via Python) | No (separate file) | Yes (via R) | Yes | Yes | MUST: Yes (Eiffel code) |
| **Production-ready** | Yes | Yes | Yes | Yes | Yes | SHOULD: Phase 1 MVP |
| **Math accessibility** | High (Bayesian Methods for Hackers) | Medium | Medium | Low | Low | MUST: High |

---

## Eiffel-Specific Competitive Advantage

| Aspect | Python/R/Julia | Eiffel |
|--------|---|---|
| **Type system** | Dynamic (loose) | Static (strict) ✓ |
| **Void safety** | Null pointer errors | Contracts enforce invariants ✓ |
| **Concurrency** | Threading (implicit races) | SCOOP (deadlock-free) ✓ |
| **Performance** | Interpreted/JIT | Compiled ✓ |
| **Production safety** | Weak (testing catches bugs) | Contracts+SCOOP (prevention) ✓ |
| **Embedded** | Python/R/Julia must be external | Eiffel native ✓ |

**Opportunity:** Eiffel can offer probabilistic reasoning that is type-safe, void-safe, and production-verified in ways Python/R cannot.

---

## Gap Analysis: What Exists vs What's Needed

| Capability | ISE Base | simple_math | simple_randomizer | **simple_probability (new)** |
|------------|----------|------------|-------------------|-----|
| Normal distribution | ✗ | ✗ | ✗ | **NEW** |
| Beta distribution | ✗ | ✗ | ✗ | **NEW** |
| Binomial distribution | ✗ | ✗ | ✗ | **NEW** |
| Gamma/Exponential | ✗ | ✗ | ✗ | **NEW** |
| PDF function | ✗ | ✗ | ✗ | **NEW** |
| CDF function | ✗ | ✗ | ✗ | **NEW** |
| ICDF/quantile | ✗ | ✗ | ✗ | **NEW** |
| Random sampling | ✗ | ✗ | ✓ (uniform only) | **EXTEND** |
| Box-Muller transform | ✗ | ✗ | ✗ | **NEW** |
| Rejection sampling | ✗ | ✗ | ✗ | **NEW** |
| Inverse transform | ✗ | ✗ | ✗ | **NEW** |
| Bayesian updating | ✗ | ✗ | ✗ | **NEW** |
| Conjugate priors | ✗ | ✗ | ✗ | **NEW** |
| MCMC (Metropolis-Hastings) | ✗ | ✗ | ✗ | **PHASE 2** |

---

## Build vs Buy vs Adapt Decision Matrix

| Option | Effort | Risk | Fit | Recommendation |
|--------|--------|------|-----|---|
| **Build from scratch** | HIGH (1,500-2,000 LOC Phase 1) | MEDIUM (math errors, numerical stability) | PERFECT (Eiffel-native, DBC, SCOOP) | **RECOMMENDED** |
| **Wrap PyMC via FFI** | LOW (binding layer) | HIGH (Python dependency, GIL, deployment complexity) | POOR (loses type safety, SCOOP) | **AVOID** |
| **Port SciPy algorithms** | MEDIUM (adaptation) | LOW (algorithms proven) | GOOD (algorithms reliable) | **HYBRID: Use SciPy as reference** |
| **Call into R/Julia** | LOW (system call) | HIGH (process overhead, deployment) | POOR (not embedded) | **AVOID** |
| **Adapt Julia Distributions.jl** | MEDIUM (translate Julia→Eiffel) | LOW (design proven) | EXCELLENT (type hierarchy fits Eiffel) | **SECONDARY: Reference design** |

---

## Patterns Identified

| Pattern | Seen In | Adopt for Eiffel? |
|---------|---------|---|
| **Unified distribution interface** | R, Julia, SciPy | YES — abstract DISTRIBUTION class with pdf/cdf/icdf/sample |
| **Distribution-as-first-class-object** | PyMC, Stan, Julia | YES — NORMAL_DISTRIBUTION, BETA_DISTRIBUTION, etc. |
| **Separation of model from inference** | Stan, PyMC | YES — DISTRIBUTION is model, BAYESIAN_UPDATER is inference |
| **Conjugate prior pairing** | R bayesm, Stan | YES — Natural conjugate pairs in Phase 2 |
| **Lazy CDF computation** | SciPy (numerical approx) | YES — Compute on-the-fly rather than precompute tables |
| **Agent-based random state** | Simple randomizer pattern | YES — Use agents for reproducible seeding |

---

## Recommendation: BUILD (with reference to Julia/SciPy)

**Build our own simple_probability library because:**

1. **Perfect Eiffel fit**: Type system + contracts + SCOOP enable type-safe, verified probability
2. **Lightweight**: Don't need 100 distributions for MVP; start with 5-6
3. **No external dependencies**: Eiffel first, no Python/R coupling
4. **Design freedom**: Can optimize for non-math developers (hide complexity, expose clarity)
5. **Ecosystem gap**: Genuine need in Eiffel community

**Reference designs:**
- Julia Distributions.jl for type hierarchy
- SciPy for numerical algorithms (CDF approximations)
- PyMC/Stan for Bayesian mental model
- R's d/p/q/r naming for API intuition

**Timeline estimate:**
- Phase 1 (Core): 2-3 weeks (6 distributions, SIMPLE_PROBABILITY facade)
- Phase 2 (Inference): 2-3 weeks (MCMC, conjugate priors)
- Phase 3+ (Extended): Ongoing (more distributions, advanced algorithms)

---

## Open Questions for Requirements Phase

1. Should we support multivariate distributions (Multivariate Normal, Dirichlet) in Phase 1 or Phase 2?
2. How much numerical stability vs performance (reject sampling can be slow)?
3. Should MCMC support custom likelihoods (requires agents + first-class functions)?
4. What's our documentation strategy (Jupyter notebooks, Eiffel examples, mathematical tutorials)?

