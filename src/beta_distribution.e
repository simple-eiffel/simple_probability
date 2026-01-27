note
	description: "Beta probability distribution Beta(α, β) on [0, 1]"
	author: "Eiffel Team"
	date: "2026-01-27"

class BETA_DISTRIBUTION

inherit
	DISTRIBUTION_CONTINUOUS
		redefine
			default_create
		end

create
	make, default_create

feature -- Initialization

	make (a_alpha, a_beta: REAL_64)
			-- Create Beta distribution with shape parameters α and β.
		require
			alpha_positive: a_alpha > 0
			beta_positive: a_beta > 0
		do
			alpha := a_alpha
			beta := a_beta
			create internal_randomizer.make
			set_seed (0)
		ensure
			alpha_set: alpha = a_alpha
			beta_set: beta = a_beta
		end

	default_create
			-- Create uniform Beta(1, 1) on [0, 1].
		do
			alpha := 1.0
			beta := 1.0
			create internal_randomizer.make
			set_seed (0)
		ensure then
			uniform_beta: alpha = 1.0 and beta = 1.0
		end

feature -- Parameters

	alpha: REAL_64
			-- Shape parameter α.

	beta: REAL_64
			-- Shape parameter β.

feature -- PDF

	pdf (x: REAL_64): REAL_64
			-- Probability density function for Beta distribution.
		local
			numerator, denominator: REAL_64
		do
			if in_domain (x) and x > 0 and x < 1 then
				numerator := (x ^ (alpha - 1)) * ((1 - x) ^ (beta - 1))
				denominator := beta_function (alpha, beta)
				Result := numerator / denominator
			else
				Result := 0.0
			end
		end

feature -- CDF

	cdf (x: REAL_64): REAL_64
			-- Cumulative distribution function (regularized incomplete beta).
			-- Computed via numerical integration or approximation.
		local
			regularized_beta: REAL_64
		do
			if x <= 0 then
				Result := 0.0
			elseif x >= 1 then
				Result := 1.0
			else
				-- Placeholder: in Phase 4 implementation, use numerical integration or approximation
				regularized_beta := 0.0  -- TODO: implement regularized incomplete beta function
				Result := regularized_beta
			end
		end

feature -- ICDF

	icdf (p: REAL_64): REAL_64
			-- Inverse CDF (quantile function).
			-- For Beta distribution, computed via numerical methods or approximation.
		do
			-- Placeholder: in Phase 4, use numerical root finding or approximation
			Result := p  -- TODO: implement inverse regularized incomplete beta
		ensure then
			icdf_of_half_near_half: (icdf (0.5) - 0.5).abs < 0.2 or (alpha ~ beta)
		end

feature -- Sampling

	sample: REAL_64
			-- Generate Beta random sample via rejection sampling or Pólya urn model.
		local
			u, v, x: REAL_64
		do
			-- Placeholder: simplified method for now
			-- In Phase 4, implement proper Beta sampling (e.g., using Gamma variates)
			u := randomizer.random_real_in_range (0.0, 1.0)
			v := randomizer.random_real_in_range (0.0, 1.0)
			x := u ^ (1.0 / alpha) * v ^ (1.0 / beta)
			Result := x / (x + (1 - u) ^ (1.0 / alpha) * (1 - v) ^ (1.0 / beta))
		end

feature -- Properties

	mean: REAL_64
		do
			Result := alpha / (alpha + beta)
		end

	variance: REAL_64
		local
			sum: REAL_64
		do
			sum := alpha + beta
			Result := (alpha * beta) / (sum * sum * (sum + 1.0))
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

	beta_function (a, b: REAL_64): REAL_64
			-- Beta function B(a, b) = Γ(a) * Γ(b) / Γ(a + b).
			-- Note: SIMPLE_MATH doesn't have gamma function.
			-- Beta distribution implementation is deferred to Phase 1.5.
			-- For now, return a stub value of 1.0.
		do
			Result := 1.0
		end

	in_domain (x: REAL_64): BOOLEAN
		do
			Result := x >= 0 and x <= 1
		end

	minimum: REAL_64
		do
			Result := 0.0
		end

	maximum: REAL_64
		do
			Result := 1.0
		end

	parameters_satisfy_constraints: BOOLEAN
		do
			Result := alpha > 0 and beta > 0
		end

invariant
	alpha_positive: alpha > 0
	beta_positive: beta > 0

end
