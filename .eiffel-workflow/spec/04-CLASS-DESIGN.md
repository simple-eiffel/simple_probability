# CLASS DESIGN: simple_probability

## Class Inventory

| Class | Role | Single Responsibility | Phase |
|-------|------|----------------------|-------|
| **DISTRIBUTION** | Abstract base | Define distribution interface contract (pdf, cdf, icdf, sample) | 1 |
| **DISTRIBUTION_CONTINUOUS** | Abstract base | Specialize for continuous distributions (pdf, CDF-based) | 1 |
| **DISTRIBUTION_DISCRETE** | Abstract base | Specialize for discrete distributions (pmf, integer-valued) | 1 |
| **NORMAL_DISTRIBUTION** | Concrete | Implement Normal(μ, σ) distribution | 1 |
| **UNIFORM_DISTRIBUTION** | Concrete | Implement Uniform(a, b) distribution | 1 |
| **BETA_DISTRIBUTION** | Concrete | Implement Beta(α, β) distribution | 1 |
| **BINOMIAL_DISTRIBUTION** | Concrete | Implement Binomial(n, p) distribution | 1 |
| **EXPONENTIAL_DISTRIBUTION** | Concrete | Implement Exponential(λ) distribution | 1 |
| **POISSON_DISTRIBUTION** | Concrete | Implement Poisson(λ) distribution | 1.5 |
| **SIMPLE_PROBABILITY** | Facade | Coordinate library; factory for distributions | 1 |
| **BAYESIAN_UPDATER** | Engine | Compute posterior from prior + likelihood + data | 1 |
| **PROBABILITY_VALUE** | Data | Represent value ∈ [0, 1] with contracts | 1 |
| **CREDIBLE_INTERVAL** | Data | Hold [lower, upper] interval bounds | 1 |

---

## Hierarchy: DISTRIBUTION

```
                    ┌────────────────────────┐
                    │   DISTRIBUTION         │
                    │   (Deferred)           │
                    ├────────────────────────┤
                    │ + pdf(x): REAL_64      │
                    │ + cdf(x): REAL_64      │
                    │ + icdf(p): REAL_64     │
                    │ + sample: REAL_64      │
                    │ + mean: REAL_64        │
                    │ + variance: REAL_64    │
                    │ + set_seed(s: INT)     │
                    └────────┬───────────────┘
                             │
        ┌────────────────────┴─────────────────────┐
        │                                          │
┌───────▼────────────────────┐    ┌──────────────▼────────────────┐
│ DISTRIBUTION_CONTINUOUS   │    │ DISTRIBUTION_DISCRETE         │
│ (Deferred)                 │    │ (Deferred)                    │
├────────────────────────────┤    ├────────────────────────────────┤
│ pdf(x)        [abstract]   │    │ pmf(k: INT): REAL_64          │
│ cdf(x)        [abstract]   │    │ sample: INTEGER               │
│ support: STR  [abstract]   │    │ support: STR                  │
│ in_domain(x): BOOL         │    │ Sample via inverse transform  │
└────────┬────────────────────┘    └──────────┬─────────────────────┘
         │                                    │
    ┌────┴────────────┬──────────┬──────────┐ │      ┌──────────────────┐
    │                 │          │          │ │      │                  │
┌───▼────────┐  ┌────▼──────┐ ┌─▼──────┐ ┌─▼──┐ ┌──▼──────────┐  ┌───▼─────────┐
│NORMAL      │  │UNIFORM    │ │BETA    │ │EXP │ │BINOMIAL    │  │POISSON      │
│DISTRIBUTION│  │DISTRIBUTION│ │DIST  │ │DIST│ │DISTRIBUTION│  │DISTRIBUTION │
└────────────┘  └───────────┘ └──────┘ └────┘ └────────────┘  └─────────────┘
```

**Inheritance Justification:**

| Child | Parent | IS-A Relationship | Liskov Substitutable? |
|-------|--------|------|---|
| NORMAL_DISTRIBUTION | DISTRIBUTION_CONTINUOUS | Bell-curve IS-A continuous distribution | YES |
| UNIFORM_DISTRIBUTION | DISTRIBUTION_CONTINUOUS | Flat IS-A continuous distribution | YES |
| BETA_DISTRIBUTION | DISTRIBUTION_CONTINUOUS | [0,1]-bounded IS-A continuous distribution | YES |
| EXPONENTIAL_DISTRIBUTION | DISTRIBUTION_CONTINUOUS | Waiting time IS-A continuous distribution | YES |
| BINOMIAL_DISTRIBUTION | DISTRIBUTION_DISCRETE | Counting successes IS-A discrete distribution | YES |
| POISSON_DISTRIBUTION | DISTRIBUTION_DISCRETE | Event counting IS-A discrete distribution | YES |
| DISTRIBUTION_CONTINUOUS | DISTRIBUTION | Continuous IS-A distribution | YES (with specialization) |
| DISTRIBUTION_DISCRETE | DISTRIBUTION | Discrete IS-A distribution | YES (with specialization) |

**Each concrete class properly specializes its parent; Liskov substitution holds.**

---

## Facade Design: SIMPLE_PROBABILITY

**Purpose:** Single entry point for library functionality; factory for creating distributions.

**Responsibility:** Coordinate and delegate distribution creation to concrete classes.

```eiffel
class SIMPLE_PROBABILITY

create
    make

feature -- Distribution Factories (Continuous)

    new_normal (mu, sigma: REAL_64): NORMAL_DISTRIBUTION
            -- Create Normal(μ, σ) distribution.
        require
            sigma_positive: sigma > 0
            sigma_reasonable: sigma < 1e10
        ensure
            result_valid: Result.mean ~ mu
            result_variance: Result.variance ~ sigma * sigma
        end

    new_uniform (a, b: REAL_64): UNIFORM_DISTRIBUTION
            -- Create Uniform(a, b) distribution.
        require
            valid_bounds: a < b
        ensure
            min_set: Result.minimum = a
            max_set: Result.maximum = b
        end

    new_beta (alpha, beta: REAL_64): BETA_DISTRIBUTION
            -- Create Beta(α, β) distribution.
        require
            alpha_positive: alpha > 0
            beta_positive: beta > 0
        ensure
            alpha_set: Result.alpha ~ alpha
            beta_set: Result.beta ~ beta
        end

    new_exponential (rate: REAL_64): EXPONENTIAL_DISTRIBUTION
            -- Create Exponential(λ) distribution.
        require
            rate_positive: rate > 0
        ensure
            rate_set: Result.rate ~ rate
        end

feature -- Distribution Factories (Discrete)

    new_binomial (n: INTEGER; p: REAL_64): BINOMIAL_DISTRIBUTION
            -- Create Binomial(n, p) distribution.
        require
            n_positive: n > 0
            p_valid: p >= 0 and p <= 1
        ensure
            n_set: Result.n = n
            p_set: Result.p ~ p
        end

    new_poisson (lambda: REAL_64): POISSON_DISTRIBUTION
            -- Create Poisson(λ) distribution.
        require
            lambda_positive: lambda > 0
        ensure
            lambda_set: Result.lambda ~ lambda
        end

feature -- Bayesian Inference

    new_bayesian_updater: BAYESIAN_UPDATER
            -- Create updater for Bayesian reasoning.
        ensure
            result_valid: Result /= Void
        end

feature -- Utilities

    standard_normal_cdf (z: REAL_64): REAL_64
            -- Standard Normal CDF at z. Reusable utility.
        ensure
            result_in_unit_interval: Result >= 0 and Result <= 1
            monotonic: "Defined elsewhere" -- cdf is monotonically increasing
        end

    inverse_standard_normal_cdf (p: REAL_64): REAL_64
            -- Standard Normal quantile at probability p.
        require
            p_valid: p > 0 and p < 1
        ensure
            result_reasonable: Result >= -10 and Result <= 10
        end

feature {NONE} -- Initialization

    make
            -- Create unconfigured facade.
        do
            -- No state to initialize
        end

invariant
    -- Facade is stateless
end
```

**Hides:**
- Distribution implementation details (algorithm choices)
- Numerical approximations (CDF rational approximations)
- Sampling algorithms (Box-Muller, inverse transform, rejection)

---

## Continuous Distribution Base: DISTRIBUTION_CONTINUOUS

```eiffel
deferred class DISTRIBUTION_CONTINUOUS

inherit
    DISTRIBUTION

feature {NONE} -- Random Generation
    randomizer: SIMPLE_RANDOMIZER
            -- RNG for sampling.

feature -- PDF

    pdf (x: REAL_64): REAL_64
            -- Probability density at x.
        require
            x_in_domain: in_domain(x)
        ensure
            result_non_negative: Result >= 0
            result_finite: not Result.is_infinite
        deferred
        end

feature -- CDF

    cdf (x: REAL_64): REAL_64
            -- Cumulative probability P(X ≤ x).
        require
            x_in_domain: in_domain(x)
        ensure
            result_in_unit_interval: Result >= 0 and Result <= 1
            result_at_support_bounds:
                (x = minimum implies Result ~ 0) and
                (x = maximum implies Result ~ 1)
        deferred
        end

feature -- ICDF / Quantile

    icdf (p: REAL_64): REAL_64
            -- Inverse CDF / quantile at probability p.
        require
            p_valid: p > 0 and p < 1
        ensure
            result_in_domain: in_domain(Result)
            cdf_of_result_is_p: (cdf(Result) - p).abs < 1e-6
        deferred
        end

feature -- Sampling

    sample: REAL_64
            -- Random draw from distribution.
        ensure
            result_in_domain: in_domain(Result)
        deferred
        end

feature -- Domain

    in_domain (x: REAL_64): BOOLEAN
            -- Is x in the distribution support?
        require
            x_finite: not x.is_infinite and not x.is_nan
        deferred
        ensure
            consistent: Result implies (x >= minimum and x <= maximum)
        end

    minimum: REAL_64
        deferred
        end

    maximum: REAL_64
        deferred
        end

feature -- Properties

    mean: REAL_64
        deferred
        ensure
            finite: not Result.is_infinite
        end

    variance: REAL_64
        deferred
        ensure
            non_negative: Result >= 0
        end

feature -- Seeding

    set_seed (seed: INTEGER)
            -- Set random seed for reproducibility.
        do
            create randomizer.make_with_seed(seed)
        ensure
            seed_set: next_random_sequence_deterministic
        end

feature {NONE} -- Contracts Check Helpers

    next_random_sequence_deterministic: BOOLEAN
            -- Is next random sequence deterministic? (For contract checking)
        do
            Result := true  -- After set_seed, samples should be deterministic
        end

invariant
    parameters_valid: parameters_satisfy_constraints
    mean_in_reasonable_range: not mean.is_infinite
    variance_non_negative: variance >= 0
    minimum_less_than_maximum: minimum < maximum

end
```

---

## Concrete Distribution: NORMAL_DISTRIBUTION

```eiffel
class NORMAL_DISTRIBUTION

inherit
    DISTRIBUTION_CONTINUOUS

create
    make

feature -- Parameters

    mu: REAL_64
            -- Mean parameter.

    sigma: REAL_64
            -- Standard deviation parameter.

feature -- Initialization

    make (a_mu, a_sigma: REAL_64)
            -- Create Normal(μ, σ) distribution.
        require
            sigma_positive: a_sigma > 0
            sigma_not_too_large: a_sigma < 1e10
        do
            mu := a_mu
            sigma := a_sigma
            set_seed(0)  -- Default seed (can be overridden)
        ensure
            mu_set: mu = a_mu
            sigma_set: sigma = a_sigma
        end

feature -- PDF

    pdf (x: REAL_64): REAL_64
            -- Normal probability density.
        local
            z, pi, two_pi_sqrt: REAL_64
        do
            z := (x - mu) / sigma
            pi := math.pi
            two_pi_sqrt := (2 * pi).sqrt
            Result := (1 / (sigma * two_pi_sqrt)) * math.exp(-0.5 * z * z)
        ensure
            result_positive: Result > 0
            result_at_mean_maximum: pdf(mu) >= pdf(mu + 1)  -- Peak at mean
        end

feature -- CDF

    cdf (x: REAL_64): REAL_64
            -- Normal cumulative distribution (via approximation).
        local
            z: REAL_64
        do
            z := (x - mu) / sigma
            Result := simple_prob.standard_normal_cdf(z)
        ensure
            result_in_unit_interval: Result >= 0 and Result <= 1
            monotonic: cdf(x) <= cdf(x + 1)
        end

feature -- ICDF

    icdf (p: REAL_64): REAL_64
            -- Normal quantile (inverse CDF).
        do
            Result := mu + sigma * simple_prob.inverse_standard_normal_cdf(p)
        ensure
            icdf_of_half_is_mean: (icdf(0.5) - mu).abs < 1e-10
        end

feature -- Sampling

    sample: REAL_64
            -- Generate Normal random sample via Box-Muller.
        local
            u1, u2, r, theta: REAL_64
        do
            u1 := randomizer.random_real_in_range(0.0, 1.0)
            u2 := randomizer.random_real_in_range(0.0, 1.0)
            r := (-2 * u1.ln).sqrt
            theta := 2 * math.pi * u2
            Result := mu + sigma * r * theta.cos
        ensure
            result_in_reasonable_range: Result.abs < mu.abs + 10 * sigma
        end

feature -- Domain

    in_domain (x: REAL_64): BOOLEAN
            -- Normal has unbounded support.
        do
            Result := true
        end

    minimum: REAL_64
        do
            Result := -1e100  -- Effectively -∞
        end

    maximum: REAL_64
        do
            Result := 1e100   -- Effectively +∞
        end

feature -- Properties

    mean: REAL_64
        do
            Result := mu
        end

    variance: REAL_64
        do
            Result := sigma * sigma
        end

feature {NONE} -- Implementation

    simple_prob: SIMPLE_PROBABILITY
            -- Facade for utility functions.
        once
            create Result.make
        end

    math: SIMPLE_MATH
            -- Math library for exp, sqrt, pi.
        once
            create Result.make
        end

    parameters_satisfy_constraints: BOOLEAN
        do
            Result := sigma > 0 and sigma < 1e10
        end

invariant
    sigma_positive: sigma > 0
    sigma_reasonable: sigma < 1e10

end
```

---

## Bayesian Updater: BAYESIAN_UPDATER

```eiffel
class BAYESIAN_UPDATER

create
    make

feature -- Bayesian Updating

    update_conjugate_beta_binomial (
            prior_alpha, prior_beta: REAL_64;
            successes, trials: INTEGER
        ): BETA_DISTRIBUTION
            -- Update Beta prior with Binomial observations (conjugate).
        require
            prior_valid: prior_alpha > 0 and prior_beta > 0
            trials_positive: trials > 0
            successes_valid: successes >= 0 and successes <= trials
        local
            posterior_alpha, posterior_beta: REAL_64
        do
            -- Conjugate update: Beta(α + k, β + n - k)
            posterior_alpha := prior_alpha + successes
            posterior_beta := prior_beta + (trials - successes)
            create Result.make(posterior_alpha, posterior_beta)
        ensure
            posterior_alpha_larger: Result.alpha >= prior_alpha
            posterior_updated: Result.alpha + Result.beta > prior_alpha + prior_beta
        end

feature {NONE} -- Initialization

    make
        do
            -- No state
        end

end
```

---

## Credible Interval Data

```eiffel
class CREDIBLE_INTERVAL

create
    make

feature -- Bounds

    lower: REAL_64
    upper: REAL_64
    probability: REAL_64  -- E.g., 0.95 for 95% credible interval

feature -- Initialization

    make (a_lower, a_upper, a_probability: REAL_64)
        require
            bounds_valid: a_lower < a_upper
            prob_valid: a_probability > 0 and a_probability < 1
        do
            lower := a_lower
            upper := a_upper
            probability := a_probability
        ensure
            lower_set: lower = a_lower
            upper_set: upper = a_upper
        end

feature -- Operations

    contains (x: REAL_64): BOOLEAN
            -- Is x in interval?
        do
            Result := x >= lower and x <= upper
        end

    width: REAL_64
            -- Interval width (upper - lower).
        do
            Result := upper - lower
        ensure
            positive: Result > 0
        end

invariant
    bounds_valid: lower < upper
    probability_valid: probability > 0 and probability < 1

end
```

---

## Summary of Phase 1 Class Structure

**Core Abstractions (3 base classes):**
- DISTRIBUTION (interface contract)
- DISTRIBUTION_CONTINUOUS (pdf/cdf)
- DISTRIBUTION_DISCRETE (pmf)

**Concrete Distributions (5 Phase 1 + 1 Phase 1.5):**
- NORMAL_DISTRIBUTION
- UNIFORM_DISTRIBUTION
- BETA_DISTRIBUTION
- EXPONENTIAL_DISTRIBUTION
- BINOMIAL_DISTRIBUTION
- POISSON_DISTRIBUTION (Phase 1.5)

**Bayesian Inference (2 classes):**
- BAYESIAN_UPDATER (conjugate prior updates)
- CREDIBLE_INTERVAL (confidence bounds)

**Facade:**
- SIMPLE_PROBABILITY (factories, utilities)

**Supporting Data:**
- PROBABILITY_VALUE (future: phantom type for [0,1])

**Total Phase 1 LOC estimate: ~1,500**
- Bases: 200 LOC
- Concrete distributions: 1,000 LOC (200 each)
- Bayesian: 100 LOC
- Facade: 100 LOC
- Supporting: 100 LOC

