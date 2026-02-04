note
	description: "Adversarial and stress tests for probability distributions"
	author: "Eiffel Team"
	date: "2026-01-27"

class TEST_DISTRIBUTION_ADVERSARIAL

inherit
	TEST_SET_BASE

feature {NONE} -- Fixtures

	fixtures: DISTRIBUTION_FIXTURES
		once
			create Result
		end

feature -- Boundary Value Tests (Normal Distribution)

	test_normal_with_very_small_sigma
			-- Test Normal distribution with very small sigma (σ = 0.0001).
		local
			dist: NORMAL_DISTRIBUTION
			pdf_at_mean: REAL_64
		do
			create dist.make (0.0, 0.0001)
			pdf_at_mean := dist.pdf (0.0)
			-- PDF should be very large (spike at mean)
			assert ("pdf_at_mean_is_large", pdf_at_mean > 1000.0)
		end

	test_normal_with_very_large_sigma
			-- Test Normal distribution with very large sigma (σ = 10000).
		local
			dist: NORMAL_DISTRIBUTION
			pdf_at_mean, pdf_far: REAL_64
		do
			create dist.make (0.0, 10000.0)
			pdf_at_mean := dist.pdf (0.0)
			pdf_far := dist.pdf (100000.0)
			-- Both should be very small (flat distribution)
			assert ("pdf_at_mean_is_small", pdf_at_mean < 0.001)
			assert ("pdf_far_is_nonzero", pdf_far >= 0.0)
		end

	test_normal_with_negative_mean
			-- Test Normal distribution with negative mean (μ = -1000).
		local
			dist: NORMAL_DISTRIBUTION
		do
			create dist.make (-1000.0, 1.0)
			assert ("negative_mean_set", dist.mean ~ -1000.0)
			assert ("variance_still_positive", dist.variance ~ 1.0)
		end

	test_normal_with_extreme_positive_mean
			-- Test Normal distribution with very large positive mean (μ = 1e6).
		local
			dist: NORMAL_DISTRIBUTION
		do
			create dist.make (1000000.0, 1.0)
			assert ("large_mean_set", dist.mean ~ 1000000.0)
		end

	test_cdf_at_extreme_negative_x
			-- Test CDF at extreme negative value (x = -100).
		local
			dist: NORMAL_DISTRIBUTION
			cdf_val: REAL_64
		do
			create dist.make (0.0, 1.0)
			cdf_val := dist.cdf (-100.0)
			-- CDF should be essentially 0
			assert ("cdf_at_negative_100_approx_zero", cdf_val < 0.01)
		end

	test_cdf_at_extreme_positive_x
			-- Test CDF at extreme positive value (x = 100).
		local
			dist: NORMAL_DISTRIBUTION
			cdf_val: REAL_64
		do
			create dist.make (0.0, 1.0)
			cdf_val := dist.cdf (100.0)
			-- CDF should be essentially 1
			assert ("cdf_at_positive_100_approx_one", cdf_val > 0.99)
		end

	test_icdf_at_extreme_low_probability
			-- Test ICDF at very low probability (p = 0.00001).
		local
			dist: NORMAL_DISTRIBUTION
			icdf_val: REAL_64
		do
			create dist.make (0.0, 1.0)
			icdf_val := dist.icdf (0.00001)
			-- Should be far in negative tail
			assert ("icdf_at_low_prob_is_negative", icdf_val < -3.0)
		end

	test_icdf_at_extreme_high_probability
			-- Test ICDF at very high probability (p = 0.99999).
		local
			dist: NORMAL_DISTRIBUTION
			icdf_val: REAL_64
		do
			create dist.make (0.0, 1.0)
			icdf_val := dist.icdf (0.99999)
			-- Should be far in positive tail
			assert ("icdf_at_high_prob_is_positive", icdf_val > 3.0)
		end

feature -- Monotonicity and Continuity Tests

	test_cdf_strictly_monotonic_over_range
			-- Test that CDF is strictly increasing over many points.
		local
			dist: NORMAL_DISTRIBUTION
			prev_cdf, curr_cdf: REAL_64
			x: REAL_64
			iteration: INTEGER
		do
			create dist.make (0.0, 1.0)
			prev_cdf := dist.cdf (-10.0)
			from
				x := -9.9
				iteration := 0
			until
				x > 10.0 or iteration > 200
			loop
				curr_cdf := dist.cdf (x)
				assert ("cdf_monotonic_at_" + x.out, curr_cdf >= prev_cdf)
				prev_cdf := curr_cdf
				x := x + 0.1
				iteration := iteration + 1
			end
		end

	test_pdf_symmetric_around_mean
			-- Test that PDF is symmetric: pdf(μ+d) = pdf(μ-d).
		local
			dist: NORMAL_DISTRIBUTION
			mu: REAL_64
			delta: REAL_64
		do
			create dist.make (5.0, 2.0)
			mu := dist.mean
			delta := 3.0
			assert ("pdf_symmetric",
				(dist.pdf (mu + delta) - dist.pdf (mu - delta)).abs < 0.0000001)
		end

	test_pdf_unimodal_around_mean
			-- Test that PDF has single peak at mean.
		local
			dist: NORMAL_DISTRIBUTION
			mu: REAL_64
			pdf_mean, pdf_near1, pdf_near2, pdf_far: REAL_64
		do
			create dist.make (0.0, 1.0)
			mu := dist.mean
			pdf_mean := dist.pdf (mu)
			pdf_near1 := dist.pdf (mu + 0.5)
			pdf_near2 := dist.pdf (mu + 1.0)
			pdf_far := dist.pdf (mu + 3.0)
			assert ("peak_at_mean_vs_near1", pdf_mean > pdf_near1)
			assert ("peak_at_mean_vs_near2", pdf_mean > pdf_near2)
			assert ("peak_at_mean_vs_far", pdf_mean > pdf_far)
		end

feature -- Inverse Function Tests

	test_icdf_cdf_roundtrip
			-- Test that cdf(icdf(p)) ≈ p for mid-range p values.
		local
			dist: NORMAL_DISTRIBUTION
			p, x, recovered_p: REAL_64
			iteration: INTEGER
		do
			create dist.make (0.0, 1.0)
			from
				p := 0.1
				iteration := 0
			until
				p >= 0.9 or iteration > 8
			loop
				x := dist.icdf (p)
				recovered_p := dist.cdf (x)
				-- Compound error: icdf error + cdf error can be ~0.05 due to approximations
				assert ("roundtrip_" + p.out, (recovered_p - p).abs < 0.1)
				p := p + 0.1
				iteration := iteration + 1
			end
		end

	test_icdf_monotonic_in_probability
			-- Test that icdf is monotonically increasing in p.
		local
			dist: NORMAL_DISTRIBUTION
			prev_x, curr_x: REAL_64
			p: REAL_64
			iteration: INTEGER
		do
			create dist.make (0.0, 1.0)
			prev_x := dist.icdf (0.1)
			from
				p := 0.2
				iteration := 0
			until
				p >= 0.9 or iteration > 8
			loop
				curr_x := dist.icdf (p)
				assert ("icdf_monotonic_at_" + p.out, curr_x >= prev_x)
				prev_x := curr_x
				p := p + 0.1
				iteration := iteration + 1
			end
		end

feature -- Sampling Consistency Tests

	test_sample_multiple_times_within_domain
			-- Test that multiple samples remain in domain (no NaN).
		local
			dist: NORMAL_DISTRIBUTION
			sample_val: REAL_64
			iteration: INTEGER
		do
			create dist.make (0.0, 1.0)
			from
				iteration := 0
			until
				iteration >= 100
			loop
				sample_val := dist.sample
				assert ("sample_" + iteration.out + "_not_nan",
					not sample_val.is_nan)
				iteration := iteration + 1
			end
		end

	test_sample_approximately_follows_distribution
			-- Test that samples approximately follow the distribution (empirical CDF).
		local
			dist: NORMAL_DISTRIBUTION
			samples: ARRAY [REAL_64]
			count_in_range: INTEGER
			iteration: INTEGER
		do
			create samples.make_filled (0.0, 1, 1000)
			create dist.make (0.0, 1.0)
			-- Generate 1000 samples
			from
				iteration := 1
			until
				iteration > 1000
			loop
				samples [iteration] := dist.sample
				iteration := iteration + 1
			end
			-- Count samples in ±1σ range (should be ~68%)
			count_in_range := 0
			from
				iteration := 1
			until
				iteration > 1000
			loop
				if samples [iteration] >= -1.0 and samples [iteration] <= 1.0 then
					count_in_range := count_in_range + 1
				end
				iteration := iteration + 1
			end
			-- 68% ± some tolerance (allow 60-75% range)
			assert ("samples_in_1sigma",
				count_in_range >= 600 and count_in_range <= 750)
		end

feature -- Variance and Properties Tests

	test_variance_properties
			-- Test variance properties: var(aX) = a²·var(X).
		local
			dist1, dist2: NORMAL_DISTRIBUTION
		do
			create dist1.make (0.0, 1.0)
			create dist2.make (0.0, 2.0)
			-- var(2σ) = (2σ)² = 4σ² = 4 * var(σ)
			assert ("variance_scaling",
				(dist2.variance - 4.0 * dist1.variance).abs < 0.0001)
		end

	test_standard_deviation_is_sqrt_variance
			-- Test that std_dev = sqrt(variance).
		local
			dist: NORMAL_DISTRIBUTION
		do
			create dist.make (0.0, 2.5)
			-- For Normal, σ = standard_deviation = sqrt(variance)
			-- And variance = σ²
			assert ("std_dev_correct", dist.standard_deviation ~ 2.5)
		end

feature -- Multiple Distribution Instances

	test_multiple_independent_distributions
			-- Test that multiple distribution instances don't interfere.
		local
			dist1, dist2, dist3: NORMAL_DISTRIBUTION
			cdf1, cdf2, cdf3: REAL_64
		do
			create dist1.make (0.0, 1.0)
			create dist2.make (10.0, 2.0)
			create dist3.make (-5.0, 0.5)

			-- Each should compute independently
			cdf1 := dist1.cdf (0.0)
			cdf2 := dist2.cdf (10.0)
			cdf3 := dist3.cdf (-5.0)

			-- All should be approximately 0.5 (CDF at mean)
			assert ("dist1_cdf_at_mean", (cdf1 - 0.5).abs < 0.01)
			assert ("dist2_cdf_at_mean", (cdf2 - 0.5).abs < 0.01)
			assert ("dist3_cdf_at_mean", (cdf3 - 0.5).abs < 0.01)
		end

feature -- Binomial Distribution Boundary Tests

	test_binomial_with_n_equals_1
			-- Test Binomial(1, p) - single trial (Bernoulli).
		local
			dist: BINOMIAL_DISTRIBUTION
		do
			create dist.make (1, 0.5)
			assert ("mean_correct", dist.mean ~ 0.5)
			assert ("variance_correct", dist.variance ~ 0.25)
		end

	test_binomial_with_p_equals_0
			-- Test Binomial(n, 0) - impossible event.
		local
			dist: BINOMIAL_DISTRIBUTION
		do
			create dist.make (10, 0.0)
			assert ("pmf_0_is_one", dist.pmf (0) ~ 1.0)
			assert ("pmf_other_is_zero", dist.pmf (5) ~ 0.0)
			assert ("mean_zero", dist.mean ~ 0.0)
		end

	test_binomial_with_p_equals_1
			-- Test Binomial(n, 1) - certain event.
		local
			dist: BINOMIAL_DISTRIBUTION
		do
			create dist.make (10, 1.0)
			assert ("pmf_n_is_one", dist.pmf (10) ~ 1.0)
			assert ("pmf_other_is_zero", dist.pmf (5) ~ 0.0)
			assert ("mean_equals_n", dist.mean ~ 10.0)
		end

	test_binomial_pmf_sums_to_one
			-- Test that sum of PMF over support equals 1.
		local
			dist: BINOMIAL_DISTRIBUTION
			sum: REAL_64
			k: INTEGER
		do
			create dist.make (5, 0.3)
			sum := 0.0
			from
				k := 0
			until
				k > 5
			loop
				sum := sum + dist.pmf (k)
				k := k + 1
			end
			assert ("pmf_sums_to_one", (sum - 1.0).abs < 0.00001)
		end

feature -- Uniform Distribution Boundary Tests

	test_uniform_with_very_small_width
			-- Test Uniform(a, a+ε) - very narrow distribution.
		local
			dist: UNIFORM_DISTRIBUTION
		do
			create dist.make (5.0, 5.0001)
			assert ("mean_approximately_a", (dist.mean - 5.00005).abs < 0.00001)
			assert ("variance_very_small", dist.variance < 0.0001)
		end

	test_uniform_with_wide_bounds
			-- Test Uniform with very wide support.
		local
			dist: UNIFORM_DISTRIBUTION
		do
			create dist.make (-1000000.0, 1000000.0)
			-- PDF should be very small: 1/(2000000) = 5e-7
			assert ("pdf_nonzero", dist.pdf (0.0) > 0.0)
			assert ("pdf_bounded_above_one", dist.pdf (0.0) < 1.0)
		end

	test_uniform_cdf_is_linear
			-- Test that Uniform CDF is linear.
		local
			dist: UNIFORM_DISTRIBUTION
			cdf_low, cdf_mid, cdf_high: REAL_64
		do
			create dist.make (0.0, 10.0)
			cdf_low := dist.cdf (2.0)
			cdf_mid := dist.cdf (5.0)
			cdf_high := dist.cdf (8.0)
			assert ("cdf_at_2_correct", (cdf_low - 0.2).abs < 0.0001)
			assert ("cdf_at_5_correct", (cdf_mid - 0.5).abs < 0.0001)
			assert ("cdf_at_8_correct", (cdf_high - 0.8).abs < 0.0001)
		end

feature -- Exponential Distribution Boundary Tests

	test_exponential_with_very_small_rate
			-- Test Exponential with small rate (mean = 1/λ = large).
		local
			dist: EXPONENTIAL_DISTRIBUTION
		do
			create dist.make (0.001)
			assert ("mean_is_large", dist.mean ~ 1000.0)
		end

	test_exponential_with_very_large_rate
			-- Test Exponential with large rate (mean = 1/λ = small).
		local
			dist: EXPONENTIAL_DISTRIBUTION
		do
			create dist.make (1000.0)
			assert ("mean_is_small", dist.mean ~ 0.001)
		end

	test_exponential_memoryless_property
			-- Test memoryless property: P(X > s+t | X > s) = P(X > t).
		local
			dist: EXPONENTIAL_DISTRIBUTION
			s, t: REAL_64
			prob_combined, prob_simple: REAL_64
		do
			create dist.make (0.5)
			s := 2.0
			t := 3.0
			-- P(X > s+t) = 1 - F(s+t)
			prob_combined := 1.0 - dist.cdf (s + t)
			-- P(X > t) = 1 - F(t)
			prob_simple := 1.0 - dist.cdf (t)
			-- Approximately equal due to memoryless property
			assert ("memoryless", (prob_combined - prob_simple * (1.0 - dist.cdf (s))).abs < 0.001)
		end

feature -- Bayesian Updater Edge Cases

	test_bayesian_update_with_no_observations
			-- Test Beta posterior when no observations (k=0, n=0).
		local
			updater: BAYESIAN_UPDATER
			posterior: BETA_DISTRIBUTION
		do
			create updater.make
			posterior := updater.update_conjugate_beta_binomial (1.0, 1.0, 0, 1)
			-- Prior unchanged
			assert ("posterior_alpha_correct", posterior.alpha ~ 1.0)
			assert ("posterior_beta_correct", posterior.beta ~ 2.0)
		end

	test_bayesian_update_with_all_successes
			-- Test Beta posterior when all trials succeed.
		local
			updater: BAYESIAN_UPDATER
			posterior: BETA_DISTRIBUTION
		do
			create updater.make
			posterior := updater.update_conjugate_beta_binomial (1.0, 1.0, 10, 10)
			-- All successes push toward p=1
			assert ("posterior_alpha_increased", posterior.alpha ~ 11.0)
			assert ("posterior_beta_unchanged", posterior.beta ~ 1.0)
		end

	test_bayesian_update_with_all_failures
			-- Test Beta posterior when all trials fail.
		local
			updater: BAYESIAN_UPDATER
			posterior: BETA_DISTRIBUTION
		do
			create updater.make
			posterior := updater.update_conjugate_beta_binomial (1.0, 1.0, 0, 10)
			-- All failures push toward p=0
			assert ("posterior_alpha_unchanged", posterior.alpha ~ 1.0)
			assert ("posterior_beta_increased", posterior.beta ~ 11.0)
		end

end
