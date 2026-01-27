# Implementation Approach: simple_probability Phase 1

## Overview

Implement 10 Eiffel classes with full Design-by-Contract specifications for accessible, type-safe probability distributions and Bayesian inference. Phase 1 delivers 5 continuous distributions (Normal, Uniform, Beta, Exponential) + 1 discrete (Binomial) + supporting classes + 50+ tests.

## Implementation Strategy

### Distribution Classes (Priority Order)

#### 1. NORMAL_DISTRIBUTION (Weeks 1)
- **Status**: Critical path
- **Complexity**: Medium
- **pdf()**: Standard formula (1/(σ√(2π))) * exp(-(x-μ)²/(2σ²))
- **cdf()**: Use error function or rational approximation (Abramowitz & Stegun)
- **icdf()**: Inverse via error function (e.g., Hart algorithm)
- **sample()**: Box-Muller transform (u1, u2 uniform → polar coordinates)
- **Dependencies**: simple_math (exp, sqrt, pi), simple_randomizer (random_real_in_range)
- **Tests**: 9 unit tests + 3 statistical tests
- **Acceptance**: All 12 tests pass, ±1e-6 accuracy vs SciPy

#### 2. UNIFORM_DISTRIBUTION (Week 1)
- **Status**: Low complexity, quick win
- **pdf()**: 1/(b-a) if x ∈ [a,b], else 0 (analytical)
- **cdf()**: (x-a)/(b-a) if x ∈ [a,b]
- **icdf()**: a + p*(b-a) (analytical)
- **sample()**: Inverse transform: a + u*(b-a) where u ~ U(0,1)
- **Dependencies**: simple_randomizer
- **Tests**: 8 unit tests
- **Acceptance**: All tests pass, analytical formulas verified

#### 3. BINOMIAL_DISTRIBUTION (Week 1)
- **Status**: Discrete, medium complexity
- **pmf()**: C(n,k) * p^k * (1-p)^(n-k) using binomial_coefficient
- **pdf()**: Wrapper returning pmf() for consistency with interface
- **cdf()**: Sum of pmf from 0 to floor(x)
- **icdf()**: Find smallest k where cdf(k) >= p
- **sample()**: Bernoulli trials loop (count successes in n trials)
- **Helpers**: binomial_coefficient (multiplicative formula)
- **Dependencies**: simple_randomizer
- **Tests**: 10 unit tests
- **Acceptance**: All tests pass, samples match chi-squared distribution test

#### 4. EXPONENTIAL_DISTRIBUTION (Week 2)
- **Status**: Medium complexity
- **pdf()**: λ * exp(-λ*x) for x ≥ 0
- **cdf()**: 1 - exp(-λ*x)
- **icdf()**: -ln(1-p) / λ
- **sample()**: Inverse transform: -ln(u) / λ
- **Dependencies**: simple_math (ln, exp), simple_randomizer
- **Tests**: 8 unit tests
- **Acceptance**: All tests pass, moment matching (mean = 1/λ)

#### 5. BETA_DISTRIBUTION (Week 2)
- **Status**: High complexity, Bayesian critical
- **pdf()**: [x^(α-1) * (1-x)^(β-1)] / B(α,β) where B is beta function
- **cdf()**: Regularized incomplete beta (numerical integration or approximation)
- **icdf()**: Inverse via Newton-Raphson on regularized incomplete beta
- **sample()**: Gamma-ratio method: Gamma(α) / (Gamma(α) + Gamma(β))
- **Helpers**: beta_function using gamma function, regularized_incomplete_beta
- **Dependencies**: simple_math (gamma function), simple_randomizer
- **Tests**: 10 unit tests + convergence tests
- **Acceptance**: Beta-Binomial conjugate pair validated empirically

#### 6. SIMPLE_PROBABILITY (Week 2)
- **Status**: Factory, straightforward
- **Factories**: new_normal, new_uniform, new_beta, new_binomial, new_exponential
- **Utilities**: standard_normal_cdf, inverse_standard_normal_cdf (placeholders)
- **Dependencies**: None (just delegates to distribution constructors)
- **Tests**: 5 integration tests
- **Acceptance**: All factories create correct distributions

#### 7. BAYESIAN_UPDATER (Week 2)
- **Status**: Core inference, conjugate formula implementation
- **update_conjugate_beta_binomial**: Beta(α + k, β + n - k)
- **credible_interval_from_posterior**: Symmetric CI from icdf
- **Dependencies**: DISTRIBUTION interface
- **Tests**: 6 unit tests (Beta-Binomial conjugacy verification)
- **Acceptance**: Posterior matches analytical formula

### Test Strategy

#### Unit Tests (40 tests across all distributions)
Per distribution (8-10 tests):
- **Creation**: make, default_create
- **PDF/PMF**: positivity, peak location (mode)
- **CDF**: bounds, monotonicity, boundary values
- **ICDF**: median, quantile properties
- **Sampling**: domain check, seeding reproducibility
- **Integration**: end-to-end workflow

#### Statistical Tests (Phase 5 - deferred for now)
- **KS test**: samples match theoretical distribution (p > 0.05)
- **Chi-squared**: pmf for discrete distributions
- **Moment matching**: computed mean/variance vs theoretical

#### SCOOP Tests (Phase 5)
- 4 independent agents, 1000 samples each
- Zero data races, deterministic with same seed

### Numerical Implementation Details

#### Normal Distribution CDF
Options (choose one):
1. **Rational approximation** (Wichura): ±7 decimal places, fast
2. **Error function**: Use simple_math erf if available
3. **Series expansion**: Taylor series (slower but accurate)
Recommended: Rational approximation for Phase 1 (good speed/accuracy)

#### Beta Distribution CDF
Options:
1. **Numerical integration**: Simpson's rule via simple_math
2. **Continued fraction**: Accelerated convergence
3. **Series expansion**: Beta-binomial series
Recommended: Numerical integration via simple_math (if available), else deferred to Phase 2

#### Sampling Algorithms

| Distribution | Algorithm | Complexity | Phase |
|---|---|---|---|
| Normal | Box-Muller (θ = 2π*u2, r = √(-2ln(u1))) | O(1) | 1 |
| Uniform | Inverse (a + u*(b-a)) | O(1) | 1 |
| Beta | Gamma-ratio (Gamma(α)/Gamma(α+β)) | O(α+β) | 2* |
| Binomial | Bernoulli loop (count successes) | O(n) | 1 |
| Exponential | Inverse (-ln(u)/λ) | O(1) | 1 |

*Phase 2: Beta currently uses simplified method, Phase 2 upgrades to proper Gamma-ratio

### Contract Implementation

#### Preconditions (Defensive)
Check all parameter validity before execution:
- σ > 0, σ < 10^10 (avoid overflow)
- p ∈ [0, 1] for Binomial
- α > 0, β > 0 for Beta
- a < b for Uniform
- λ > 0 for Exponential

#### Postconditions (Verification)
Verify computed results match contracts:
- pdf(x) ≥ 0, finite
- cdf(x) ∈ [0, 1], monotonic
- icdf(p) in domain
- sample() in domain, not NaN
- mean finite, variance ≥ 0

#### Invariants (State Consistency)
Maintain valid state across all operations:
- min < max (bounds valid)
- seed ≥ 0
- randomizer initialized
- parameters satisfy constraints

### Dependencies & Integration

| Need | Library | API Expected | Phase |
|---|---|---|---|
| Random sampling | simple_randomizer | random_real_in_range(0.0, 1.0): REAL_64 | 1 |
| Math functions | simple_math | exp, ln, sqrt, pi, gamma | 1 |
| Error function | simple_math (optional) | erf | 2* |
| Integration | simple_math (optional) | numerical_integrate | 2* |
| Test framework | simple_testing | TEST_SET_BASE | 1 |

*Phase 2: If not available in Phase 1, implement placeholder or use approximation

### Error Handling

#### Precondition Violations
- **Strategy**: Fail fast via precondition assertions
- **Action**: Developer fixes call site (correct parameters)
- **Phase 1**: No exception handling (design by contract)
- **Phase 2**: Optional exception bridge for robustness

#### Numerical Issues
- **NaN/Infinity**: Contract postcondition catches (result_finite clause)
- **Underflow**: Use log-space computation for small probabilities
- **Overflow**: Clamp large values, warn in documentation

### Quality Targets

| Metric | Target | Verification |
|---|---|---|
| **Test Coverage** | 90%+ | EQA coverage report |
| **Accuracy (pdf/cdf)** | ±1e-6 vs SciPy | Unit test assertions |
| **Sampling Distribution** | KS test p > 0.05 | Statistical test (Phase 5) |
| **Reproducibility** | Same seed → identical sequence | Seeding tests |
| **Performance** | <1ms per sample, <100μs per pdf | Benchmark (Phase 5) |

### Risk Mitigation

| Risk | Mitigation | Phase |
|---|---|---|
| **Numerical instability** | Test vs SciPy, use log-space | 1 |
| **Missing dependencies** | Verify simple_randomizer/simple_math APIs early | Week 1 |
| **Contract violations** | Unit tests for all preconditions | 1 |
| **SCOOP data races** | Each distribution owns randomizer | 1 |
| **API mismatch** | Integration tests for factories | 1 |

### Timeline

| Week | Deliverable | Status |
|---|---|---|
| **1** | Normal, Uniform, Binomial complete + tests passing | Critical path |
| **2** | Beta, Exponential, SIMPLE_PROBABILITY, BAYESIAN_UPDATER complete | Ready |
| **3** | All 50+ tests passing, documentation, bug fixes | Ship v1.0.0 |
| **4** | Phase 1.5: Poisson distribution (optional) | If time permits |

### Success Criteria (Phase 1 Ship)

- [ ] All 5 distributions compile without warnings
- [ ] 50+ unit tests pass, 90%+ code coverage
- [ ] PDF/CDF accurate to ±1e-6 vs SciPy reference
- [ ] Sampling passes basic distribution checks
- [ ] SCOOP compatibility verified (4 agents concurrent sampling)
- [ ] Documentation complete (README, examples, API docs)
- [ ] v1.0.0 tagged and released

---

**Status: Ready for Implementation**

Contracts specify all behavior. Implementation fills in method bodies while keeping contracts frozen. Estimated effort: 2-3 weeks for Phase 1 MVP.
