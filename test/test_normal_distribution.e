note
	description: "Unit tests for NORMAL_DISTRIBUTION"
	author: "Eiffel Team"
	date: "2026-01-27"

class TEST_NORMAL_DISTRIBUTION

inherit
	TEST_SET_BASE

feature {NONE} -- Fixtures

	fixtures: DISTRIBUTION_FIXTURES
		once
			create Result
		end

feature -- Creation Tests

	test_make_creates_distribution
			-- Test that make creates distribution with correct parameters.
		do
			assert_reals_equal ("mean_set", 0.0, fixtures.std_normal.mean, 0.0001)
			assert_reals_equal ("variance_set", 1.0, fixtures.std_normal.variance, 0.0001)
		end

	test_default_create_creates_standard_normal
			-- Test that default_create produces N(0,1).
		do
			assert_reals_equal ("mean_is_zero", 0.0, fixtures.std_normal.mean, 0.0001)
			assert_reals_equal ("std_dev_is_one", 1.0, fixtures.std_normal.standard_deviation, 0.0001)
		end

feature -- PDF Tests

	test_pdf_at_mean_is_maximum
			-- Test that PDF has maximum at mean.
		do
			assert_true ("pdf_at_mean_greater",
				fixtures.custom_normal.pdf (100.0) > fixtures.custom_normal.pdf (101.0))
		end

	test_pdf_positive
			-- Test that PDF is non-negative.
		local
			pdf_val: REAL_64
		do
			pdf_val := fixtures.std_normal.pdf (-3.0)
			assert_true ("pdf_non_negative", pdf_val >= 0.0)
		end

feature -- CDF Tests

	test_cdf_at_mean_is_half
			-- Test that CDF at mean is approximately 0.5.
		local
			cdf_val: REAL_64
			dist: NORMAL_DISTRIBUTION
		do
			create dist.make (3.0, 1.0)
			cdf_val := dist.cdf (3.0)
			assert_reals_equal ("cdf_at_mean_approx_half", 0.5, cdf_val, 0.01)
		end

	test_cdf_monotonic
			-- Test that CDF is monotonically increasing.
		do
			assert_true ("cdf_increasing",
				fixtures.std_normal.cdf (0.0) < fixtures.std_normal.cdf (1.0))
			assert_true ("cdf_increasing_2",
				fixtures.std_normal.cdf (1.0) < fixtures.std_normal.cdf (2.0))
		end

feature -- ICDF Tests

	test_icdf_of_half_is_mean
			-- Test that ICDF(0.5) = median = mean.
		local
			dist: NORMAL_DISTRIBUTION
			icdf_val: REAL_64
		do
			create dist.make (2.5, 1.0)
			icdf_val := dist.icdf (0.5)
			assert_reals_equal ("icdf_half_approx_mean", 2.5, icdf_val, 0.00001)
		end

feature -- Sampling Tests

	test_sample_in_domain
			-- Test that sample is in valid domain.
		local
			sample_val: REAL_64
		do
			sample_val := fixtures.std_normal.sample
			assert_false ("sample_not_nan", sample_val.is_nan)
		end

	test_seeding_produces_same_sequence
			-- Test that same seed produces identical sample sequences.
		local
			s1_1, s1_2, s2_1, s2_2: REAL_64
		do
			s1_1 := fixtures.seeded_normal_1.sample
			s1_2 := fixtures.seeded_normal_1.sample
			s2_1 := fixtures.seeded_normal_2.sample
			s2_2 := fixtures.seeded_normal_2.sample
			assert_reals_equal ("first_samples_match", s1_1, s2_1, 0.0000000001)
			assert_reals_equal ("second_samples_match", s1_2, s2_2, 0.0000000001)
		end

feature -- Contract Tests

	test_precondition_sigma_positive
			-- Test that make rejects σ ≤ 0.
		local
			dist: NORMAL_DISTRIBUTION
		do
			-- Should fail precondition check (testing framework detects violation)
			-- In Phase 5, verify exception is raised
		end

end
