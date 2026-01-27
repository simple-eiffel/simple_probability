# SCOPE: simple_probability

## Problem Statement

**In one sentence:** Developers building data-driven systems in Eiffel lack a simple, accessible probability and Bayesian reasoning library that doesn't require deep mathematical expertise.

### What's Wrong Today

1. **Mathematical Barrier**: Probability theory uses heavy notation (PDF, CDF, conjugate priors, Bayesian updating). Non-math engineers find this intimidating.
2. **Gap in Eiffel Ecosystem**: simple_math provides linear algebra and statistics summarization, but has zero probability distributions, sampling algorithms, or Bayesian inference.
3. **Pain Point**: Even with simple_randomizer, developers cannot:
   - Model uncertainty (e.g., "this sensor reading is ±10% from true value")
   - Perform Bayesian updates (e.g., "I got test result X, what's my posterior belief about disease presence?")
   - Generate synthetic data from realistic distributions (e.g., customer wait times follow exponential)
   - Quantify confidence in predictions

### Who Experiences This

| User Type | Needs | Pain Level |
|-----------|-------|------------|
| **Data Pipeline Developer** | Model uncertainty, propagate errors | HIGH |
| **Quality Engineer** | Bayesian A/B testing, confidence intervals | HIGH |
| **ML Engineer** | Prior specification, posterior sampling | HIGH |
| **Business Analyst** | Probability reasoning for decisions | MEDIUM |
| **Sensor/IoT Developer** | Uncertainty quantification, filtering | HIGH |
| **Reliability Engineer** | Distribution-based failure prediction | MEDIUM |

### Impact of Not Solving

- Developers fall back to hard-coded heuristics or switch to Python/R for probability work
- Loss of type safety, SCOOP compatibility, Design by Contract verification
- Duplicated effort across projects (each reimplements Normal distribution, MCMC, etc.)
- Eiffel ecosystem gap vs. competitors (Python has PyMC, Stan, SciPy; R has base stats + Bayesian tools)

## Target Users: Developer Personas

### Persona 1: "Alex the Pragmatic Engineer"
- **Background**: 10+ years software engineering, minimal statistics training
- **Goal**: Add uncertainty quantification to sensor fusion algorithm
- **Pain**: "I know Normal distribution is bell curve-shaped. How do I use it in code without learning measure theory?"
- **Success Criteria**: Can specify prior, update with sensor data, extract confidence intervals in <30 minutes

### Persona 2: "Sam the Data Pipeline Builder"
- **Background**: Backend engineer, familiar with data operations
- **Goal**: Model error propagation through data transformations
- **Pain**: "I want Bayesian reasoning in my system, but I don't want to learn Stan or PyMC"
- **Success Criteria**: Can define prior, likelihood, posterior within existing Eiffel code

### Persona 3: "Jordan the QA Automation Lead"
- **Background**: Test automation, basic statistics knowledge
- **Goal**: Implement Bayesian A/B testing for feature validation
- **Pain**: "I know the concept, but implementing posterior calculations feels too mathy"
- **Success Criteria**: Can define control vs treatment distributions, sample posterior, report credible intervals

## Success Criteria

| Level | Criterion | How to Measure |
|-------|-----------|---|
| **MVP** | Developers can create Normal, Beta, Binomial distributions and sample from them | Code example: `create {NORMAL_DISTRIBUTION}.make(0, 1) sample` works |
| **MVP** | Developers can perform basic Bayesian updating on real-world problem | Code example: test result → posterior belief quantifies uncertainty |
| **MVP** | PDF/CDF accessible without memorizing math | API: `dist.pdf(x)`, `dist.cdf(x)` — no formulas in user code |
| **Full** | Developers can compare models using Bayesian model selection | Marginal likelihood, Bayes factors calculated by library |
| **Full** | MCMC sampling works for complex posteriors | Metropolis-Hastings generates posterior samples correctly |

## Scope Boundaries

### In Scope (MUST)
- **Probability distributions** (Normal, Beta, Binomial, Uniform, Exponential, Gamma)
- **PDF/CDF/quantile functions** (probability density, cumulative probability, inverse)
- **Random sampling** from any distribution
- **Parameter inference** from data (Method of Moments, Maximum Likelihood)
- **Bayesian updating** (prior + likelihood → posterior)
- **Conjugate priors** (Normal-InverseGamma, Beta-Binomial, etc.)
- **Simple credible intervals** (percentile method from posterior samples)
- **Design by Contract** on all distribution classes
- **SCOOP compatibility** (thread-safe via simple_randomizer seeding)

### In Scope (SHOULD)
- **MCMC sampling** (Metropolis-Hastings) for arbitrary posteriors
- **Multivariate distributions** (Multivariate Normal)
- **Model comparison** (Bayes factors, evidence)
- **Rejection sampling** for unusual distributions
- **Common distributions** (Weibull, Lognormal, Student's t, Poisson, Geometric)
- **Hierarchical priors** (Dirichlet for proportions, etc.)

### Out of Scope
- **Machine Learning implementations** (neural networks, forests, etc.) — that's simple_ml
- **Graphical models / Bayesian networks** — future simple_networks
- **Time series models** (ARIMA, Kalman filters) — future domain
- **Causal inference** (do-calculus, instrumental variables) — future research
- **Advanced MCMC** (Hamiltonian, variational inference) — Phase 2+
- **GPU acceleration** — Phase 3+

### Deferred to Future
- **Normalizing flows** (Phase 2 with simple_neural)
- **Variational inference** (Phase 2 with optimization)
- **Symbolic probability** (Phase 3)
- **Frequentist hypothesis testing** (separate library: simple_frequentist)

## Constraints

| Type | Constraint | Immutable? |
|------|-----------|-----------|
| **SCOOP** | Must be SCOOP-compatible (thread-safe concurrency) | YES |
| **simple_* first** | Prefer simple_randomizer over ISE, simple_math over ISE | YES |
| **No external C** | No separate .c files; inline C only (per ecosystem standard) | YES |
| **DBC Contracts** | All classes require preconditions, postconditions, invariants | YES |
| **Performance** | Acceptable O(n) per sample; reject O(n³) algorithms | NO — depends on Phase |
| **File dependencies** | No loading probability tables from disk (compute on-the-fly) | YES |
| **Backward compatibility** | ISE 25.02 compiler, void-safe mode | YES |

## Assumptions to Validate

| ID | Assumption | Risk if False | Validation |
|----|-----------|-------|-----------|
| A-1 | Developers prefer "Normal.sample()" over "compute_gaussian_cdf_manually()" | Loss of adoption | User interviews in Phase 0 |
| A-2 | Bayesian reasoning resonates with Eiffel developers building systems | Too niche for ecosystem | Check simple_* library usage patterns |
| A-3 | Box-Muller + rejection sampling sufficient for MVP (no fancy MCMC needed) | Users demand advanced inference too early | Start Phase 1 with basic, extend Phase 2 |
| A-4 | SCOOP concurrency model compatible with randomizer seeding | Implementation blockers discovered | Prototype concurrent sampling |
| A-5 | simple_math's facade pattern scales to 10+ distributions | API becomes cluttered | Design distribution registry pattern |
| A-6 | Non-math engineers can understand "conjugate prior" with documentation | Adoption stalls on theory | User testing on intent documentation |

## Research Questions

1. **How do other languages (Python, R, Julia) make probability accessible to non-statisticians?**
   - What API patterns reduce cognitive load?
   - How much math do they expose vs. hide?

2. **What Bayesian reasoning tasks appear most often in production systems?**
   - Is it 80/20: straightforward priors + likelihoods vs. exotic custom models?
   - Can we cover MVP with conjugate pairs?

3. **Are Eiffel developers ready for probabilistic reasoning in their architectures?**
   - Or is this ahead of the curve?
   - What's the adoption risk?

4. **How can we bridge math notation → Eiffel API?**
   - Contract notation clearly captures preconditions (α > 0) but what about model semantics?
   - Should we provide example Jupyter notebooks, or Eiffel test examples?

5. **Performance trade-offs: accuracy vs. speed?**
   - Is numerical approximation (Simpson's rule for CDF) acceptable or must we precompute?
   - Rejection sampling can be slow for rare events; can we live with that in MVP?

---

## Scope Validation Matrix

| Question | Answer | Risk | Mitigation |
|----------|--------|------|-----------|
| Is this a "nice to have" or "critical"? | Critical for data systems; nice-to-have for typical apps | Medium | Start Phase 1 small, validate demand |
| Does it overlap dangerously with simple_math? | No: math=tools, probability=domains | Low | Clear API boundary (DISTRIBUTION abstract) |
| Do we have the math expertise in-house? | Yes: probability theory is well-known domain | Low | Prototype distributions first |
| Will this ship in one phase or need iteration? | Likely 2-3 phases (MVP → MCMC → Inference chains) | Medium | Design extensible architecture upfront |
| Is there demand outside the simple_* ecosystem? | Yes: Eiffel data science, IoT, reliability engineering | Low | Library fills ecosystem gap |

---

**SCOPE VALIDATION: PASS** ✓

This is a well-scoped, valuable addition to the Eiffel ecosystem addressing a clear gap.
