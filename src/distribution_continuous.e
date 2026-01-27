note
	description: "Base class for continuous probability distributions"
	author: "Eiffel Team"
	date: "2026-01-27"

deferred class DISTRIBUTION_CONTINUOUS

inherit
	DISTRIBUTION

feature {NONE} -- Random Generation

	randomizer: SIMPLE_RANDOMIZER
			-- Random number generator for sampling.
		note
			comment: "Each distribution instance has its own randomizer for SCOOP safety."
		deferred
		end

feature -- PDF (Probability Density Function)

	pdf (x: REAL_64): REAL_64
			-- Probability density function value at x.
		deferred
		ensure then
			result_non_negative: Result >= 0.0
		end

feature -- CDF (Cumulative Distribution Function)

	cdf (x: REAL_64): REAL_64
			-- Cumulative probability P(X ≤ x).
			-- For continuous distributions, CDF is monotonically increasing from 0 to 1.
		require else
			not_nan: not x.is_nan
		deferred
		ensure then
			at_minimum: x <= minimum implies Result ~ 0
			at_maximum: x >= maximum implies Result ~ 1
			cdf_bounded: Result >= 0 and Result <= 1
		end

feature -- ICDF (Inverse CDF / Quantile)

	icdf (p: REAL_64): REAL_64
			-- Quantile function (inverse CDF) at probability p.
			-- Returns the value x such that P(X ≤ x) = p.
		require else
			p_in_open_unit_interval: p > 0 and p < 1
		deferred
		ensure then
			icdf_of_half_is_median: (icdf (0.5) - median).abs < 0.000001
		end

feature -- Sampling

	sample: REAL_64
			-- Generate random sample from distribution using randomizer.
		deferred
		ensure then
			result_in_domain: in_domain (Result)
			result_not_nan: not Result.is_nan
		end

feature -- Properties

	median: REAL_64
			-- Median of distribution (50th percentile).
		do
			Result := icdf (0.5)
		ensure
			result_in_domain: in_domain (Result)
			cdf_at_median: (cdf (Result) - 0.5).abs < 0.000001
		end

	mode: REAL_64
			-- Mode of distribution (value with highest PDF).
			-- Default: mean. Subclasses override if different.
		do
			Result := mean
		ensure
			result_in_domain: in_domain (Result)
		end

feature {NONE} -- Boundary Checking

	on_boundary (x: REAL_64): BOOLEAN
			-- Is x on the boundary of the distribution support?
		do
			Result := (x = minimum or x = maximum)
		end

	parameters_satisfy_constraints: BOOLEAN
			-- Do all distribution parameters satisfy their constraints?
		deferred
		end

invariant
	parameters_valid: parameters_satisfy_constraints
	variance_non_negative: variance >= 0
	median_in_domain: in_domain (median)

end
