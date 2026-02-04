note
	description: "Three-tier fixture hierarchy for probability distribution tests"
	author: "Larry Rix with Claude (Anthropic)"
	date: "$Date$"
	revision: "$Revision$"

class
	DISTRIBUTION_FIXTURES

inherit
	TEST_SET_BASE

feature -- Tier 1: Standard Distributions

	std_normal: NORMAL_DISTRIBUTION
			-- Standard normal distribution N(0,1)
		once
			create Result
		ensure
			distribution_created: Result /= Void
			mean_is_zero: Result.mean ~ 0.0
			std_dev_is_one: Result.standard_deviation ~ 1.0
		end

	std_uniform: UNIFORM_DISTRIBUTION
			-- Standard uniform distribution U(0,1)
		once
			create Result.make (0.0, 1.0)
		ensure
			distribution_created: Result /= Void
		end

feature -- Tier 2: Parameterized Distributions

	custom_normal: NORMAL_DISTRIBUTION
			-- Custom normal distribution N(100, 15) where 15 is standard deviation
		once
			create Result.make (100.0, 15.0)
		ensure
			distribution_created: Result /= Void
			mean_set: Result.mean ~ 100.0
			variance_set: Result.variance ~ 225.0
		end

	binomial_dist: BINOMIAL_DISTRIBUTION
			-- Binomial distribution with n=20, p=0.3
		once
			create Result.make (20, 0.3)
		ensure
			distribution_created: Result /= Void
		end

	exponential_dist: EXPONENTIAL_DISTRIBUTION
			-- Exponential distribution with rate λ=2.0
		once
			create Result.make (2.0)
		ensure
			distribution_created: Result /= Void
		end

feature -- Tier 3: Seeded Distributions

	seeded_normal_1: NORMAL_DISTRIBUTION
			-- Normal distribution with fixed seed for reproducibility
		once
			create Result.make (0.0, 1.0)
			Result.set_seed (42)
		ensure
			distribution_created: Result /= Void
			seed_set: Result /= Void
		end

	seeded_normal_2: NORMAL_DISTRIBUTION
			-- Second normal distribution with same seed (for comparison)
		once
			create Result.make (0.0, 1.0)
			Result.set_seed (42)
		ensure
			distribution_created: Result /= Void
			seed_set: Result /= Void
		end

	narrow_normal: NORMAL_DISTRIBUTION
			-- Normal distribution with very small sigma (σ = 0.0001)
		once
			create Result.make (0.0, 0.0001)
		ensure
			distribution_created: Result /= Void
			very_small_variance: Result.variance ~ 0.0001
		end

	wide_normal: NORMAL_DISTRIBUTION
			-- Normal distribution with very large sigma (σ = 10000)
		once
			create Result.make (0.0, 10000.0)
		ensure
			distribution_created: Result /= Void
			very_large_variance: Result.variance ~ 10000.0
		end

	negative_mean_normal: NORMAL_DISTRIBUTION
			-- Normal distribution with negative mean (μ = -1000)
		once
			create Result.make (-1000.0, 1.0)
		ensure
			distribution_created: Result /= Void
			negative_mean_set: Result.mean ~ -1000.0
		end

	extreme_positive_normal: NORMAL_DISTRIBUTION
			-- Normal distribution with very large positive mean (μ = 1e6)
		once
			create Result.make (1000000.0, 1.0)
		ensure
			distribution_created: Result /= Void
			large_mean_set: Result.mean ~ 1000000.0
		end

end
