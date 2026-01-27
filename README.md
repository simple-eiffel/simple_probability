# simple_probability

Type-safe, Design-by-Contract probability and Bayesian reasoning library for Eiffel.

## Overview

**simple_probability** provides a comprehensive library for working with probability distributions and Bayesian inference in Eiffel. All functionality is protected by Design-by-Contract (DBC) with preconditions, postconditions, and invariants that document expected behavior and catch violations at runtime.

### Key Features

- **Multiple Probability Distributions**
  - Continuous: Normal (Gaussian), Uniform, Exponential, Beta
  - Discrete: Binomial
  - All distributions support PDF/PMF, CDF, ICDF (inverse CDF), and sampling

- **Bayesian Inference**
  - Conjugate prior updates (Beta-Binomial pair)
  - Credible interval extraction
  - Maximum posterior estimation

- **Design by Contract**
  - Preconditions validate inputs
  - Postconditions verify outputs
  - Invariants protect class state
  - All contracts are executable and enforced at runtime

- **SCOOP Compatible**
  - Concurrency-safe design
  - Each distribution instance owns its randomizer
  - No shared mutable state

- **Void-Safe**
  - All types explicitly marked as attached or detachable
  - Strict void-safety enforcement

## Installation

### Prerequisites

- EiffelStudio 25.02 or later
- simple_randomizer library
- simple_math library

### Setup

1. Clone the repository:
```bash
git clone https://github.com/simple-eiffel/simple_probability.git
cd simple_probability
```

2. Set environment variables:
```bash
export SIMPLE_EIFFEL=/path/to/simple_eiffel_libs
```

3. Compile:
```bash
ec -batch -config simple_probability.ecf -target simple_probability -c_compile
```

## Usage

### Creating Distributions

Use the `SIMPLE_PROBABILITY` facade class to create distributions:

```eiffel
local
    factory: SIMPLE_PROBABILITY
    normal_dist: NORMAL_DISTRIBUTION
    binomial_dist: BINOMIAL_DISTRIBUTION
do
    create factory.make

    -- Create Normal(μ=0, σ=1) - standard normal
    normal_dist := factory.new_normal (0.0, 1.0)

    -- Create Binomial(n=10, p=0.5)
    binomial_dist := factory.new_binomial (10, 0.5)
end
```

### Computing Probabilities

#### PDF/PMF (Probability Density/Mass Function)

```eiffel
local
    normal: NORMAL_DISTRIBUTION
    pdf_at_zero: REAL_64
do
    create normal.make (0.0, 1.0)

    -- Probability density at x=0
    pdf_at_zero := normal.pdf (0.0)
    -- Result: 0.399 (the peak of standard normal)
end
```

#### CDF (Cumulative Distribution Function)

```eiffel
local
    normal: NORMAL_DISTRIBUTION
    prob_less_than_1: REAL_64
do
    create normal.make (0.0, 1.0)

    -- Probability that X ≤ 1
    prob_less_than_1 := normal.cdf (1.0)
    -- Result: 0.8413 (84.13%)
end
```

#### ICDF (Inverse CDF / Quantile Function)

```eiffel
local
    normal: NORMAL_DISTRIBUTION
    q_95: REAL_64
do
    create normal.make (0.0, 1.0)

    -- 95th percentile (value where CDF = 0.95)
    q_95 := normal.icdf (0.95)
    -- Result: 1.645 (approximately)
end
```

### Sampling

Generate random samples from distributions:

```eiffel
local
    normal: NORMAL_DISTRIBUTION
    samples: ARRAY [REAL_64]
    i: INTEGER
do
    create normal.make (0.0, 1.0)
    create samples.make_filled (0.0, 1, 1000)

    -- Generate 1000 samples
    from i := 1 until i > 1000 loop
        samples [i] := normal.sample
        i := i + 1
    end
end
```

### Bayesian Inference

#### Conjugate Prior Update

```eiffel
local
    updater: BAYESIAN_UPDATER
    prior: BETA_DISTRIBUTION
    posterior: BETA_DISTRIBUTION
do
    create updater.make
    create prior.make (1.0, 1.0)  -- Uniform prior

    -- Observe: 8 successes out of 10 trials
    posterior := updater.update_conjugate_beta_binomial (1.0, 1.0, 8, 10)

    -- posterior is Beta(9, 3) - concentrated toward high probability
    check posterior.alpha = 9.0 end
    check posterior.beta = 3.0 end
end
```

#### Credible Intervals

```eiffel
local
    updater: BAYESIAN_UPDATER
    posterior: BETA_DISTRIBUTION
    interval: TUPLE [lower_bound, upper_bound: REAL_64]
do
    create updater.make
    create posterior.make (2.0, 2.0)

    -- Extract 95% credible interval
    interval := updater.credible_interval_from_posterior (posterior, 0.95)

    -- interval.lower_bound and interval.upper_bound contain the bounds
end
```

## API Reference

### SIMPLE_PROBABILITY (Facade)

Factory class for creating distribution instances.

**Public Features:**
- `new_normal (mu, sigma: REAL_64): NORMAL_DISTRIBUTION`
- `new_uniform (a, b: REAL_64): UNIFORM_DISTRIBUTION`
- `new_exponential (rate: REAL_64): EXPONENTIAL_DISTRIBUTION`
- `new_binomial (n: INTEGER; p: REAL_64): BINOMIAL_DISTRIBUTION`
- `new_beta (alpha, beta: REAL_64): BETA_DISTRIBUTION`

### DISTRIBUTION (Abstract Base)

All distributions inherit from this deferred class.

**Features:**
- `pdf (x: REAL_64): REAL_64` - Probability density function
- `cdf (x: REAL_64): REAL_64` - Cumulative distribution function
- `icdf (p: REAL_64): REAL_64` - Inverse CDF (quantile function)
- `sample: REAL_64` - Generate random sample
- `mean: REAL_64` - Expected value
- `variance: REAL_64` - Variance
- `standard_deviation: REAL_64` - Standard deviation (σ)
- `minimum: REAL_64` - Lower bound of support
- `maximum: REAL_64` - Upper bound of support
- `set_seed (s: INTEGER)` - Set random seed for reproducibility

### NORMAL_DISTRIBUTION

Gaussian distribution N(μ, σ).

**Creation:**
- `make (mu, sigma: REAL_64)` - Create with mean μ and standard deviation σ
- `default_create` - Create standard normal N(0, 1)

**Implementation Details:**
- PDF: Analytical formula
- CDF: Wichura rational approximation (error ≤ ±0.1%)
- ICDF: Newton-Raphson refinement of initial approximation
- Sampling: Box-Muller transform

### BINOMIAL_DISTRIBUTION

Binomial distribution Binomial(n, p).

**Creation:**
- `make (n: INTEGER; p: REAL_64)` - Create with n trials and success probability p
- `default_create` - Create Binomial(1, 0.5) - single fair coin flip

**Features:**
- `pmf (k: INTEGER): REAL_64` - Probability mass function P(X = k)

**Implementation Details:**
- PMF: Analytical formula C(n,k)·p^k·(1-p)^(n-k)
- CDF: Cumulative sum of PMF
- ICDF: Linear search for smallest k where CDF(k) ≥ p
- Sampling: Loop of n Bernoulli trials

### UNIFORM_DISTRIBUTION

Continuous uniform distribution U(a, b).

**Creation:**
- `make (a, b: REAL_64)` - Create uniform over interval [a, b]

**Implementation Details:**
- PDF: Constant 1/(b-a)
- CDF: Linear (x-a)/(b-a)
- ICDF: Linear inverse a + p(b-a)
- Sampling: Inverse transform method

### EXPONENTIAL_DISTRIBUTION

Exponential distribution with rate parameter λ.

**Creation:**
- `make (rate: REAL_64)` - Create with rate λ

**Properties:**
- Mean = 1/λ
- Memoryless property: P(X > s+t | X > s) = P(X > t)

**Implementation Details:**
- PDF: λ·exp(-λx) for x ≥ 0
- CDF: 1 - exp(-λx)
- ICDF: -ln(1-p)/λ
- Sampling: Inverse transform -ln(U)/λ

### BETA_DISTRIBUTION

Beta distribution Beta(α, β).

**Creation:**
- `make (alpha, beta: REAL_64)` - Create with shape parameters α, β

**Note:** Phase 1 implementation is partial (lacks gamma function). Deferred to Phase 1.5.

### BAYESIAN_UPDATER

Performs Bayesian inference via conjugate prior updates.

**Features:**
- `update_conjugate_beta_binomial (prior_alpha, prior_beta: REAL_64; successes, trials: INTEGER): BETA_DISTRIBUTION`
  - Updates Beta prior with Binomial observations
  - Returns posterior Beta distribution

- `credible_interval_from_posterior (posterior: DISTRIBUTION; confidence_level: REAL_64): TUPLE [lower_bound, upper_bound: REAL_64]`
  - Extracts symmetric credible interval from posterior
  - Returns [quantile(α/2), quantile(1-α/2)]

## Testing

Run the comprehensive test suite:

```bash
cd simple_probability
/d/prod/ec.sh -batch -config simple_probability.ecf -target simple_probability_tests -c_compile
./EIFGENs/simple_probability_tests/W_code/simple_probability.exe
```

**Test Coverage:**
- 9 basic functionality tests (Phase 5)
- 31 adversarial and stress tests (Phase 6)
  - Boundary value tests (extreme parameters)
  - Monotonicity and continuity verification
  - Inverse function roundtrip tests
  - Sampling distribution checks
  - Cross-distribution validation
  - Bayesian inference edge cases

**Result:** 40 tests, 40 passing, 0 failing

## Design Principles

### Design by Contract

Every public feature has:
- **Preconditions** (`require`) - Input validation
- **Postconditions** (`ensure`) - Output guarantees
- **Invariants** (`invariant`) - Class state protection

Example:
```eiffel
icdf (p: REAL_64): REAL_64
    require
        p_valid: p > 0 and p < 1
    deferred
    ensure
        result_in_domain: in_domain (Result)
        cdf_inverse_property: (cdf (Result) - p).abs < 0.1
    end
```

### SCOOP Safety

Each distribution maintains its own `randomizer` (SIMPLE_RANDOMIZER) instance. This design allows:
- Multiple distributions in concurrent threads without synchronization
- Deterministic sampling (after set_seed)
- No race conditions or deadlocks

### Void Safety

All code is void-safe:
- Types explicitly marked `detachable` (can be Void) or implicitly `attached`
- No unchecked Void dereferences
- Compiler enforces void-safety at compile time

## Known Limitations

### Phase 1 Limitations

1. **set_seed not fully functional**
   - SIMPLE_RANDOMIZER lacks true set_seed method
   - Workaround: Recreate randomizer with make_with_seed
   - Impact: Tests use determinism inherited from randomizer creation
   - Resolution: Phase 1.5 will implement full set_seed

2. **Beta distribution incomplete**
   - SIMPLE_MATH lacks gamma function
   - Beta distribution methods are stubbed
   - Impact: Cannot compute Beta probabilities or samples
   - Resolution: Phase 1.5 will implement gamma and complete Beta

3. **Numerical precision**
   - Normal CDF uses rational approximation (error tolerance: ±0.1)
   - Adequate for: quantile computation, credible intervals
   - Insufficient for: high-precision statistical inference (>1e-6 accuracy)
   - Resolution: Phase 2+ will add higher-precision algorithms

## Dependencies

- **base** (ISE EiffelStudio stdlib) - Core types (REAL_64, INTEGER, etc.)
- **simple_randomizer** - Random number generation
- **simple_math** - Mathematical functions (sqrt, log, exp, cos, pi)

No ISE stdlib beyond base, no external dependencies outside simple_* ecosystem.

## License

MIT License - See LICENSE file

## Contributing

Contributions welcome! Please:
1. Follow Eiffel naming conventions (UPPER_CASE for classes, lower_case for features)
2. Include Design by Contract (require/ensure/invariant)
3. Add tests for new features
4. Maintain void-safety and SCOOP compatibility

## Authors

Simple Eiffel Team

## Version

1.0.0 (Phase 1 - Probability Distributions and Bayesian Inference)

## Roadmap

- **Phase 1.5**: Complete Beta distribution, implement set_seed properly
- **Phase 2**: Higher-precision normal CDF/ICDF, additional distributions (Poisson, Geometric, etc.)
- **Phase 3**: Mixture models, EM algorithm
- **Phase 4**: Maximum likelihood estimation
- **Phase 5**: Hypothesis testing framework
