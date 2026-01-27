# Phase 0 Intent Review Request

**Instructions:** Review the intent document below and generate probing questions to clarify vague language, identify missing requirements, and surface implicit assumptions. This is the "attack phase" — your goal is to find weaknesses before implementation begins.

## Review Criteria

Look for:
1. **Vague language:** Words like "fast", "secure", "easy", "flexible", "sufficient" without concrete definitions
2. **Missing edge cases:** What happens with empty input? Maximum size? Invalid data?
3. **Untestable criteria:** Are acceptance criteria specific and measurable?
4. **Hidden dependencies:** What external systems or libraries are assumed?
5. **Scope ambiguity:** Is "out of scope" clearly defined?
6. **Conflicting goals:** Do "accessible to non-math developers" and "scientifically rigorous" tension properly resolved?
7. **Risk unmitigated:** Are critical risks actually addressed, or just acknowledged?

## Output Format

Provide 7-10 probing questions. For each:
- Quote the vague phrase or concern
- Explain why it's problematic
- Offer 2-3 concrete alternatives the user can choose from
- Indicate: **CRITICAL** (blocks implementation) or **NICE-TO-HAVE** (nice to clarify)

---

## Intent Document to Review

**Project:** simple_probability (Eiffel probability & Bayesian library)

**Copy the contents of `.eiffel-workflow/intent.md` here and review it.**

---

## Example Review Structure

### Question 1: Numerical Accuracy (**CRITICAL**)

**Quote:** "Numerical accuracy: ±1e-6 relative error vs SciPy/NumPy reference"

**Why vague?** ±1e-6 is defined for *what* operations? PDF? CDF? Sampling? Different distributions? Edge cases (tails, extreme parameters)?

**Concrete alternatives:**
1. Per-operation targets: PDF ±1e-7, CDF ±1e-6, ICDF ±1e-5
2. Testing strategy: Compare vs SciPy on 100 random parameters for each distribution
3. Document known limitations: "Tails (beyond ±6σ) have lower accuracy; documented in RELEASE_NOTES.md"

**User should choose:** Which operations matter most? How many reference points?

---

## Evaluation Criteria for Review Quality

✓ **Good review:** Surfaces real ambiguities that would cause implementation delays
✓ **Good review:** Offers concrete choices (not just complaints)
✓ **Good review:** Distinguishes critical blocks from nice-to-haves
✗ **Bad review:** "This looks good" (no probing)
✗ **Bad review:** "You should do X" (prescriptive, not clarifying)

---

**After Review:**

1. Return this entire file with questions filled in
2. User answers questions in: `.eiffel-workflow/evidence/phase0-ai-review.md`
3. Questions + answers become requirements for implementation
4. No surprises during code review (all expectations set upfront)
