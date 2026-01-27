note
	description: "Exponential probability distribution Exp(λ)"
	author: "Eiffel Team"
	date: "2026-01-27"

class EXPONENTIAL_DISTRIBUTION

inherit
	DISTRIBUTION_CONTINUOUS
		redefine
			default_create
		end

create
	make, default_create

feature -- Initialization

	make (a_rate: REAL_64)
			-- Create Exponential distribution with rate parameter λ (rate = 1/mean).
		require
			rate_positive: a_rate > 0
		do
			rate := a_rate
			create internal_randomizer.make
			set_seed (0)
		ensure
			rate_set: rate = a_rate
		end

	default_create
			-- Create standard Exponential(1) with rate λ = 1.
		do
			rate := 1.0
			create internal_randomizer.make
			set_seed (0)
		ensure then
			standard_exponential: rate = 1.0
		end

feature -- Parameters

	rate: REAL_64
			-- Rate parameter λ (inverse of mean).

feature -- PDF

	pdf (x: REAL_64): REAL_64
			-- Probability density function: f(x) = λ * exp(-λ*x) for x ≥ 0.
		do
			if in_domain (x) then
				Result := rate * math_lib.exp (-rate * x)
			else
				Result := 0.0
			end
		end

feature -- CDF

	cdf (x: REAL_64): REAL_64
			-- Cumulative distribution function: F(x) = 1 - exp(-λ*x) for x ≥ 0.
		do
			if x < 0.0 then
				Result := 0.0
			else
				Result := 1.0 - math_lib.exp (-rate * x)
			end
		end

feature -- ICDF

	icdf (p: REAL_64): REAL_64
			-- Inverse CDF (quantile function): F^(-1)(p) = -ln(1-p) / λ.
		do
			Result := -math_lib.log (1.0 - p) / rate
		ensure then
			icdf_of_half_near_mean_ln2: (icdf (0.5) - mean * math_lib.log (2.0)).abs < 0.0000000001
		end

feature -- Sampling

	sample: REAL_64
			-- Generate Exponential random sample via inverse transform: -ln(U) / λ.
		local
			u: REAL_64
		do
			u := randomizer.random_real_in_range (0.0, 1.0)
			Result := -math_lib.log (u) / rate
		end

feature -- Properties

	mean: REAL_64
		do
			Result := 1.0 / rate
		end

	variance: REAL_64
		do
			Result := 1.0 / (rate * rate)
		end

feature -- Seeding

	set_seed (s: INTEGER)
		do
			-- Note: SIMPLE_RANDOMIZER doesn't have set_seed method.
			-- For deterministic sampling, create randomizer with make_with_seed.
			-- This is a limitation of Phase 1 - will be improved in Phase 1.5.
			-- For now, this is a stub.
		ensure then
			seed_set: next_samples_deterministic
		end

feature {NONE} -- Implementation

	internal_randomizer: SIMPLE_RANDOMIZER

	randomizer: SIMPLE_RANDOMIZER
		do
			Result := internal_randomizer
		end

	math_lib: SIMPLE_MATH
		once
			create Result.make
		end

	in_domain (x: REAL_64): BOOLEAN
		do
			Result := x >= 0
		end

	minimum: REAL_64
		do
			Result := 0.0
		end

	maximum: REAL_64
		do
			Result := {REAL_64}.positive_infinity
		end

	parameters_satisfy_constraints: BOOLEAN
		do
			Result := rate > 0
		end

invariant
	rate_positive: rate > 0

end
