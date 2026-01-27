note
	description: "Binomial probability distribution Binomial(n, p)"
	author: "Eiffel Team"
	date: "2026-01-27"

class BINOMIAL_DISTRIBUTION

inherit
	DISTRIBUTION_DISCRETE
		redefine
			default_create
		end

create
	make, default_create

feature -- Initialization

	make (a_n: INTEGER; a_p: REAL_64)
			-- Create Binomial distribution with n trials and success probability p.
		require
			n_positive: a_n > 0
			p_valid: a_p >= 0 and a_p <= 1
		do
			n := a_n
			p := a_p
			create internal_randomizer.make
			set_seed (0)
		ensure
			n_set: n = a_n
			p_set: p = a_p
		end

	default_create
			-- Create Binomial(1, 0.5) - single fair coin flip.
		do
			n := 1
			p := 0.5
			create internal_randomizer.make
			set_seed (0)
		ensure then
			single_fair_trial: n = 1 and p = 0.5
		end

feature -- Parameters

	n: INTEGER
			-- Number of trials.

	p: REAL_64
			-- Probability of success in each trial.

feature -- PDF (from DISTRIBUTION interface - discrete variant uses pmf)

	pdf (x: REAL_64): REAL_64
			-- Probability density (for discrete, returns pmf at floor(x)).
		do
			-- For discrete distributions, pdf returns pmf at integer value
			if x = x.floor then
				Result := pmf (x.floor)
			else
				Result := 0.0
			end
		end

feature -- PMF

	pmf (k: INTEGER): REAL_64
			-- Probability mass function: P(X = k) = C(n,k) * p^k * (1-p)^(n-k).
		local
			binom_coeff: REAL_64
		do
			if k < 0 or k > n then
				Result := 0.0
			else
				binom_coeff := binomial_coefficient (n, k)
				Result := binom_coeff * (p ^ k) * ((1.0 - p) ^ (n - k))
			end
		end

feature -- CDF

	cdf (x: REAL_64): REAL_64
			-- Cumulative distribution function: P(X ≤ floor(x)).
		local
			k_upper: INTEGER
		do
			if x < 0.0 then
				Result := 0.0
			elseif x >= n.to_double then
				Result := 1.0
			else
				k_upper := x.floor
				Result := cdf_up_to_integer (k_upper)
			end
		end

feature -- ICDF

	icdf (prob: REAL_64): REAL_64
			-- Inverse CDF (quantile function).
			-- Returns smallest k such that P(X ≤ k) ≥ prob.
		local
			k: INTEGER
			cumulative: REAL_64
		do
			cumulative := 0.0
			from k := 0 until k > n or cumulative >= prob loop
				cumulative := cumulative + pmf (k)
				if cumulative < prob then k := k + 1 end
			end
			Result := k.to_double
		ensure then
			result_integer: (Result - Result.floor).abs < 0.0000000001
		end

feature -- Sampling

	sample: REAL_64
			-- Generate Binomial random sample via Bernoulli trials.
		local
			successes: INTEGER
			i: INTEGER
			u: REAL_64
		do
			from i := 1 until i > n loop
				u := randomizer.random_real_in_range (0.0, 1.0)
				if u < p then
					successes := successes + 1
				end
				i := i + 1
			end
			Result := successes.to_double
		end

feature -- Properties

	mean: REAL_64
		do
			Result := n.to_double * p
		end

	variance: REAL_64
		do
			Result := n.to_double * p * (1.0 - p)
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

	binomial_coefficient (n_val, k: INTEGER): REAL_64
			-- Compute C(n, k) = n! / (k! * (n-k)!).
		require
			n_non_negative: n_val >= 0
			k_valid: k >= 0 and k <= n_val
		local
			i: INTEGER
			result_val: REAL_64
		do
			result_val := 1.0
			from i := 0 until i >= k loop
				result_val := result_val * (n_val - i).to_double / (i + 1).to_double
				i := i + 1
			end
			Result := result_val
		ensure
			result_positive: Result > 0
		end

	minimum_integer: INTEGER
		do
			Result := 0
		end

	maximum_integer: INTEGER
		do
			Result := n
		end

	cdf_up_to_integer (k: INTEGER): REAL_64
		local
			i: INTEGER
			cumulative: REAL_64
		do
			from i := 0 until i > k loop
				cumulative := cumulative + pmf (i)
				i := i + 1
			end
			Result := cumulative
		ensure then
			result_bounded: Result >= 0 and Result <= 1
		end

	in_domain (x: REAL_64): BOOLEAN
		do
			Result := x >= 0 and x <= n
		end

	minimum: REAL_64
		do
			Result := 0.0
		end

	maximum: REAL_64
		do
			Result := n.to_double
		end

	parameters_satisfy_constraints: BOOLEAN
		do
			Result := n > 0 and p >= 0 and p <= 1
		end

invariant
	n_positive: n > 0
	p_valid: p >= 0 and p <= 1

end
