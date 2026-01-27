# DECISIONS: simple_probability

## Decision Log

### D-001: Build vs Acquire

**Question:** Should we build simple_probability from scratch, wrap external libraries (PyMC, SciPy), or port existing code?

**Options:**

1. **Build from scratch** (1,500-2,000 LOC)
   - Pros: Eiffel-native, full type safety, SCOOP-compatible, no external dependencies, custom APIs for non-math developers
   - Cons: More engineering effort upfront, must implement all algorithms ourselves

2. **Wrap SciPy/NumPy via FFI**
   - Pros: Proven algorithms, 100+ distributions out-of-box
   - Cons: Heavy dependencies, GIL issues (threading), deployment complexity, loses Eiffel type safety

3. **Port PyMC/Stan**
   - Pros: Advanced inference (NUTS, HMC)
   - Cons: These languages have semantics incompatible with Eiffel (Python dynamic typing, Stan's separate language), massive rewrite needed

4. **Call R via system process**
   - Pros: R has mature stats packages
   - Cons: Slow (process overhead), deployment dependency, not embedded

**Decision:** **BUILD** (Option 1)

**Rationale:**
- Eiffel's type system + contracts enable a simpler, safer API than Python alternatives
- No external process/language dependencies — probability reasoning stays in Eiffel
- Reference existing algorithms (SciPy, Julia) but implement natively
- Fills genuine gap in Eiffel ecosystem
- Allows us to prioritize developer accessibility (non-math API)

**Implications:**
- Must implement numerical algorithms carefully (testing against reference libraries)
- Performance Phase 1 may be slower than SciPy (acceptable; optimize Phase 2+)
- Documentation must be exceptional (our users won't have PyMC blog posts to reference)

**Reversible:** YES — if performance becomes unacceptable, can refactor to wrapped approach later.

---

### D-002: Scope of Phase 1 Distributions

**Question:** Which distributions should be in Phase 1 MVP? All distributions or a minimal set?

**Options:**

1. **Start with 2: Normal + Uniform only**
   - Pros: Minimal complexity, fast Phase 1, proves architecture
   - Cons: Too limited; doesn't solve real Bayesian problems without Beta+Binomial

2. **Start with 5: Normal, Uniform, Beta, Binomial, Exponential** (RECOMMENDED)
   - Pros: Core distributions cover 80% of use cases; includes conjugate pair (Beta-Binomial); shows pattern
   - Cons: More code (~1,500 LOC), longer Phase 1

3. **Start with 10+: Add Gamma, Poisson, Lognormal, etc.**
   - Pros: Comprehensive
   - Cons: Overscope; Phase 1 becomes bloated

4. **Separate phases: Core 5 now, extended later**
   - Pros: Lean MVP, iterative additions
   - Cons: Multiple releases to get to "useful"

**Decision:** **Option 2** (5 distributions, with option to add more in Phase 1.5)

**Rationale:**
- Beta-Binomial conjugate pair necessary for Bayesian updating demo
- Exponential covers important use case (waiting times, reliability)
- 5 distributions show architecture without overscoping
- Additional distributions in Phase 1.5 if time permits

**Implications:**
- Documentation must clearly explain when to use each distribution
- Tests must cover all 5 thoroughly
- Extensibility design crucial (adding Poisson/Gamma should be trivial)

**Reversible:** YES — can add distributions anytime.

---

### D-003: API Design: Object vs Function-Based

**Question:** Should distributions be objects with methods, or functions applied to parameters?

**Options:**

1. **Object-oriented (Recommended)** — Julia/SciPy model
   ```eiffel
   create {NORMAL_DISTRIBUTION}.make(mu, sigma)
   dist.pdf(x)
   dist.sample()
   ```
   - Pros: Type-safe, extensible, contracts on each method, SCOOP-natural
   - Cons: Slightly more verbose

2. **Function-based** — R model
   ```eiffel
   dnorm(x, mean=0, sd=1)
   pnorm(x, mean=0, sd=1)
   rnorm(n, mean=0, sd=1)
   ```
   - Pros: Familiar to statisticians, compact
   - Cons: Less type-safe, harder to track state (randomizer seed)

3. **Hybrid** — Class + functional API
   - Pros: Both styles supported
   - Cons: More code, confusing

**Decision:** **Option 1** (Object-oriented)

**Rationale:**
- Eiffel's strength is type safety + OOP; use it
- Contracts belong on methods, not free functions
- Distribution state (mean, variance) naturally encapsulated
- SCOOP agents work better with methods than free functions

**Implications:**
- Every distribution is a class inheriting from DISTRIBUTION
- SIMPLE_PROBABILITY facade provides factories (not free functions)
- Users learn one pattern: "create {DIST}.make(...), then call methods"

**Reversible:** YES — can add functional API later if demand exists.

---

### D-004: Numerical Accuracy vs Performance Trade-off

**Question:** When computing CDF with no closed form, should we use numerical integration (slow, accurate) or approximation (fast, less accurate)?

**Options:**

1. **Always integrate (SciPy approach)**
   - Pros: Guaranteed accuracy to numerical precision
   - Cons: CDF calls slow (~1-10ms depending on precision)

2. **Use rational approximations (Abramowitz & Stegun)**
   - Pros: Fast (~100μs), accurate to 1e-7
   - Cons: Less general (only works for common distributions)

3. **Hybrid: Fast approximation + fallback to integration**
   - Pros: Usually fast; guarantees accuracy if needed
   - Cons: More complex logic

**Decision:** **Option 2** (Rational approximations for Phase 1, integrate if time permits Phase 1.5)

**Rationale:**
- Phase 1 target: CDF < 100μs (achievable with approximations)
- Common distributions (Normal, Beta) have well-known approximations
- Bayesian updating doesn't require extreme precision (1e-6 adequate)
- Can add integration fallback later if users need it

**Implications:**
- Phase 1 CDF calls fast enough for real-time applications
- Contracts document accuracy limits (e.g., "CDF accurate to ±1e-7")
- Tests must verify accuracy against reference library

**Reversible:** YES — can improve algorithm anytime.

---

### D-005: Bayesian Updating: Exact vs Approximation

**Question:** Should Bayesian updating use exact conjugate priors or approximate MCMC?

**Options:**

1. **Exact conjugate priors only (Phase 1)**
   - Pros: Fast (closed-form posterior), exact results, simple
   - Cons: Limited to conjugate pair models only

2. **MCMC for all models (Phase 1)**
   - Pros: Handles any likelihood, general-purpose
   - Cons: Requires convergence checking, slow, adds complexity to Phase 1

3. **Hybrid: Conjugate priors in Phase 1, MCMC in Phase 2** (RECOMMENDED)
   - Pros: MVP solves most common problems exactly; MCMC added when needed
   - Cons: Two different update paths (must document clearly)

**Decision:** **Option 3** (Phase 1: Conjugate pairs; Phase 2: MCMC)

**Rationale:**
- 80% of Bayesian problems use conjugate pairs (Beta-Binomial, Normal-InverseGamma)
- Exact updates are fast, build confidence
- MCMC introduces convergence complexity best deferred to Phase 2
- Users can prototype Phase 1, upgrade to MCMC Phase 2 if needed

**Implications:**
- Phase 1 BAYESIAN_UPDATER only handles registered conjugate pairs
- API should hint at MCMC fallback (documentation, contracts)
- Design MCMC interface in Phase 1 (don't implement) so later addition is seamless

**Reversible:** YES — MCMC can be added without breaking existing code.

---

### D-006: Seeding & Reproducibility Model

**Question:** How should randomness be controlled for reproducibility? Global seed, per-distribution seed, or agent-based?

**Options:**

1. **Global seed** (simple_randomizer current approach)
   - Pros: Simple, familiar
   - Cons: Not SCOOP-friendly (all threads see same seed state)

2. **Per-distribution seed** (thread-local)
   ```eiffel
   dist.set_seed(42)
   dist.sample()  -- Deterministic
   ```
   - Pros: SCOOP-safe, each distribution independent
   - Cons: More state to manage

3. **Agent-based** (advanced)
   ```eiffel
   create sampler.make(seed := 42)
   sampler.next_sample(dist)  -- Returns deterministic sample
   ```
   - Pros: Flexible, SCOOP-safe, testable
   - Cons: More complex API

**Decision:** **Option 2** (Per-distribution seed, optionally via agent)

**Rationale:**
- SCOOP: Each distribution can have local seed without global synchronization
- Testing: Tests set seed before assertions
- Phase 1: Keep simple (per-dist seed)
- Phase 2: Can add agent-based randomizer for advanced users

**Implications:**
- `DISTRIBUTION` interface includes `set_seed(seed: INTEGER)` and `set_random(randomizer: SIMPLE_RANDOMIZER)`
- Contracts enforce that seed is set before sampling in tests
- Default randomizer (from simple_randomizer) used if none provided

**Reversible:** YES — can refactor to agent model without breaking API.

---

### D-007: Documentation Strategy: Math or Business?

**Question:** How much mathematical notation vs plain English should documentation use?

**Options:**

1. **Pure math** (academic style)
   - Pros: Precise, concise for statisticians
   - Cons: Intimidates non-math developers (our audience!)

2. **Pure English** (non-technical)
   - Pros: Accessible, no math literacy required
   - Cons: Imprecise, hard to verify correctness

3. **Dual narrative: Business first, math second** (RECOMMENDED)
   - Pros: Non-math users understand intent; math users verify rigor
   - Cons: More documentation to write

**Decision:** **Option 3** (Dual narrative)

**Rationale:**
- Primary audience: non-math engineers building systems
- Secondary audience: statisticians reviewing correctness
- Pattern: Every class has two sections: "What is this?" (business) and "Technical details" (math)

**Implications:**
- Every public feature gets two explanations (plain + formal)
- Examples must use business contexts (disease testing, coin flips, sensor uncertainty)
- Math papers cited for those wanting to dive deeper
- Documentation writing time: significant (maybe 20% of Phase 1 effort)

**Reversible:** YES — can add/improve documentation anytime.

---

### D-008: Integration with simple_math and simple_randomizer

**Question:** How deep should we integrate with existing libraries?

**Options:**

1. **Minimal integration** — Use only for basic operations
   - Pros: Loose coupling, less dependency risk
   - Cons: Reinvent wheels (e.g., math.sqrt, math.exp already exist)

2. **Full integration** — Reuse everything possible (RECOMMENDED)
   ```eiffel
   class NORMAL_DISTRIBUTION
   inherit
       DISTRIBUTION
   feature
       pdf (x: REAL_64): REAL_64
           local
               z: REAL_64
           do
               z := (x - mu) / sigma
               Result := (1 / (sigma * math.sqrt(2 * math.pi))) * math.exp(-0.5 * z * z)
           end
   end
   ```
   - Pros: Code reuse, consistency, performance gains
   - Cons: Tighter coupling, breaks if simple_math changes

3. **Create abstractions** — Define our own Math interface
   - Pros: Decoupled, flexible
   - Cons: Unnecessary abstraction

**Decision:** **Option 2** (Full integration, with contracts)

**Rationale:**
- simple_math is stable (v1.0+), low risk of breaking changes
- Reuse math functions (exp, log, sqrt) rather than reimplement
- Sampling reuses simple_randomizer's RNG
- No performance penalty; better code clarity

**Implications:**
- Dependencies: simple_randomizer (required), simple_math (required)
- Version compatibility: simple_probability v1.0 requires simple_math v1.0+, simple_randomizer v1.0+
- Testing: Must work with both libraries' test suites

**Reversible:** YES — can abstract if integration becomes problematic.

---

### D-009: Discrete vs Continuous Distribution Hierarchy

**Question:** Should discrete (Binomial, Poisson) and continuous (Normal, Beta) distributions share one DISTRIBUTION abstract class or have separate hierarchies?

**Options:**

1. **Single hierarchy**
   ```eiffel
   class DISTRIBUTION
   feature
       pdf (x: REAL_64): REAL_64  -- For continuous
       pmf (k: INTEGER): REAL_64  -- For discrete
   end
   ```
   - Pros: Unified API, polymorphism works
   - Cons: Mixing semantics (pdf vs pmf), type confusion

2. **Separate hierarchies** (RECOMMENDED)
   ```eiffel
   class DISTRIBUTION_CONTINUOUS
   feature
       pdf, cdf, icdf, sample: REAL_64
   end

   class DISTRIBUTION_DISCRETE
   feature
       pmf, cdf_discrete, icdf_discrete, sample: INTEGER
   end
   ```
   - Pros: Type-safe (pdf only for continuous), clear semantics
   - Cons: More classes, less polymorphism

**Decision:** **Option 2** (Separate hierarchies with common DISTRIBUTION_BASE)

**Rationale:**
- Continuous and discrete have fundamentally different semantics (pdf vs pmf)
- Type system should prevent calling pdf() on discrete distribution
- Contracts different (∫pdf=1 for continuous; Σpmf=1 for discrete)
- Both inherit from DISTRIBUTION_BASE to share common infrastructure

**Implications:**
- Phase 1: DISTRIBUTION_CONTINUOUS (Normal, Uniform, Beta, Exponential)
- Phase 1.5: DISTRIBUTION_DISCRETE (Binomial, Poisson, Geometric)
- Architecture: Common factory in SIMPLE_PROBABILITY handles both

**Reversible:** YES — can merge if it becomes a burden.

---

### D-010: Extension Mechanism for Custom Distributions

**Question:** Should library allow users to create custom probability distributions?

**Options:**

1. **Sealed library** — Only built-in distributions
   - Pros: Simpler, enforces consistency
   - Cons: Users can't add domain-specific distributions

2. **Open architecture** (RECOMMENDED)
   ```eiffel
   class MY_CUSTOM_DISTRIBUTION
   inherit
       DISTRIBUTION_CONTINUOUS
   feature
       pdf (x: REAL_64): REAL_64
           do ... end
   end
   ```
   - Pros: Extensible, enables advanced use cases
   - Cons: Users might create incorrect distributions

**Decision:** **Option 2** (Open, with contracts as guard rails)

**Rationale:**
- Design by Contract protects against incorrect distributions (require pdf_integrates_to_1)
- Phase 2 users will want custom likelihoods, priors
- Extensibility shows library is serious about ecosystem role

**Implications:**
- DISTRIBUTION_CONTINUOUS is non-final
- Contracts on abstract features must be checkable by users
- Documentation must show how to implement custom distributions correctly

**Reversible:** YES — can seal if abuse occurs.

---

## Decision Impact Matrix

| Decision | Phase 1 Impact | Phase 2 Impact | Risk Level |
|----------|---|---|---|
| D-001: Build | High (1,500+ LOC) | Medium (extend) | Low (proven decision) |
| D-002: 5 distributions | High (design choice) | Medium (easy to add) | Low (can expand) |
| D-003: OOP API | High (architecture) | Medium (foundation set) | Low (proven pattern) |
| D-004: Approximations | Medium (CDF performance) | High (can improve algorithm) | Medium (accuracy vs speed) |
| D-005: Conjugate priors Phase 1 | Low (simple to implement) | High (MCMC design needed) | Low (phased approach) |
| D-006: Per-dist seed | Medium (seeding design) | Low (works for both phases) | Low (proven pattern) |
| D-007: Dual narrative docs | High (writing effort) | Low (maintenance) | Low (better UX) |
| D-008: Full integration | Medium (coupling) | Low (stable) | Low (libraries stable) |
| D-009: Separate hierarchies | High (class design) | Low (foundation set) | Low (cleaner semantics) |
| D-010: Open architecture | Low (design decision) | High (enables Phase 2) | Medium (requires discipline) |

---

## Next Steps

These decisions are inputs to the SPEC phase. Once approved, we'll transform them into:
1. Class diagrams (DISTRIBUTION, DISTRIBUTION_CONTINUOUS, etc.)
2. ECF file structure
3. Test infrastructure
4. Documentation templates

