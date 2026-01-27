# CHALLENGED ASSUMPTIONS: simple_probability

## Assumptions Challenged

### A-001: "Non-math developers can understand probability distributions with good documentation"

**Assumption from research:** A semantic API + dual-narrative docs can bridge the gap for non-mathematicians.

**Challenge:** What if "credible interval" is still too mathy? What if users don't understand "posterior"?

**Evidence for:**
- PyMC has "Bayesian Methods for Hackers" → computation-first approach works for learners
- R's base stats used by engineers without PhD; API clear (mean, var, sample)
- User testing research indicates semantic naming resonates ("credible_interval" vs "quantile_function")

**Evidence against:**
- Statistics is genuinely hard; no library makes it trivial
- Some concepts (conjugate priors, MCMC convergence) require training
- Risk: Users abandon library if learning curve too steep

**Verdict:** VALID with mitigation

**Action:**
- Provide extensive worked examples (disease testing, coin flips, A/B testing)
- Semantic layer must prioritize business context over math
- Documentation has sections: "Non-Statistician Guide" + "For Statisticians"
- Invest in tutorial blog posts, workshops

---

### A-002: "Conjugate priors are enough for Phase 1 Bayesian inference"

**Assumption:** Beta-Binomial conjugate pair covers 80% of use cases; MCMC can be Phase 2.

**Challenge:** What if users demand MCMC in Phase 1? What if 80% estimate is wrong?

**Evidence for:**
- Beta-Binomial solves: disease testing, coin flips, A/B testing, quality control
- Exact conjugate updates are fast (closed-form) vs slow (MCMC sampling)
- Phase 1 MVP benefits from simplicity; Phase 2 adds complexity

**Evidence against:**
- Some real problems need custom likelihoods (not conjugate)
- MCMC not that hard; users might expect it
- Scope creep risk: "Just add MCMC" could delay Phase 1

**Verdict:** VALID but requires communication

**Action:**
- Phase 1 architecture designed for Phase 2 extension (MCMC_SAMPLER stubbed)
- Documentation clearly states Phase 1 is conjugate-only; MCMC coming Phase 2
- Real-world examples show conjugate pair solving actual problems
- Measure demand: if many users want MCMC Phase 1, reconsider Phase 1.5

---

### A-003: "SCOOP concurrency is worth the complexity; users want parallel sampling"

**Assumption:** SCOOP-native parallel MCMC chains worth the extra design complexity.

**Challenge:** What if users don't care about parallelism? What if SCOOP adds bugs?

**Evidence for:**
- MCMC chains are embarrassingly parallel (independent chains with same seed)
- SCOOP eliminates GIL (Python bottleneck) and explicit threading (error-prone)
- Eiffel's strength is type-safe concurrency; should leverage it

**Evidence against:**
- Phase 1 doesn't have MCMC, so parallelism deferred
- SCOOP concurrency bugs are subtle and hard to debug
- Most users run single-threaded; parallelism is nice-to-have

**Verdict:** VALID for Phase 2+, not Phase 1

**Action:**
- Phase 1 focuses on correctness; SCOOP concurrency is Phase 2 feature
- Design distribution sampling to be SCOOP-safe (no shared mutable state)
- Phase 2 MCMC_SAMPLER designed for parallel chains
- Testing: Phase 2 will extensively test concurrent sampling

---

### A-004: "Parameter inference (fitting distributions to data) should be in Phase 1"

**Assumption:** Method of Moments + basic curve fitting useful and not too complex.

**Challenge:** Is this MVP scope or nice-to-have? Do users expect it?

**Evidence for:**
- Real use case: "Fit Normal distribution to sensor noise data"
- Method of Moments is trivial: mean = sample_mean, variance = sample_variance
- Adds 100 LOC; not blocking

**Evidence against:**
- Phase 1 already dense (5 distributions, Bayesian updating)
- Could defer to Phase 2 with more advanced MLE
- Users can do mean/variance calculation themselves

**Verdict:** VALID; include basic fitting but defer advanced MLE

**Action:**
- Include `estimate_from_moments(mean, variance)` in Phase 1
- Include `estimate_from_data(observations)` for Method of Moments
- Defer Maximum Likelihood Estimation to Phase 2
- Keep simple: two static methods per distribution class

---

### A-005: "5 distributions is enough for Phase 1 MVP"

**Assumption:** Normal, Uniform, Beta, Binomial, Exponential cover 80% of use cases.

**Challenge:** What about Poisson (count data)? Gamma (reliability)? Are we missing something?

**Evidence for:**
- Beta-Binomial conjugate pair is core (Bayesian examples)
- Normal foundational (everything references Normal)
- Exponential needed (sensor failures, waiting times)
- Uniform trivial (validates pattern)

**Evidence against:**
- Poisson is extremely common (event counting)
- Users might want Gamma, Weibull (reliability engineering)
- Could add 3-4 more distributions cheaply (same pattern)

**Verdict:** VALID but borderline

**Action:**
- Phase 1: Core 5 (Normal, Uniform, Beta, Binomial, Exponential)
- Phase 1.5: Add Poisson, Geometric, Negative Binomial if time permits
- Documentation explains Phase 1 prioritizes core; Phase 2 adds extended distributions
- Pattern is proven after first 5; adding more is mechanical

---

### A-006: "Eiffel's type system prevents bugs better than Python/R dynamic typing"

**Assumption:** Type-safe probability library is competitive advantage; compile-time checks catch errors.

**Challenge:** Is type safety real benefit or academic exercise? Do users care?

**Evidence for:**
- Sending DISTRIBUTION where INTEGER expected → compile error (vs runtime error in Python)
- Prior vs Posterior are different types (prevents mixing up)
- SCOOP separate clause prevents data races at compile time
- Production systems value reliability over convenience

**Evidence against:**
- Python users happy despite dynamic typing; libraries work via testing
- Type annotations in Python (typing module) provide similar safety
- Learning curve steeper with strict typing

**Verdict:** VALID; type safety is real advantage for production systems

**Action:**
- Leverage Eiffel type system in marketing ("type-safe probability")
- Demonstrate compile-time error catching in examples
- Don't overstate; acknowledge dynamic languages work too
- Target production teams (reliability-focused), not academics

---

### A-007: "Simple_randomizer's RNG is adequate for probability sampling"

**Assumption:** ISE's RANDOM (Mersenne Twister) suitable for statistical simulation.

**Challenge:** Is RNG quality sufficient? Does seeding work correctly?

**Evidence for:**
- Mersenne Twister well-researched, industry standard
- ISE library maintained and stable
- simple_randomizer already used in ecosystem

**Evidence against:**
- Cryptographic RNG better for sensitive applications
- Poor seeding could cause degenerate sequences
- Risk: subtle statistical bias

**Verdict:** VALID with testing

**Action:**
- Phase 1 validation: Run Diehard tests on simple_randomizer RNG
- Test seeding: Verify different seeds produce statistically independent sequences
- Document: "MT19937, suitable for statistical modeling, not cryptography"
- Phase 2: Consider cryptographic RNG upgrade if demand exists

---

### A-008: "Design by Contract is essential; every feature must have contracts"

**Assumption:** Eiffel principle: all features use require/ensure/invariant for specification.

**Challenge:** Contracts add complexity; simple features might not need them.

**Evidence for:**
- DBC is Eiffel philosophy (Meyer's approach)
- Contracts document intent and guard against misuse
- Tests verify contracts hold
- Production verification: contracts can be checked at runtime

**Evidence against:**
- Contracts add implementation complexity
- Some features trivial (e.g., getter); contract might seem overkill
- Users might find contracts verbose

**Verdict:** VALID; embrace contracts as specification

**Action:**
- Every public feature has contracts (no exceptions)
- Contracts document both what and why (comments explain intent)
- Tests are specifically designed to verify contracts
- Frame contracts as documentation, not compliance burden

---

### A-009: "Accessible APIs should hide mathematical complexity, not expose it"

**Assumption:** Non-math users shouldn't see "PMF," "conjugate prior," "hyperparameter" in API.

**Challenge:** Are we oversimplifying? Will statisticians feel patronized?

**Evidence for:**
- Primary audience: non-math engineers (confirmed in research)
- Business framing (credible_interval) more intuitive than (quantile_function)
- Semantic layer separate from math layer

**Evidence against:**
- Statisticians might prefer direct API (pdf, cdf, parameters by name)
- Hiding complexity could limit advanced users
- Two APIs might confuse rather than help

**Verdict:** VALID; embrace two-level approach

**Action:**
- Semantic API (business layer): credible_interval, update_belief, etc.
- Mathematical API (expert layer): pdf, cdf, icdf, sample with full parameter control
- Documentation shows both paths; users choose their level
- Examples guide non-math users; references available for statisticians

---

### A-010: "Phase 1 should not include MCMC or model comparison"

**Assumption:** MCMC adds too much complexity; sufficient to have conjugate priors.

**Challenge:** Does deferral hurt adoption? Can we prototype MCMC cheaply?

**Evidence for:**
- Metropolis-Hastings is algorithm ~200 LOC; could add to Phase 1
- MCMC enables arbitrary likelihoods (more flexible)
- Users might expect it

**Evidence against:**
- MCMC introduces convergence diagnostics complexity
- Burn-in tuning, thinning require expertise
- Phase 1 already dense; adding MCMC risks schedule slip
- Conjugate pairs solve common cases exactly

**Verdict:** VALID; defer MCMC to Phase 2

**Action:**
- Phase 1 architecture designed for easy MCMC addition (interface stubbed)
- Phase 2 gates: User demand for MCMC justifies next phase?
- If adoption is very high Phase 1, prioritize MCMC for Phase 2
- If adoption low, MCMC might be lower priority

---

## Requirements Questioned

### FR-014: Method of Moments estimation

**Requirement:** `dist.estimate_parameters_from_moments(mean, variance)`

**Challenge:** Is this needed in Phase 1? Can it be Phase 2?

**Status:** KEEP with mitigation
- Include basic Method of Moments (easy: mean=sample_mean, variance=sample_variance)
- Defer advanced MLE to Phase 2
- One static method per distribution sufficient

### FR-009: Bayesian posterior update

**Requirement:** `prior.update(likelihood_agent, data)` returns posterior

**Challenge:** Is updating via agent too complex? Can we simplify?

**Status:** KEEP but simplify for Phase 1
- Phase 1: Conjugate pairs only (pre-registered Beta-Binomial, etc.)
- Phase 2: Generic MCMC for arbitrary likelihoods
- Simplification: built-in conjugate pairs, not arbitrary agents Phase 1

### FR-017: Multivariate Normal

**Requirement:** Support Multivariate Normal distribution

**Challenge:** Do users need multivariate in Phase 1?

**Status:** REMOVE from Phase 1; defer to Phase 2
- Phase 1 univariate only (simpler, MVP focused)
- Phase 2 can add Multivariate Normal, Dirichlet
- Univariate distributions sufficient for common use cases

---

## Missing Requirements Identified

| ID | Missing Requirement | How Discovered | Priority |
|----|---------------------|---|---|
| **FR-NEW-001** | Parallel MCMC chains (SCOOP-native) | Eiffel competitive advantage | Phase 2 |
| **FR-NEW-002** | Convergence diagnostics (Gelman-Rubin R̂) | MCMC quality requirement | Phase 2 |
| **FR-NEW-003** | Log-likelihood computation | Numerical stability for MCMC | Phase 2 |
| **FR-NEW-004** | Credible interval extraction from samples | Common Bayesian operation | Phase 1/2 boundary |
| **FR-NEW-005** | Burn-in & thinning parameters | MCMC tuning | Phase 2 |
| **FR-NEW-006** | Model comparison (Bayes factors) | Advanced inference | Phase 2+ |
| **FR-NEW-007** | Hierarchical prior specification | Advanced Bayesian modeling | Phase 3+ |
| **FR-NEW-008** | Custom distribution registration | Extensibility for domain-specific dists | Phase 2+ |

---

## Design Constraints Validated

| Constraint | Valid? | Notes |
|-----------|--------|-------|
| **simple_* first** | YES | Use simple_randomizer (RNG), simple_math (exp/log/sqrt) |
| **SCOOP-compatible** | YES | No mutable shared state; sampling thread-safe with local seeds |
| **Void-safe (void_safety=all)** | YES | All distributions attached (never Void); safer null handling |
| **DBC contracts** | YES | Every feature has require/ensure/invariant; specification via contracts |
| **No external C** | YES | Pure Eiffel; no .c files; inline C only if needed (Phase 2+) |
| **No file I/O** | YES | Compute PDFs/CDFs on-the-fly; no probability lookup tables |
| **Inheritance: IS-A only** | YES | NORMAL_DISTRIBUTION IS-A DISTRIBUTION_CONTINUOUS; proper semantics |
| **Command-Query Separation** | MOSTLY | Exception: `update()` is command but returns posterior (necessary for Bayesian) |

---

## Design Decisions Validated

| Decision | Still Valid? | Notes |
|----------|-------------|-------|
| **D-001: BUILD from scratch** | YES | Correct choice for Eiffel-native, type-safe library |
| **D-002: 5 distributions Phase 1** | YES with option for Phase 1.5 | Core distributions sufficient; can add 3 more discretes if time |
| **D-003: Object-oriented API** | YES | Type-safe, extensible, contracts natural |
| **D-004: Rational approximations for CDF** | YES | Fast (<100μs) and accurate (1e-7); acceptable for Phase 1 |
| **D-005: Conjugate priors Phase 1** | YES | MCMC complexity justified in Phase 2; conjugates solve 80% of cases |
| **D-006: Per-distribution seed** | YES | SCOOP-safe; each distribution independent |
| **D-007: Dual-narrative docs** | YES | Critical for accessibility; business + math levels |
| **D-008: Full integration simple_randomizer/math** | YES | Reuse proven libraries; no reinvention |
| **D-009: Separate continuous/discrete hierarchies** | YES | Type safety: pdf() only for continuous, pmf() for discrete |
| **D-010: Open architecture** | YES | Users can extend; contracts guard correctness |

---

## Summary of Findings

**All major assumptions validated.** No fundamental flaws in approach.

**Key mitigations:**
1. Accessibility requires investment in documentation + examples
2. MCMC Phase 2 (not Phase 1) reduces scope and risk
3. Type safety is real advantage but requires marketing to production teams
4. Contracts + testing catch errors that dynamic languages miss
5. Architecture designed for Phase 2 extension (MCMC, multivariate, etc.)

**Open questions for Phase 1:**
1. How much semantic API overhead before complexity overwhelms benefit?
2. Does Method of Moments fit in Phase 1 or should it be Phase 2 only?
3. Should credible_interval be Phase 1 or Phase 2 only?

**Recommendation:** Proceed to class design with full confidence in core assumptions. Address open questions during implementation.

