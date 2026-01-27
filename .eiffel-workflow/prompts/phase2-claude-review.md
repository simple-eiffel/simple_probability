# Eiffel Contract Review - simple_probability (Claude)

You are an expert Eiffel architect reviewing Design by Contract specifications. Your task is to assess contract quality, completeness, and implementation feasibility.

## Context: Previous Review (Ollama)

Below is the initial contract review from Ollama. Read this carefully - you will build upon, challenge, or refine these findings.

### Ollama Review Results

**Issues Found**:
1. Preconditions too weak in NORMAL_DISTRIBUTION (CRITICAL)
2. Postconditions in icdf not sufficiently testable (MAJOR)
3. Invariants already present but need verification (CRITICAL)
4. Preconditions/invariants defensive layering is actually GOOD (CRITICAL noted as good)
5. Naming confusion between randomizer/internal_randomizer (MAJOR)

**Key Clarification Questions**:
- is_valid_for_pdf/cdf undefined but referenced in preconditions
- next_samples_deterministic postcondition unclear - how to test?
- 1e-6 tolerance achievable with simple_math?
- Standard Normal CDF placeholder returns 0.5 (test blocker)
- Beta.cdf deferred breaks Phase 1 inference

**Assessment**: GOOD contracts with MAJOR implementation gaps (2-3 hour fixes needed)

## Your Review Task

As the second reviewer in the chain, you should:

1. **Validate** Ollama's findings - are they correct and actionable?
2. **Deepen** the analysis - look for subtle contract issues Ollama may have missed:
   - Contracts that are mathematically unsound
   - Preconditions/postconditions mismatched with implementation approach
   - Missing MML queries (model-based frame conditions)
   - SCOOP-safety issues (shared mutable state)
   - Void-safety violations (detachable assumptions)
3. **Challenge** assumptions - are the design choices sound?
4. **Prioritize** - which issues matter most for Phase 1 success?

## Contract Review Depth

### Precondition Analysis
- [ ] Are preconditions **necessary** (not always true)?
- [ ] Are preconditions **sufficient** (prevent all bad inputs)?
- [ ] Do preconditions match the **implementation approach** described in approach.md?
- [ ] Example: `p > 0 and p < 1` for ICDF - but what about p=0 and p=1 (boundary)?

### Postcondition Analysis
- [ ] Does every postcondition **answer a question** (what changed, how, what didn't)?
- [ ] Are postconditions **testable** (can we verify in unit tests)?
- [ ] Are postconditions **implementable** (can code satisfy them)?
- [ ] Example: `cdf(x) <= cdf(x + 1)` - this is testable but needs context (which distributions?)

### Invariant Analysis
- [ ] Are invariants **true on object creation**?
- [ ] Are invariants **preserved by all commands**?
- [ ] Do invariants **prevent illegal states**?
- [ ] Example: `sigma > 0` - yes, but should we also bound `sigma < max_float`?

### Frame Condition Analysis (MML)
- [ ] **What changed?** (direct postcondition effects)
- [ ] **What didn't change?** (frame conditions using MML |=|)
- [ ] Example for `set_seed`: "randomizer changed, all parameters unchanged"
- [ ] **Are collections modeled?** (HASH_TABLE, ARRAY need MML_MAP, MML_SEQUENCE)

### SCOOP Safety Analysis
- [ ] Are objects **properly separated** (separate keyword)?
- [ ] Is there **no shared mutable state** between concurrent agents?
- [ ] Can **set_seed** be called safely from multiple agents?
- [ ] Example: `internal_randomizer` is owned by each distribution - GOOD

### Implementation Feasibility
- [ ] Can contracts be **satisfied by the implementation approach**?
- [ ] Do preconditions **enable the algorithm**? (e.g., σ > 0 enables Box-Muller)
- [ ] Do postconditions **match what the algorithm produces**? (e.g., Box-Muller result in domain)
- [ ] Example: icdf(0.5) ≈ mean - testable, but requires accurate inverse?

## Contract Classes to Review

### DISTRIBUTION (Abstract Base)
- Deferred features: pdf, cdf, icdf, sample, mean, variance, set_seed, in_domain, minimum, maximum
- Invariant: minimum < maximum, mean finite or ±∞, variance ≥ 0
- Issues to consider:
  - `cdf_monotonic: cdf(x) <= cdf(x + 1)` - is this testable? Is the delta arbitrary?
  - `cdf_inverse_property: (cdf(Result) - p).abs < 1e-6` - too tight or too loose?
  - `mean_finite: not mean.is_infinite or (mean = negative_infinity or mean = positive_infinity)` - confusing logic

### NORMAL_DISTRIBUTION
- Makes: Normal(μ, σ) with σ > 0, σ < 10^10
- Key features: pdf (Gaussian formula), cdf (facade call), icdf (inverse facade call), sample (Box-Muller)
- Issues to consider:
  - What if `standard_normal_cdf` is inaccurate? How does that propagate to cdf/icdf?
  - Box-Muller uses `u1.ln` - what if `simple_math.ln` is unavailable?
  - `next_samples_deterministic` postcondition - what does this mean? Can it be verified?

### UNIFORM_DISTRIBUTION
- Makes: Uniform(a, b) with a < b
- Simple analytical formulas for pdf, cdf, icdf
- Issues to consider:
  - Boundary handling: is `x ∈ [a,b]` strict or loose?
  - pdf at boundaries (a and b): is it 1/(b-a) or 0?

### BINOMIAL_DISTRIBUTION
- Makes: Binomial(n, p) with n > 0, p ∈ [0,1]
- Uses pmf: C(n,k) * p^k * (1-p)^(n-k)
- Issues to consider:
  - What about p=0 or p=1? (degenerate cases)
  - `cdf_up_to_integer` - cumulative sum can overflow for large n
  - Sampling via Bernoulli loop is O(n) - acceptable for Phase 1?

### EXPONENTIAL_DISTRIBUTION
- Makes: Exponential(λ) with λ > 0
- Formula-based: pdf = λ*exp(-λ*x), cdf = 1 - exp(-λ*x)
- Issues to consider:
  - Underflow for very large x: exp(-λ*x) → 0, cdf → 1 (correct)
  - Sampling via -ln(u)/λ: what if u is very small? ln(u) underflows?

### BETA_DISTRIBUTION
- Makes: Beta(α, β) with α > 0, β > 0
- Complex: pdf requires beta function B(α,β), cdf is regularized incomplete beta
- Issues to consider:
  - Regularized incomplete beta is deferred to Phase 2 - is this acceptable for Phase 1?
  - Beta-Binomial conjugacy requires accurate Beta.pdf/cdf - which validation?
  - Sampling via Gamma-ratio deferred - what's the placeholder?

### SIMPLE_PROBABILITY (Facade)
- Factory methods for all distributions
- Utilities: standard_normal_cdf, inverse_standard_normal_cdf (placeholders)
- Issues to consider:
  - Factories return new instances - ok for SCOOP?
  - standard_normal_cdf is 0.5 placeholder - how will this affect Normal.cdf tests?
  - inverse_standard_normal_cdf is 0.0 placeholder - similar issue

### BAYESIAN_UPDATER
- update_conjugate_beta_binomial: Beta(α + k, β + n - k)
- credible_interval_from_posterior: symmetric CI from icdf
- Issues to consider:
  - Conjugacy only works if observations are binomial and prior is Beta
  - credible_interval requires accurate icdf - Beta.icdf deferred to Phase 2
  - Lower/upper bounds must be ordered - postcondition checks this

## Output Format

```markdown
## Claude Review Results

### Issues Found

#### Issue 1: [Title]
- **Location**: [Class.feature or line]
- **Severity**: CRITICAL/MAJOR/MINOR
- **Type**: [Precondition/Postcondition/Invariant/Frame Condition/SCOOP/Void-Safety/Feasibility]
- **Ollama Found This**: Yes/No/Partially
- **Analysis**: [Why this is a real problem]
- **Suggestion**: [How to fix it]
- **Priority**: Phase 1 Blocker / Phase 1 Improvement / Phase 2+

#### Issue 2: [Title]
[...etc...]

### Ollama Validation

#### Agreed With
- [Issues Ollama found that are correct and actionable]

#### Disagree With
- [Issues Ollama found that are not real problems, and why]

#### Added Depth
- [Subtle issues Ollama missed]

### Contract Quality Assessment

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Preconditions sufficient | PASS/WARN/FAIL | [assessment] |
| Postconditions complete | PASS/WARN/FAIL | [assessment] |
| Invariants protective | PASS/WARN/FAIL | [assessment] |
| SCOOP-safe | PASS/WARN/FAIL | [assessment] |
| Void-safe | PASS/WARN/FAIL | [assessment] |
| MML-ready | PASS/WARN/FAIL | [assessment] |
| Implementable (Phase 1) | PASS/WARN/FAIL | [assessment] |

### Recommended Changes

**High Priority (fix before Phase 4 implementation):**
1. [Change 1 with rationale]
2. [Change 2 with rationale]

**Medium Priority (address in Phase 1.5 or 2):**
1. [Change 1 with rationale]

**Nice to Have (Phase 3+):**
1. [Change 1 with rationale]

### Ready for Implementation?

**VERDICT**: Ready / Needs Fixes / Blocked

**Rationale**: [Brief summary of fitness for Phase 4 implementation]
```

## Context

- **Phase**: Phase 2 Review (before implementation begins)
- **Goal**: Validate contracts before writing code
- **Next**: After this review, Grok will add security/edge-case analysis
- **Finally**: Gemini will do final feasibility check before Phase 4 implementation

Take your time. The goal is to find real problems that would cause issues during Phases 4-5.
