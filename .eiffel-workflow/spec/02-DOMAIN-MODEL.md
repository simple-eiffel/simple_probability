# DOMAIN MODEL: simple_probability

## Domain Concepts

### Concept: Probability Distribution

**Definition:** A mathematical function that describes how probability is distributed over all possible values of a random variable. Encapsulates parameters and operations for a specific type of randomness.

**Attributes:**
- **Parameters** (immutable after creation)
  - Shape/location/scale parameters (e.g., μ and σ for Normal)
  - Domain constraints (e.g., Beta requires α > 0, β > 0)
- **Statistical properties**
  - Mean (expected value)
  - Variance (spread)
  - Skewness, kurtosis (optional)
- **Random seed** (for reproducible sampling)

**Behaviors:**
- **pdf(x)** — Compute probability density at value x
- **cdf(x)** — Compute cumulative probability P(X ≤ x)
- **icdf(p)** — Compute quantile (inverse CDF): what x gives P(X ≤ x) = p?
- **sample()** — Generate random draw from distribution
- **set_seed(seed)** — Make sampling reproducible

**Related to:**
- ContinuousDistribution (specialization for PDF-based)
- DiscreteDistribution (specialization for PMF-based)
- Bayesian Prior (distribution representing initial belief)
- Bayesian Posterior (distribution after updating with data)

**Will become:** `DISTRIBUTION` (abstract), `DISTRIBUTION_CONTINUOUS` (abstract), `DISTRIBUTION_DISCRETE` (abstract), and concrete classes: `NORMAL_DISTRIBUTION`, `UNIFORM_DISTRIBUTION`, etc.

---

### Concept: Continuous Distribution

**Definition:** Probability distribution over real-valued outcomes. Uses probability density function (PDF) and cumulative distribution function (CDF).

**Attributes:**
- Support (domain where PDF is non-zero)
  - Bounded (e.g., [0,1] for Beta)
  - Half-bounded (e.g., [0,∞) for Exponential)
  - Unbounded (e.g., (-∞,∞) for Normal)
- PDF function
- CDF function
- Mean and variance

**Behaviors:**
- `pdf(x)` — Probability density at x; ∫pdf = 1
- `cdf(x)` — Cumulative probability; cdf is non-decreasing
- `icdf(p)` — Inverse: if cdf(x) = p then icdf(p) = x
- `sample()` — Generate real-valued random sample
- `integrate_pdf()` — Verify PDF integrates to 1 (for testing)

**Will become:** `DISTRIBUTION_CONTINUOUS` (abstract base)

---

### Concept: Discrete Distribution

**Definition:** Probability distribution over integer-valued outcomes. Uses probability mass function (PMF) instead of PDF.

**Attributes:**
- Support (set of possible integer values)
  - Finite (e.g., {0, 1, ..., n} for Binomial)
  - Countably infinite (e.g., {0, 1, 2, ...} for Poisson)
- PMF function
- CDF function (sum of PMF)
- Mean and variance

**Behaviors:**
- `pmf(k)` — Probability mass at integer k; Σpmf = 1
- `cdf(k)` — Cumulative probability P(X ≤ k)
- `icdf(p)` — Inverse: smallest k such that cdf(k) ≥ p
- `sample()` — Generate integer-valued random sample

**Will become:** `DISTRIBUTION_DISCRETE` (abstract base)

---

### Concept: Normal Distribution (Continuous)

**Definition:** Bell-curve probability distribution; most important distribution in statistics. Characterized by mean μ and standard deviation σ.

**Parameters:**
- **μ (mean):** Location of center (can be any real number)
- **σ (standard deviation):** Spread; must be > 0

**Formula:**
- pdf(x) = (1/(σ√(2π))) * exp(-(x-μ)²/(2σ²))
- cdf(x) = Φ((x-μ)/σ) where Φ is standard normal CDF

**Attributes:**
- mean = μ
- variance = σ²
- support = (-∞, ∞)

**Behaviors:**
- Sample via Box-Muller transform (fast, accurate)
- CDF via error function approximation (fast)
- Inverse via rational approximation

**Will become:** `NORMAL_DISTRIBUTION`

---

### Concept: Beta Distribution (Continuous)

**Definition:** Distribution over [0,1]; conjugate prior for binomial likelihood. Used for modeling proportions, probabilities.

**Parameters:**
- **α (alpha):** Shape parameter 1; must be > 0
- **β (beta):** Shape parameter 2; must be > 0

**Formula:**
- pdf(x) = (x^(α-1) * (1-x)^(β-1)) / B(α,β) where B is beta function
- cdf(x) = Regularized incomplete beta function

**Attributes:**
- mean = α / (α + β)
- variance = (α*β) / ((α+β)² * (α+β+1))
- support = [0, 1]

**Behaviors:**
- Sample via rejection sampling or Dirichlet sampler
- CDF computed numerically
- Natural conjugate prior for Binomial

**Will become:** `BETA_DISTRIBUTION`

---

### Concept: Binomial Distribution (Discrete)

**Definition:** Distribution of number of successes in n independent trials, each with probability p. Likelihood for Beta prior.

**Parameters:**
- **n:** Number of trials; must be > 0
- **p:** Probability of success; must be ∈ [0,1]

**Formula:**
- pmf(k) = C(n,k) * p^k * (1-p)^(n-k) for k = 0..n
- cdf(k) = cumulative sum of pmf

**Attributes:**
- mean = n*p
- variance = n*p*(1-p)
- support = {0, 1, 2, ..., n}

**Behaviors:**
- Sample via inverse transform
- PMF via binomial coefficient calculation
- Natural likelihood for Beta prior

**Will become:** `BINOMIAL_DISTRIBUTION`

---

### Concept: Uniform Distribution (Continuous)

**Definition:** Flat probability distribution; all values in [a,b] equally likely.

**Parameters:**
- **a:** Lower bound
- **b:** Upper bound; must have a < b

**Formula:**
- pdf(x) = 1/(b-a) if x ∈ [a,b], else 0
- cdf(x) = (x-a)/(b-a)

**Attributes:**
- mean = (a+b)/2
- variance = (b-a)²/12
- support = [a, b]

**Behaviors:**
- Sample trivially (already uniform from RNG)
- PDF/CDF/ICDF are exact formulas
- Reference distribution (validates pattern)

**Will become:** `UNIFORM_DISTRIBUTION`

---

### Concept: Exponential Distribution (Continuous)

**Definition:** Distribution of time until next event; models waiting times, failure rates.

**Parameters:**
- **λ (lambda):** Rate parameter; must be > 0

**Formula:**
- pdf(x) = λ * exp(-λ*x) for x ≥ 0
- cdf(x) = 1 - exp(-λ*x)

**Attributes:**
- mean = 1/λ
- variance = 1/λ²
- support = [0, ∞)

**Behaviors:**
- Sample via inverse transform: -ln(u)/λ
- CDF exact formula
- Memoryless property (important for reliability)

**Will become:** `EXPONENTIAL_DISTRIBUTION`

---

### Concept: Bayesian Prior

**Definition:** A probability distribution representing initial belief before observing any data. Encodes domain knowledge or lack thereof.

**Attributes:**
- Underlying distribution (Normal, Beta, etc.)
- Parameters (already specified in distribution)

**Behaviors:**
- Update with data and likelihood to produce posterior
- Can be informative (strong belief) or uninformative (weak belief)
- Must integrate to 1 (valid probability)

**Related to:**
- Likelihood (what data produces)
- Posterior (result after updating)
- Conjugate prior (updates have closed form)

**Will become:** Uses `DISTRIBUTION`; role handled by instance usage pattern

---

### Concept: Bayesian Likelihood

**Definition:** A function describing how well a model (with given parameters) predicts observed data. P(data | parameters).

**Attributes:**
- Likelihood function (agent/closure): takes parameters and returns probability of data
- Numerically stable form (log-likelihood preferred)

**Behaviors:**
- Evaluate given parameters
- Combine with prior to compute posterior (via Bayes rule)
- Can be custom (user-defined) or standard (built-in)

**Related to:**
- Prior (belief before data)
- Posterior (belief after data)
- Data (observations used to update)

**Will become:** `BAYESIAN_LIKELIHOOD` interface or agent callback

---

### Concept: Bayesian Posterior

**Definition:** Probability distribution representing updated belief after observing data. Result of applying Bayes' rule: P(θ|data) ∝ P(data|θ) * P(θ).

**Attributes:**
- Distribution (same type as prior in conjugate case)
- Updated parameters
- Data that triggered update

**Behaviors:**
- Extract credible intervals (confidence bounds)
- Sample from posterior
- Use as prior for next update (sequential Bayesian)
- Compare to other posteriors (model selection)

**Related to:**
- Prior (starting belief)
- Likelihood (data model)
- Credible interval (confidence quantification)

**Will become:** Returns `DISTRIBUTION` (same type as prior)

---

### Concept: Credible Interval

**Definition:** Range [a, b] containing a specified probability mass from the posterior. Eiffel equivalent of Bayesian confidence interval.

**Attributes:**
- Lower bound (a)
- Upper bound (b)
- Probability mass (e.g., 0.95 for 95% credible interval)

**Behaviors:**
- Represent range of plausible parameter values
- Interpret: "95% of posterior probability is in [a,b]"
- Extract from posterior samples via percentiles

**Will become:** Simple return value (TUPLE or INTERVAL class)

---

## Concept Relationships

```
                      ┌──────────────────────────┐
                      │  DISTRIBUTION            │
                      │  (Abstract Base)         │
                      └────────────┬─────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
        ┌───────────▼────────────┐    ┌──────────▼──────────┐
        │ CONTINUOUS             │    │ DISCRETE            │
        │ (pdf, cdf, icdf)       │    │ (pmf, cdf, icdf)    │
        └────┬────┬────┬─────────┘    └──────┬──────┬───────┘
             │    │    │                      │      │
      ┌──────▼─┐  │    │         ┌────────────▼──┐   │
      │NORMAL  │  │    │         │  BINOMIAL     │   │
      └────────┘  │    │         └───────────────┘   │
                  │    │                              │
          ┌───────▼──┐ │                    ┌─────────▼────┐
          │UNIFORM   │ │                    │POISSON       │
          └──────────┘ │                    └──────────────┘
                       │
               ┌───────▼──────┐
               │BETA          │
               └──────────────┘
                       ▲
                       │ (conjugate prior for)
                       │
               ┌───────┴──────────┐
               │                  │
               │  ┌───────────────▼─────────┐
               │  │ BINOMIAL (likelihood)   │
               │  └─────────────────────────┘
               │
        ┌──────┴────────────────────────────┐
        │                                   │
┌───────▼─────────┐        ┌────────────────▼────┐
│ BAYESIAN_PRIOR  │        │ BAYESIAN_LIKELIHOOD │
│ (initial belief)│        │ (data model)        │
└────────┬────────┘        └────────────────┬────┘
         │                                  │
         └──────────────────┬───────────────┘
                            │
                            │ + data
                            │ + Bayes rule
                            ▼
                ┌─────────────────────────────┐
                │ BAYESIAN_POSTERIOR          │
                │ (updated belief)            │
                └──────────────┬──────────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
        ┌───────────▼──────┐  ┌──────────▼────────┐
        │CREDIBLE_INTERVAL │  │Next Update        │
        └──────────────────┘  │(sequential Bayes) │
                              └───────────────────┘
```

---

## Domain Rules

| Rule | Description | Enforcement | Eiffel Element |
|------|-------------|-------------|---|
| **DR-001** | Distribution parameters must be valid | Precondition checks | `create {X_DISTRIBUTION}.make(...)` requires |
| **DR-002** | PDF/PMF must be non-negative | Postcondition verification | `pdf(x)` ensures Result ≥ 0 |
| **DR-003** | PDF must integrate to ~1 | Invariant (statistical test) | `invariant pdf_integrates_to_1` |
| **DR-004** | CDF must be monotonically increasing | Postcondition | `cdf(x1) <= cdf(x2)` when x1 < x2 |
| **DR-005** | CDF bounds: cdf(-∞)=0, cdf(+∞)=1 | Postcondition bounds | `cdf(x)` ensures Result ∈ [0, 1] |
| **DR-006** | ICDF is inverse of CDF | Postcondition | `icdf(cdf(x)) ≈ x` within tolerance |
| **DR-007** | Sample must be in domain | Postcondition | `sample()` ensures in_domain(Result) |
| **DR-008** | Same seed → same samples | Postcondition reproducibility | `set_seed(s); sample() == set_seed(s); sample()` |
| **DR-009** | Prior must be valid distribution | Invariant | Prior satisfies rules DR-001 through DR-008 |
| **DR-010** | Posterior must integrate to 1 | Postcondition (Bayes rule) | `update()` ensures posterior.pdf integrates to 1 |
| **DR-011** | Likelihood must be non-negative | Precondition | Likelihood agent requires Result ≥ 0 |
| **DR-012** | Credible interval endpoints valid | Invariant | For 95% interval: P(a < θ < b) ≈ 0.95 |

---

## Glossary

| Term | Definition | Example |
|------|------------|---------|
| **PDF** | Probability Density Function | For Normal, pdf(x) = (1/(σ√(2π))) * exp(-(x-μ)²/(2σ²)) |
| **PMF** | Probability Mass Function | For Binomial, pmf(k) = C(n,k) * p^k * (1-p)^(n-k) |
| **CDF** | Cumulative Distribution Function | cdf(x) = P(X ≤ x); returns value ∈ [0,1] |
| **ICDF** | Inverse CDF / Quantile function | icdf(0.95) returns 95th percentile value |
| **Prior** | Initial belief before data | P(θ) in Bayes' rule |
| **Likelihood** | Probability of data given parameters | P(data \| θ) in Bayes' rule |
| **Posterior** | Updated belief after data | P(θ \| data) ∝ P(data \| θ) * P(θ) |
| **Conjugate Prior** | Prior that produces posterior of same form | Beta is conjugate prior for Binomial |
| **Credible Interval** | Range containing specified posterior probability | 95% interval contains 95% of posterior mass |
| **Mean** | Expected value of distribution | μ = ∫ x * pdf(x) dx |
| **Variance** | Measure of spread | σ² = ∫ (x - μ)² * pdf(x) dx |
| **Support** | Domain where distribution is defined | [0,1] for Beta, (-∞,∞) for Normal |
| **Shape Parameter** | Parameter controlling distribution shape | α, β for Beta; n, p for Binomial |
| **Box-Muller** | Algorithm to sample Normal from Uniform | Uses two uniform random values to generate Normal |
| **Inverse Transform** | Sampling algorithm using ICDF | sample = icdf(uniform(0,1)) |
| **Rejection Sampling** | Sampling by accepting/rejecting candidates | Used for Beta, complex distributions |
| **Bayes' Rule** | P(θ\|data) = P(data\|θ) * P(θ) / P(data) | Fundamental Bayesian updating formula |
| **Log-Likelihood** | Natural logarithm of likelihood | Numerically stable; used in MCMC |

---

## Summary

**Domain has two layers:**

1. **Distribution Layer** — Pure probability models
   - Distributions (Normal, Beta, Binomial, etc.)
   - Operations (pdf, cdf, icdf, sample)
   - Parameters and moments
   - Support and domain rules

2. **Bayesian Layer** — Statistical inference
   - Prior (initial belief as distribution)
   - Likelihood (data model)
   - Posterior (updated belief from Bayes rule)
   - Credible intervals (confidence quantification)

**Design principle:** Distributions are stateless (describe probability), Bayesian updating composes distributions via mathematical rules (prior * likelihood / normalizer).

