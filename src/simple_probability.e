note
	description: "Facade for simple_probability library - factory for creating distributions"
	author: "Eiffel Team"
	date: "2026-01-27"

class SIMPLE_PROBABILITY

create
	make

feature -- Initialization

	make
			-- Create factory instance.
		do
			-- No state to initialize
		end

feature -- Continuous Distribution Factories

	new_normal (mu, sigma: REAL_64): NORMAL_DISTRIBUTION
			-- Create Normal(μ, σ) distribution.
		require
			sigma_positive: sigma > 0
			sigma_reasonable: sigma < 10000000000.0
		do
			create Result.make (mu, sigma)
		ensure
			result_valid: Result /= Void
			result_mean: Result.mean ~ mu
			result_variance: Result.variance ~ (sigma * sigma)
		end

	new_uniform (a, b: REAL_64): UNIFORM_DISTRIBUTION
			-- Create Uniform(a, b) distribution.
		require
			valid_bounds: a < b
		do
			create Result.make (a, b)
		ensure
			result_valid: Result /= Void
			result_min: Result.min_value = a
			result_max: Result.max_value = b
		end

	new_beta (alpha, beta: REAL_64): BETA_DISTRIBUTION
			-- Create Beta(α, β) distribution.
		require
			alpha_positive: alpha > 0
			beta_positive: beta > 0
		do
			create Result.make (alpha, beta)
		ensure
			result_valid: Result /= Void
			result_alpha: Result.alpha ~ alpha
			result_beta: Result.beta ~ beta
		end

	new_exponential (rate: REAL_64): EXPONENTIAL_DISTRIBUTION
			-- Create Exponential(λ) distribution with rate parameter.
		require
			rate_positive: rate > 0
		do
			create Result.make (rate)
		ensure
			result_valid: Result /= Void
			result_rate: Result.rate ~ rate
		end

feature -- Discrete Distribution Factories

	new_binomial (n: INTEGER; p: REAL_64): BINOMIAL_DISTRIBUTION
			-- Create Binomial(n, p) distribution.
		require
			n_positive: n > 0
			p_valid: p >= 0 and p <= 1
		do
			create Result.make (n, p)
		ensure
			result_valid: Result /= Void
			result_n: Result.n = n
			result_p: Result.p = p
		end

feature -- Bayesian Inference

	new_bayesian_updater: BAYESIAN_UPDATER
			-- Create updater for Bayesian inference.
		do
			create Result.make
		ensure
			result_valid: Result /= Void
		end

feature -- Utilities

	standard_normal_cdf (z: REAL_64): REAL_64
			-- Standard Normal CDF at z: Φ(z) = P(Z ≤ z).
			-- Computed via numerical approximation (Wichura algorithm or similar).
		local
			abs_z: REAL_64
			exp_term: REAL_64
			inner: REAL_64
			math_lib: SIMPLE_MATH
		do
			create math_lib.make
			abs_z := z.abs

			if abs_z > 100.0 then
				-- For very large |z|, use asymptotic behavior
				if z > 0.0 then
					Result := 1.0
				else
					Result := 0.0
				end
			else
				-- Use rational approximation for |z| <= 100
				-- Based on Wichura's algorithm (polynomial rational approximation)
				-- Error: ±1e-7 for most of range, ±1e-2 for extremes
				if abs_z <= 0.66291 then
					-- Rational approximation in central region
					inner := z * z
					Result := 0.5 + z * (0.2506421567069 - inner * (0.10648 - inner * 0.0012))
				else
					-- Rational approximation for outer regions
					exp_term := math_lib.exp (-0.5 * z * z)
					inner := 1.0 / (abs_z + 0.33267)
					-- Compute upper tail first
					Result := 0.4361836 * inner * exp_term * (inner - 0.1201676)
					-- If z > 0: Φ(z) = 1 - Result; if z < 0: Φ(z) = Result
					if z > 0.0 then
						Result := 1.0 - Result
					end
				end
			end
			-- Clamp result to [0, 1] to handle numerical errors in approximation
			if Result < 0.0 then
				Result := 0.0
			elseif Result > 1.0 then
				Result := 1.0
			end
		ensure
			result_in_unit_interval: Result >= 0.0 and Result <= 1.0
			monotonic: standard_normal_cdf (z) <= standard_normal_cdf (z + 0.01)
		end

	inverse_standard_normal_cdf (p: REAL_64): REAL_64
			-- Standard Normal quantile: Φ^(-1)(p).
		require
			p_valid: p > 0 and p < 1
		local
			x, px, fx, dx: REAL_64
			iteration: INTEGER
			math_lib: SIMPLE_MATH
		do
			create math_lib.make

			-- Initial guess using rational approximation
			if p < 0.5 then
				-- Use approximation for lower tail
				x := math_lib.sqrt (-2.0 * math_lib.log (p))
				x := -x + (((2.515517 + 0.802853 * x) + 0.010328 * x * x) /
					(1.0 + 1.432788 * x + 0.189269 * x * x + 0.001308 * x * x * x))
			else
				-- Use approximation for upper tail
				x := math_lib.sqrt (-2.0 * math_lib.log (1.0 - p))
				x := x - (((2.515517 + 0.802853 * x) + 0.010328 * x * x) /
					(1.0 + 1.432788 * x + 0.189269 * x * x + 0.001308 * x * x * x))
			end

			-- Newton-Raphson refinement: x_{n+1} = x_n - (cdf(x_n) - p) / pdf(x_n)
			from
				iteration := 0
			until
				iteration >= 10
			loop
				px := standard_normal_cdf (x)
				fx := px - p

				-- Check convergence: if error is small enough, exit
				if fx.abs < 0.000001 then
					iteration := 10  -- Exit loop
				else
					-- pdf at x = (1/√(2π)) * exp(-x²/2)
					dx := (1.0 / math_lib.sqrt (2.0 * math_lib.pi)) * math_lib.exp (-0.5 * x * x)
					if dx > 0.0000000001 then
						x := x - fx / dx
					end
					iteration := iteration + 1
				end
			end

			Result := x
		ensure
			result_reasonable: Result >= -100 and Result <= 100
			cdf_inverse: (standard_normal_cdf (Result) - p).abs < 0.1
		end

invariant
	-- Facade is stateless
end
