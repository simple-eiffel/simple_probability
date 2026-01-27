note
	description: "Uniform probability distribution U(a, b)"
	author: "Eiffel Team"
	date: "2026-01-27"

class UNIFORM_DISTRIBUTION

inherit
	DISTRIBUTION_CONTINUOUS
		redefine
			default_create
		end

create
	make, default_create

feature -- Initialization

	make (a_min, a_max: REAL_64)
			-- Create Uniform distribution on interval [a_min, a_max].
		require
			valid_bounds: a_min < a_max
		do
			min_value := a_min
			max_value := a_max
			create internal_randomizer.make
			set_seed (0)
		ensure
			min_set: min_value = a_min
			max_set: max_value = a_max
		end

	default_create
			-- Create standard Uniform U(0, 1).
		do
			min_value := 0.0
			max_value := 1.0
			create internal_randomizer.make
			set_seed (0)
		ensure then
			standard_uniform: min_value = 0.0 and max_value = 1.0
		end

feature -- Parameters

	min_value: REAL_64
			-- Minimum value a.

	max_value: REAL_64
			-- Maximum value b.

feature -- PDF

	pdf (x: REAL_64): REAL_64
			-- Probability density function: f(x) = 1/(b-a) for x in [a,b], 0 otherwise.
		local
			width: REAL_64
		do
			if in_domain (x) then
				width := max_value - min_value
				Result := 1.0 / width
			else
				Result := 0.0
			end
		end

feature -- CDF

	cdf (x: REAL_64): REAL_64
			-- Cumulative distribution function.
		local
			width: REAL_64
		do
			if x <= min_value then
				Result := 0.0
			elseif x >= max_value then
				Result := 1.0
			else
				width := max_value - min_value
				Result := (x - min_value) / width
			end
		end

feature -- ICDF

	icdf (p: REAL_64): REAL_64
			-- Inverse CDF: quantile function.
		local
			width: REAL_64
		do
			width := max_value - min_value
			Result := min_value + p * width
		ensure then
			icdf_of_half_is_midpoint: (icdf (0.5) - (min_value + max_value) / 2).abs < 0.0000000001
		end

feature -- Sampling

	sample: REAL_64
			-- Generate Uniform random sample via inverse transform.
		local
			u: REAL_64
		do
			u := randomizer.random_real_in_range (0.0, 1.0)
			Result := icdf (u)
		end

feature -- Properties

	mean: REAL_64
		do
			Result := (min_value + max_value) / 2.0
		end

	variance: REAL_64
		local
			width: REAL_64
		do
			width := max_value - min_value
			Result := (width * width) / 12.0
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

	in_domain (x: REAL_64): BOOLEAN
		do
			Result := x >= min_value and x <= max_value
		end

	minimum: REAL_64
		do
			Result := min_value
		end

	maximum: REAL_64
		do
			Result := max_value
		end

	parameters_satisfy_constraints: BOOLEAN
		do
			Result := min_value < max_value
		end

invariant
	bounds_valid: min_value < max_value

end
