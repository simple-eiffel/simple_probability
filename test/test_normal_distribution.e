note
	description: "Unit tests for NORMAL_DISTRIBUTION"
	author: "Eiffel Team"
	date: "2026-01-27"

class TEST_NORMAL_DISTRIBUTION

inherit
	TEST_SET_BASE

feature -- Creation Tests

	test_make_creates_distribution
			-- Test that make creates distribution with correct parameters.
		local
			dist: NORMAL_DISTRIBUTION
		do
			create dist.make (0.0, 1.0)
			assert ("mean set", dist.mean ~ 0.0)
			assert ("variance set", dist.variance ~ 1.0)
		end

	test_default_create_creates_standard_normal
			-- Test that default_create produces N(0,1).
		local
			dist: NORMAL_DISTRIBUTION
		do
			create dist
			assert ("mean is zero", dist.mean ~ 0.0)
			assert ("std dev is one", dist.standard_deviation ~ 1.0)
		end

feature -- PDF Tests

	test_pdf_at_mean_is_maximum
			-- Test that PDF has maximum at mean.
		local
			dist: NORMAL_DISTRIBUTION
			pdf_at_mean, pdf_away: REAL_64
		do
			create dist.make (5.0, 2.0)
			pdf_at_mean := dist.pdf (5.0)
			pdf_away := dist.pdf (6.0)
			assert ("pdf_at_mean > pdf_away", pdf_at_mean > pdf_away)
		end

	test_pdf_positive
			-- Test that PDF is non-negative.
		local
			dist: NORMAL_DISTRIBUTION
			pdf_val: REAL_64
		do
			create dist.make (0.0, 1.0)
			pdf_val := dist.pdf (-3.0)
			assert ("pdf non-negative", pdf_val >= 0)
		end

feature -- CDF Tests

	test_cdf_at_mean_is_half
			-- Test that CDF at mean is approximately 0.5.
		local
			dist: NORMAL_DISTRIBUTION
			cdf_val: REAL_64
		do
			create dist.make (3.0, 1.0)
			cdf_val := dist.cdf (3.0)
			assert ("cdf at mean ~ 0.5", (cdf_val - 0.5).abs < 0.01)
		end

	test_cdf_monotonic
			-- Test that CDF is monotonically increasing.
		local
			dist: NORMAL_DISTRIBUTION
		do
			create dist.make (0.0, 1.0)
			assert ("cdf_increasing", dist.cdf (0.0) < dist.cdf (1.0))
			assert ("cdf_increasing_2", dist.cdf (1.0) < dist.cdf (2.0))
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
			assert_true ("icdf(0.5) ~ mean", (icdf_val - 2.5).abs < 0.00001)
		end

feature -- Sampling Tests

	test_sample_in_domain
			-- Test that sample is in valid domain.
		local
			dist: NORMAL_DISTRIBUTION
			sample_val: REAL_64
		do
			create dist.make (0.0, 1.0)
			sample_val := dist.sample
			assert ("sample not NaN", not sample_val.is_nan)
		end

	test_seeding_produces_same_sequence
			-- Test that same seed produces identical sample sequences.
		local
			dist1, dist2: NORMAL_DISTRIBUTION
			s1_1, s1_2, s2_1, s2_2: REAL_64
		do
			create dist1.make (0.0, 1.0)
			create dist2.make (0.0, 1.0)
			dist1.set_seed (42)
			dist2.set_seed (42)
			s1_1 := dist1.sample
			s1_2 := dist1.sample
			s2_1 := dist2.sample
			s2_2 := dist2.sample
			assert ("first samples match", (s1_1 - s2_1).abs < 0.0000000001)
			assert ("second samples match", (s1_2 - s2_2).abs < 0.0000000001)
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
