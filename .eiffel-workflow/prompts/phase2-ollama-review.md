# Eiffel Contract Review - simple_probability (Ollama)

You are an experienced Eiffel programmer reviewing contracts for a probability distribution library. Find obvious problems before implementation begins.

## Review Checklist
- [ ] Preconditions that are always true (too weak)
- [ ] Postconditions that don't constrain anything (too weak)
- [ ] Missing invariants that should protect state
- [ ] Obvious edge cases not handled by contracts
- [ ] Missing MML model queries (if using collections)
- [ ] Missing frame conditions (what did NOT change)
- [ ] Impossible postconditions (contradictory with preconditions)
- [ ] Circular dependencies or design flaws

## Part 1: Contracts to Review

### DISTRIBUTION (Abstract Base)

```eiffel
deferred class DISTRIBUTION

feature -- Probability Operations

	pdf (x: REAL_64): REAL_64
		require
			x_valid: is_valid_for_pdf (x)
		deferred
		ensure
			result_non_negative: Result >= 0
			result_finite: not Result.is_infinite
		end

	cdf (x: REAL_64): REAL_64
		require
			x_valid: is_valid_for_cdf (x)
		deferred
		ensure
			result_in_unit_interval: Result >= 0 and Result <= 1
			cdf_monotonic: cdf (x) <= cdf (x + 1)
		end

	icdf (p: REAL_64): REAL_64
		require
			p_valid: p > 0 and p < 1
		deferred
		ensure
			result_in_domain: in_domain (Result)
			cdf_inverse_property: (cdf (Result) - p).abs < 1e-6
		end

	sample: REAL_64
		deferred
		ensure
			result_in_domain: in_domain (Result)
		end

	mean: REAL_64
		deferred
		ensure
			result_finite: not Result.is_infinite
		end

	variance: REAL_64
		deferred
		ensure
			result_non_negative: Result >= 0
		end

	standard_deviation: REAL_64
		do
			Result := variance.sqrt
		ensure
			result_non_negative: Result >= 0
			result_equals_sqrt_variance: Result * Result ~ variance
		end

	set_seed (s: INTEGER)
		deferred
		ensure
			seed_set: next_samples_deterministic
		end

feature {NONE} -- Domain Checking

	in_domain (x: REAL_64): BOOLEAN
		require
			x_finite: not x.is_infinite and not x.is_nan
		deferred
		ensure
			consistent: Result implies (x >= minimum and x <= maximum)
		end

	minimum: REAL_64
		deferred
		ensure
			result_valid: not Result.is_infinite or Result = {REAL_64}.negative_infinity
		end

	maximum: REAL_64
		deferred
		ensure
			result_valid: not Result.is_infinite or Result = {REAL_64}.positive_infinity
		end

invariant
	minimum_less_than_maximum: minimum < maximum
	mean_finite: not mean.is_infinite or (mean = {REAL_64}.negative_infinity or mean = {REAL_64}.positive_infinity)
	variance_non_negative: variance >= 0

end
```

### NORMAL_DISTRIBUTION (Concrete)

```eiffel
class NORMAL_DISTRIBUTION

inherit DISTRIBUTION_CONTINUOUS

create make, default_create

feature -- Parameters
	mu: REAL_64
	sigma: REAL_64

feature -- Initialization
	make (a_mu, a_sigma: REAL_64)
		require
			sigma_positive: a_sigma > 0
			sigma_reasonable: a_sigma < 10000000000.0
		do
			mu := a_mu
			sigma := a_sigma
			create internal_randomizer.make
			set_seed (0)
		ensure
			mu_set: mu = a_mu
			sigma_set: sigma = a_sigma
		end

	default_create
		do
			mu := 0.0
			sigma := 1.0
			create internal_randomizer.make
			set_seed (0)
		ensure then
			standard_normal: mu = 0.0 and sigma = 1.0
		end

feature -- PDF
	pdf (x: REAL_64): REAL_64
		local
			z: REAL_64
			pi: REAL_64
			two_pi_sqrt: REAL_64
		do
			z := (x - mu) / sigma
			pi := math.pi
			two_pi_sqrt := (2 * pi).sqrt
			Result := (1 / (sigma * two_pi_sqrt)) * math.exp (-0.5 * z * z)
		end

feature -- CDF
	cdf (x: REAL_64): REAL_64
		local
			z: REAL_64
			facade: SIMPLE_PROBABILITY
		do
			z := (x - mu) / sigma
			create facade.make
			Result := facade.standard_normal_cdf (z)
		end

feature -- ICDF
	icdf (p: REAL_64): REAL_64
		local
			facade: SIMPLE_PROBABILITY
		do
			create facade.make
			Result := mu + sigma * facade.inverse_standard_normal_cdf (p)
		ensure then
			icdf_of_half_is_mean: (icdf (0.5) - mu).abs < 0.0000000001
		end

feature -- Sampling
	sample: REAL_64
		local
			u1, u2, r, theta: REAL_64
		do
			u1 := randomizer.random_real_in_range (0.0, 1.0)
			u2 := randomizer.random_real_in_range (0.0, 1.0)
			r := (-2 * u1.ln).sqrt
			theta := 2 * math.pi * u2
			Result := mu + sigma * r * theta.cos
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

feature -- Seeding
	set_seed (s: INTEGER)
		do
			internal_randomizer.set_seed (s)
		ensure then
			seed_set: next_samples_deterministic
		end

feature {NONE} -- Implementation
	internal_randomizer: SIMPLE_RANDOMIZER
	randomizer: SIMPLE_RANDOMIZER
		do
			Result := internal_randomizer
		end

	math: SIMPLE_MATH
		once
			create Result.make
		end

	in_domain (x: REAL_64): BOOLEAN
		do
			Result := True
		end

	minimum: REAL_64
		do
			Result := {REAL_64}.negative_infinity
		end

	maximum: REAL_64
		do
			Result := {REAL_64}.positive_infinity
		end

	parameters_satisfy_constraints: BOOLEAN
		do
			Result := sigma > 0 and sigma < 10000000000.0
		end

invariant
	sigma_positive: sigma > 0
	sigma_reasonable: sigma < 10000000000.0

end
```

[Similar contracts for UNIFORM_DISTRIBUTION, BETA_DISTRIBUTION, BINOMIAL_DISTRIBUTION, EXPONENTIAL_DISTRIBUTION, SIMPLE_PROBABILITY, BAYESIAN_UPDATER - see src/*.e files in project]

## Part 2: Implementation Approach

See approach.md in project (summarized below):

### Key Design Decisions
- **Preconditions**: Parameter validation (σ > 0, p ∈ [0,1])
- **Postconditions**: Result properties (pdf ≥ 0, cdf ∈ [0,1])
- **Invariants**: State consistency (min < max, variance ≥ 0)
- **Seeding**: Each distribution owns randomizer for SCOOP safety
- **Sampling**: Box-Muller (Normal), Inverse transform (Exponential, Uniform), Bernoulli loop (Binomial)

### Dependencies
- simple_randomizer (RNG)
- simple_math (exp, ln, sqrt, pi)

## Your Review Task

Please find problems with these contracts. For each issue:

1. **ISSUE**: One-line description
2. **LOCATION**: Class.feature or line number
3. **SEVERITY**: CRITICAL / MAJOR / MINOR
4. **SUGGESTION**: How to fix it
5. **RATIONALE**: Why this matters

Examples of issues to look for:
- Precondition too weak: `require n_positive: n > 0` when n=0 might cause integer overflow
- Postcondition not testable: `Result.is_positive` when Result can be negative
- Missing frame condition: `cdf(x) <= cdf(x+1)` without specifying unchanged parameters
- Circular logic: precondition on parameter contradicts invariant

## Output Format

```markdown
## Ollama Review Results

### Issues Found

#### Issue 1: [Title]
- **Location**: [Class.feature]
- **Severity**: CRITICAL/MAJOR/MINOR
- **Description**: [What's wrong]
- **Suggestion**: [How to fix]

#### Issue 2: [Title]
[...etc...]

### Strengths Observed
- [What's well-specified]

### Questions for Clarification
- [Any unclear parts of contracts?]
```

Take your time. Look for real problems that would cause issues during implementation or testing.
