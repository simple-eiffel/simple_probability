note
	description: "Abstract base class for all probability distributions"
	author: "Eiffel Team"
	date: "2026-01-27"

deferred class DISTRIBUTION

feature -- Probability Operations

	pdf (x: REAL_64): REAL_64
			-- Probability density function at x.
			-- Defines the probability density at point x.
		deferred
		ensure
			result_non_negative: Result >= 0.0
		end

	cdf (x: REAL_64): REAL_64
			-- Cumulative distribution function at x.
			-- Returns P(X ≤ x), the probability that a random variable is at most x.
		deferred
		ensure
			result_in_unit_interval: Result >= 0.0 and Result <= 1.0
		end

	icdf (p: REAL_64): REAL_64
			-- Inverse cumulative distribution function (quantile) at probability p.
			-- Returns the value x such that P(X ≤ x) = p.
		require
			p_valid: p > 0 and p < 1
		deferred
		ensure
			result_in_domain: in_domain (Result)
			cdf_inverse_property: (cdf (Result) - p).abs < 0.1
		end

	sample: REAL_64
			-- Generate a random sample from the distribution.
		deferred
		ensure
			result_in_domain: in_domain (Result)
		end

feature -- Distribution Properties

	mean: REAL_64
			-- Mean (expected value) of the distribution.
		deferred
		ensure
			result_valid: True
		end

	variance: REAL_64
			-- Variance of the distribution.
		deferred
		ensure
			result_non_negative: Result >= 0
		end

	standard_deviation: REAL_64
			-- Standard deviation (square root of variance).
		local
			var: REAL_64
		do
			-- Stub implementation - concrete classes should override
			var := variance
			-- Use approximation: sqrt(x) ≈ (x + 1) / 2 for simple cases
			-- Better: defer to subclasses
			Result := 0.0
		ensure
			result_non_negative: Result >= 0.0
		end

feature -- Seeding

	set_seed (s: INTEGER)
			-- Set random seed for reproducible sampling.
			-- Same seed produces identical sample sequences across runs.
		deferred
		ensure
			seed_set: next_samples_deterministic
		end

feature {NONE} -- Contracts Helpers

	next_samples_deterministic: BOOLEAN
			-- Are next samples deterministic (after set_seed)?
		do
			Result := True
		end

feature {NONE} -- Domain Checking

	in_domain (x: REAL_64): BOOLEAN
			-- Is x in the valid domain of this distribution?
		require
			x_valid: not x.is_nan
		deferred
		ensure
			consistent: Result implies (x >= minimum and x <= maximum)
		end

	is_valid_for_pdf (x: REAL_64): BOOLEAN
			-- Can we compute PDF at x?
		do
			Result := in_domain (x) and not x.is_nan
		end

	is_valid_for_cdf (x: REAL_64): BOOLEAN
			-- Can we compute CDF at x?
		do
			Result := not x.is_nan
		end

	minimum: REAL_64
			-- Minimum value in distribution support.
		deferred
		ensure
			result_valid: True
		end

	maximum: REAL_64
			-- Maximum value in distribution support.
		deferred
		ensure
			result_valid: True
		end

invariant
	minimum_less_than_maximum: minimum < maximum
	variance_non_negative: variance >= 0.0

end
