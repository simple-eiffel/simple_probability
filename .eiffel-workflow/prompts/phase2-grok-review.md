# Eiffel Contract Review - simple_probability (Grok - Security & Edge Cases)

You are a security-focused code reviewer specializing in numerical algorithms. Your task is to identify edge cases, boundary conditions, and potential runtime failures in Design by Contract specifications.

## Context: Previous Reviews

### Ollama Review
```
[PASTE OLLAMA RESPONSE HERE - see evidence/phase2-ollama-response.md]
```

### Claude Review
```
[PASTE CLAUDE RESPONSE HERE - see evidence/phase2-claude-response.md]
```

## Your Review Task

As the third reviewer (Grok), you specialize in **security, edge cases, and robustness**. Your focus:

1. **Edge Cases**: What happens at boundaries? (x=0, p=0, p=1, n=0, σ=ε, etc.)
2. **Numerical Stability**: Underflow, overflow, precision loss, NaN/Infinity handling
3. **Security**: Input validation gaps, denial of service risks, race conditions
4. **Error Handling**: What goes wrong if contracts are violated? What's the failure mode?
5. **Robustness**: Can the code survive bad inputs gracefully, or does it crash?

## Edge Case Analysis Framework

### Boundary Conditions (What happens at extremes?)

#### NORMAL_DISTRIBUTION
- **μ = ±∞**: Does pdf(x) work when mean is infinite?
- **σ = 0**: Blocked by precondition σ > 0 ✓, but what about σ → 0?
- **σ = 10^10 (max allowed)**: Does pdf(x) overflow for x = 0?
- **x = μ ± σ, μ ± 2σ, μ ± 3σ**: Special points where pdf peaks - test coverage?
- **Box-Muller edge case**: u1 → 0 means r → ∞ (or NaN if u1=0 exactly)
- **Seeding with s=0, s=max_int, s<0**: Undefined behavior?

#### UNIFORM_DISTRIBUTION
- **a = b**: Blocked by precondition a < b ✓, but what about a → b?
- **a → -∞, b → +∞**: Very wide ranges - precision loss in (x-a)/(b-a)?
- **pdf(x) for x outside [a,b]**: Should return 0, but does it?
- **Sampling exactly at a or b**: Can sample produce values outside [a,b]?

#### BINOMIAL_DISTRIBUTION
- **n = 0**: Blocked by precondition n > 0 ✓, but what if someone calls pmf(k) with k=0 and n=0?
- **p = 0**: All outcomes are 0 failures. pmf(0) = 1, pmf(k>0) = 0. Correct?
- **p = 1**: All outcomes are n successes. pmf(n) = 1, pmf(k<n) = 0. Correct?
- **n = 1,000,000**: Bernoulli loop is O(n) - sampling is slow but does it overflow?
- **C(n,k) computation**: Binomial coefficient can overflow even for moderate n. Example: C(100,50) ≈ 10^29.

#### EXPONENTIAL_DISTRIBUTION
- **λ = 0**: Blocked by precondition λ > 0 ✓
- **λ → 0**: Mean → ∞. Can sampling produce huge values? NaN?
- **λ = 10^10 (very large rate)**: Sample -ln(u)/λ → 0. Underflow?
- **x → ∞**: pdf(x) = λ*exp(-λ*x) → 0. Does it underflow to 0 or produce denormalized floats?
- **x → -∞**: pdf(x) = 0 (not in domain), but does precondition x_valid prevent negative x?

#### BETA_DISTRIBUTION
- **α, β → 0**: Beta function B(α,β) → ∞. Singularity.
- **α = β = 1**: Uniform on [0,1]. Are contracts correct for this case?
- **α >> β**: Distribution skews right. Sampling accuracy?
- **Regularized incomplete beta deferred to Phase 2**: How will icdf work in Phase 1 without accurate cdf?

### Numerical Stability Issues

#### Precision Loss
- **Normal CDF via standard_normal_cdf**: Placeholder returns 0.5. Will Normal.cdf tests pass?
- **Binomial coefficient C(n,k)**: Multiplicative formula vs factorial - which overflows first?
- **Beta function**: Uses gamma function - accuracy depends on simple_math.gamma implementation.

#### Underflow
- **exp(-λ*x)**: For large λ*x, this underflows to 0. Correct behavior but need to document.
- **-ln(u)**: For u → 1, ln(u) → 0, sampling → 0. For u → 0, ln(u) → -∞, sampling → ∞.
- **pdf at tail**: Normal pdf at x = μ + 10σ is ~10^-23. Underflow to denormalized float or 0?

#### Overflow
- **pdf normalization**: For Normal, σ*√(2π) - does this overflow?
- **Binomial coefficient**: C(100,50) ≈ 10^29, exceeds REAL_64 max (~10^308). Compute via log?
- **Mean/variance**: If σ = 10^10, then variance = 10^20. Representable in REAL_64?

### Security & Robustness

#### Input Validation Gaps
- **is_valid_for_pdf (x)**: What is this? Not defined in DISTRIBUTION. Is it implemented?
- **is_valid_for_cdf (x)**: Same issue.
- **next_samples_deterministic**: Postcondition is testable but what does it assert?

#### Denial of Service (DoS)
- **Binomial sampling with n = 10^9**: O(n) Bernoulli loop will hang the program.
- **Beta cdf (Phase 2)**: If implementation uses numerical integration, large n could be slow.
- **Seeding**: set_seed called repeatedly - any overhead?

#### Race Conditions (SCOOP)
- **internal_randomizer**: Each distribution owns it, no sharing ✓
- **math.make (once)**: Created once globally - thread-safe?
- **set_seed(s)**: If called from concurrent agents on same distribution, race condition?
  - Postcondition: `next_samples_deterministic` - means what? Next sample is deterministic?
  - If two agents call set_seed(1) then sample(), do they get same value? (Probably yes, and it's good)

### Implementation Feasibility Under Edge Cases

#### Can Phase 1 Contracts Be Satisfied?

| Class | Feature | Edge Case | Phase 1 Feasible? | Notes |
|-------|---------|-----------|-------------------|-------|
| NORMAL | pdf(x) | x = ±∞ | NO | pdf should be 0, but exp(-∞²) is undefined |
| NORMAL | cdf(x) | x = -∞ | YES | standard_normal_cdf(-∞) should be 0 |
| UNIFORM | pdf(x) | x < a or x > b | Unclear | Contract silent on pdf outside domain |
| BINOMIAL | sample | n = 10^6 | YES but slow | O(n) Bernoulli loop is correct but slow |
| EXPONENTIAL | sample | u = 1.0 exactly | Unlikely | u ~ [0,1), so u=1 won't occur |
| BETA | icdf(p) | All p | NO | cdf deferred to Phase 2, icdf can't work |

## Contract Issues to Investigate

### Red Flags (Investigate These)

1. **Deferred postconditions**: Beta.icdf has postcondition `result_in_domain` but icdf logic is not provided. How can we test?
2. **Placeholder implementations**: standard_normal_cdf returns 0.5. Normal.cdf tests will fail.
3. **Missing precondition details**: is_valid_for_pdf/cdf not defined - are they domain checks or validation?
4. **Frame condition silence**: Does set_seed change anything besides randomizer state? (parameters? mean? variance?)

### Green Lights (What's Good)

- ✓ Preconditions block invalid inputs (σ > 0, p ∈ [0,1], a < b)
- ✓ No shared mutable state (each distribution owns randomizer)
- ✓ Invariants protect state (σ > 0, α > 0 maintained)
- ✓ Sampling algorithms chosen are phase-appropriate (Box-Muller, Inverse, Bernoulli)

## Output Format

```markdown
## Grok Review Results (Security & Edge Cases)

### Edge Case Findings

#### Finding 1: [Edge Case Title]
- **Class.Feature**: [Where it occurs]
- **Edge Case**: [Description of boundary condition]
- **Risk Level**: CRITICAL / MAJOR / MINOR
- **Current Contract**: [What precondition/postcondition says]
- **Problem**: [Why it's a problem]
- **Suggested Fix**: [How to handle it]
- **Phase 1 Impact**: [Blocker/Important/Nice-to-Have]

#### Finding 2: [Edge Case Title]
[...etc...]

### Numerical Stability Assessment

| Issue | Category | Severity | Phase 1 Fix? |
|-------|----------|----------|--------------|
| Binomial overflow | Overflow | MAJOR | Add log-based computation |
| Beta cdf deferred | Missing | CRITICAL | Implement placeholder or skip tests |
| Normal cdf placeholder | Missing | CRITICAL | Implement rational approx before Phase 4 |
| exp underflow | Underflow | MINOR | Document expected behavior |

### SCOOP & Concurrency

| Concern | Status | Evidence |
|---------|--------|----------|
| Shared mutable state | SAFE | Each distribution owns randomizer |
| set_seed race condition | NEEDS ANALYSIS | If called concurrently, samples may not be deterministic |
| math.make (once) | TBD | Is simple_math.make thread-safe? |

### Validation Gaps

**Missing Definitions**:
- is_valid_for_pdf(x) - not defined anywhere
- is_valid_for_cdf(x) - not defined anywhere
- next_samples_deterministic - what does this verify?

**Phase 1 Severity**: HIGH - These gaps prevent test implementation

### Recommended Edge Case Tests

**High Priority (add to Phase 4 test suite)**:
1. Normal.pdf at x = μ, μ ± σ, μ ± 3σ (peak and tail)
2. Binomial with p=0, p=1 (degenerate cases)
3. Uniform boundary handling (x=a, x=b, x<a, x>b)
4. Exponential with very large λ (underflow test)

**Medium Priority**:
1. Seeding reproducibility with multiple distributions
2. Beta edge cases α,β → 0 (singularity)

**Nice to Have**:
1. Stress tests with extreme parameter ranges
2. Concurrent sampling stress test (SCOOP)

### Blocker for Phase 4?

**ASSESSMENT**: Potential blockers identified

1. **CRITICAL**: standard_normal_cdf/inverse_standard_normal_cdf are placeholders
   - **Impact**: Normal.cdf, Normal.icdf, and Normal.sample tests will fail
   - **Fix**: Implement Wichura rational approximation before Phase 4

2. **CRITICAL**: Beta.cdf deferred to Phase 2
   - **Impact**: Beta.icdf, BAYESIAN_UPDATER.credible_interval cannot work
   - **Fix**: Implement numerical integration or skip Beta from Phase 1

3. **MAJOR**: is_valid_for_pdf/cdf undefined
   - **Impact**: Preconditions are too weak (always true)
   - **Fix**: Define these methods in DISTRIBUTION

4. **MAJOR**: Binomial coefficient can overflow
   - **Impact**: pmf/cdf will produce infinity or NaN for moderate n
   - **Fix**: Use log-based computation or cap n < 100

### Recommendations

**Must Fix Before Phase 4**:
1. Implement standard_normal_cdf (Wichura approximation takes 2-3 hours)
2. Define is_valid_for_pdf/cdf in DISTRIBUTION base class
3. Add overflow protection to binomial_coefficient

**Nice to Have Before Phase 4**:
1. Document numerical stability (where underflow/overflow expected)
2. Add edge case tests for all distributions

**Defer to Phase 2**:
1. Beta.cdf via numerical integration
2. Binomial cdf via recurrence relation (faster than summation)

### Overall Security Posture

**Rating**: Medium (with critical fixes needed)

- **Input Validation**: Good (preconditions are tight)
- **Numerical Safety**: Needs work (placeholders, overflow risks)
- **Concurrency Safety**: Likely good (need to verify simple_math thread-safety)
- **Edge Case Handling**: Incomplete (deferred features block some distributions)
```

## Context

- **Phase**: Phase 2 Review (before implementation begins)
- **Goal**: Identify edge cases and numerical risks before code is written
- **Previous**: Ollama found contract gaps, Claude deepened analysis
- **Next**: Gemini will do final feasibility check
- **Finally**: We fix issues found and move to Phase 4 implementation

Focus on **realistic failure modes** and **implementability under edge cases**. A contract is only good if code can satisfy it!
