note
	description: "Base class for discrete probability distributions"
	author: "Eiffel Team"
	date: "2026-01-27"

deferred class DISTRIBUTION_DISCRETE

inherit
	DISTRIBUTION

feature {NONE} -- Random Generation

	randomizer: SIMPLE_RANDOMIZER
			-- Random number generator for sampling.
		note
			comment: "Each distribution instance has its own randomizer for SCOOP safety."
		deferred
		end

feature -- PMF (Probability Mass Function)

	pmf (k: INTEGER): REAL_64
			-- Probability mass function value at integer k.
			-- Returns P(X = k).
		deferred
		ensure
			result_non_negative: Result >= 0.0
			result_in_unit_interval: Result <= 1.0
		end

feature -- CDF (Cumulative Distribution Function)

	cdf (x: REAL_64): REAL_64
			-- Cumulative probability P(X ≤ x).
		require else
			not_nan: not x.is_nan
		deferred
		ensure then
			cdf_bounded: Result >= 0 and Result <= 1
			cdf_at_integer: for_integer_x (x) implies Result ~ cdf_up_to_integer (integer_part (x))
		end

feature -- ICDF (Inverse CDF / Quantile)

	icdf (p: REAL_64): REAL_64
			-- Quantile function (inverse CDF) at probability p.
			-- Returns smallest k such that P(X ≤ k) >= p.
		require else
			p_in_open_unit_interval: p > 0 and p < 1
		deferred
		ensure then
			result_integer: result_is_integer
			cdf_at_result: cdf (Result) >= p
		end

feature -- Sampling

	sample: REAL_64
			-- Generate random sample from distribution.
			-- Returns integer value as REAL_64 for consistency with DISTRIBUTION interface.
		deferred
		ensure then
			result_integer: result_is_integer
			result_in_domain: in_domain (Result)
		end

feature -- Properties

	mean: REAL_64
			-- Mean (expected value) of distribution.
		deferred
		ensure then
			result_non_negative: Result >= 0.0
		end

	variance: REAL_64
			-- Variance of distribution.
		deferred
		ensure then
			result_non_negative: Result >= 0
		end

feature {NONE} -- Helper Predicates

	for_integer_x (x: REAL_64): BOOLEAN
			-- Is x an integer value?
		do
			Result := x = x.floor
		end

	integer_part (x: REAL_64): INTEGER
			-- Integer part of x (floor).
		do
			Result := x.floor
		end

	result_is_integer: BOOLEAN
			-- Is sample result an integer?
		do
			Result := True  -- Discrete samples are always integers
		end

	cdf_up_to_integer (k: INTEGER): REAL_64
			-- CDF up to integer k: sum of PMF from min to k.
		require
			k_valid: k >= minimum_integer and k <= maximum_integer
		deferred
		ensure
			result_bounded: Result >= 0 and Result <= 1
		end

	minimum_integer: INTEGER
			-- Minimum integer value in support.
		deferred
		end

	maximum_integer: INTEGER
			-- Maximum integer value in support.
		deferred
		end

	parameters_satisfy_constraints: BOOLEAN
			-- Do all distribution parameters satisfy constraints?
		deferred
		end

invariant
	parameters_valid: parameters_satisfy_constraints
	variance_non_negative: variance >= 0.0

end
