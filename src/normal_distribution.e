note
	description: "Normal (Gaussian) probability distribution N(μ, σ)"
	author: "Eiffel Team"
	date: "2026-01-27"

class NORMAL_DISTRIBUTION

inherit
	DISTRIBUTION_CONTINUOUS
		redefine
			default_create,
			standard_deviation
		end

create
	make, default_create

feature -- Initialization

	make (a_mu, a_sigma: REAL_64)
			-- Create Normal distribution with mean `a_mu` and standard deviation `a_sigma`.
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
			-- Create standard Normal N(0, 1).
		do
			mu := 0.0
			sigma := 1.0
			create internal_randomizer.make
			set_seed (0)
		ensure then
			standard_normal: mu = 0.0 and sigma = 1.0
		end

feature -- Parameters

	mu: REAL_64
			-- Mean parameter μ.

	sigma: REAL_64
			-- Standard deviation parameter σ.

feature -- PDF

	pdf (x: REAL_64): REAL_64
			-- Probability density function: f(x) = (1/(σ√(2π))) * exp(-(x-μ)²/(2σ²))
		local
			z: REAL_64
			pi: REAL_64
			two_pi_sqrt: REAL_64
		do
			z := (x - mu) / sigma
			pi := math.pi
			two_pi_sqrt := math.sqrt (2.0 * pi)
			Result := (1.0 / (sigma * two_pi_sqrt)) * math.exp (-0.5 * z * z)
		end

feature -- CDF

	cdf (x: REAL_64): REAL_64
			-- Cumulative distribution function using standard normal CDF.
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
			-- Inverse CDF (quantile function).
		local
			facade: SIMPLE_PROBABILITY
		do
			create facade.make
			Result := mu + sigma * facade.inverse_standard_normal_cdf (p)
		ensure then
			icdf_of_half_is_mean: (icdf (0.5) - mu).abs < 0.000001
		end

feature -- Sampling

	sample: REAL_64
			-- Generate Normal random sample using Box-Muller transform.
		local
			u1, u2, r, theta: REAL_64
		do
			u1 := randomizer.random_real_in_range (0.0, 1.0)
			u2 := randomizer.random_real_in_range (0.0, 1.0)
			r := math.sqrt (-2.0 * math.log (u1))
			theta := 2.0 * math.pi * u2
			Result := mu + sigma * r * math.cos (theta)
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

	standard_deviation: REAL_64
			-- Standard deviation (sigma parameter).
		do
			Result := sigma
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
			-- Internal randomizer for sampling.

	randomizer: SIMPLE_RANDOMIZER
		do
			Result := internal_randomizer
		end

	math: SIMPLE_MATH
			-- Math library for exp, sqrt, pi.
		once
			create Result.make
		end

	in_domain (x: REAL_64): BOOLEAN
		do
			Result := True  -- Normal has unbounded support
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
			Result := sigma > 0.0 and sigma < 10000000000.0
		end

invariant
	sigma_positive: sigma > 0
	sigma_reasonable: sigma < 10000000000.0

end
