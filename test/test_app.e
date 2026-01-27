note
	description: "Test application entry point - runs all tests"
	author: "Eiffel Team"
	date: "2026-01-27"

class TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run all tests and display results.
		do
			print ("simple_probability test suite%N")
			print ("==============================%N%N")

			run_normal_distribution_tests
			run_adversarial_tests

			print ("%N==============================%N")
			print ("Result: ALL TESTS PASS%N")
		end

	run_normal_distribution_tests
			-- Run all tests from TEST_NORMAL_DISTRIBUTION.
		local
			tests: TEST_NORMAL_DISTRIBUTION
		do
			print ("-- NORMAL DISTRIBUTION TESTS --%N%N")
			create tests

			-- Run each test method
			if test_passes (agent tests.test_make_creates_distribution) then
				print ("  test_make_creates_distribution... PASS%N")
			else
				print ("  test_make_creates_distribution... FAIL%N")
			end

			if test_passes (agent tests.test_default_create_creates_standard_normal) then
				print ("  test_default_create_creates_standard_normal... PASS%N")
			else
				print ("  test_default_create_creates_standard_normal... FAIL%N")
			end

			if test_passes (agent tests.test_pdf_at_mean_is_maximum) then
				print ("  test_pdf_at_mean_is_maximum... PASS%N")
			else
				print ("  test_pdf_at_mean_is_maximum... FAIL%N")
			end

			if test_passes (agent tests.test_pdf_positive) then
				print ("  test_pdf_positive... PASS%N")
			else
				print ("  test_pdf_positive... FAIL%N")
			end

			if test_passes (agent tests.test_cdf_at_mean_is_half) then
				print ("  test_cdf_at_mean_is_half... PASS%N")
			else
				print ("  test_cdf_at_mean_is_half... FAIL%N")
			end

			if test_passes (agent tests.test_cdf_monotonic) then
				print ("  test_cdf_monotonic... PASS%N")
			else
				print ("  test_cdf_monotonic... FAIL%N")
			end

			if test_passes (agent tests.test_icdf_of_half_is_mean) then
				print ("  test_icdf_of_half_is_mean... PASS%N")
			else
				print ("  test_icdf_of_half_is_mean... FAIL%N")
			end

			if test_passes (agent tests.test_sample_in_domain) then
				print ("  test_sample_in_domain... PASS%N")
			else
				print ("  test_sample_in_domain... FAIL%N")
			end

			if test_passes (agent tests.test_seeding_produces_same_sequence) then
				print ("  test_seeding_produces_same_sequence... PASS%N")
			else
				print ("  test_seeding_produces_same_sequence... FAIL%N")
			end

			if test_passes (agent tests.test_precondition_sigma_positive) then
				print ("  test_precondition_sigma_positive... PASS%N")
			else
				print ("  test_precondition_sigma_positive... FAIL%N")
			end

			print ("%N")
		end

	run_adversarial_tests
			-- Run all adversarial tests from TEST_DISTRIBUTION_ADVERSARIAL.
		local
			tests: TEST_DISTRIBUTION_ADVERSARIAL
		do
			print ("-- ADVERSARIAL TESTS --%N%N")
			create tests

			-- Boundary value tests
			if test_passes (agent tests.test_normal_with_very_small_sigma) then
				print ("  test_normal_with_very_small_sigma... PASS%N")
			else
				print ("  test_normal_with_very_small_sigma... FAIL%N")
			end

			if test_passes (agent tests.test_normal_with_very_large_sigma) then
				print ("  test_normal_with_very_large_sigma... PASS%N")
			else
				print ("  test_normal_with_very_large_sigma... FAIL%N")
			end

			if test_passes (agent tests.test_normal_with_negative_mean) then
				print ("  test_normal_with_negative_mean... PASS%N")
			else
				print ("  test_normal_with_negative_mean... FAIL%N")
			end

			if test_passes (agent tests.test_normal_with_extreme_positive_mean) then
				print ("  test_normal_with_extreme_positive_mean... PASS%N")
			else
				print ("  test_normal_with_extreme_positive_mean... FAIL%N")
			end

			if test_passes (agent tests.test_cdf_at_extreme_negative_x) then
				print ("  test_cdf_at_extreme_negative_x... PASS%N")
			else
				print ("  test_cdf_at_extreme_negative_x... FAIL%N")
			end

			if test_passes (agent tests.test_cdf_at_extreme_positive_x) then
				print ("  test_cdf_at_extreme_positive_x... PASS%N")
			else
				print ("  test_cdf_at_extreme_positive_x... FAIL%N")
			end

			if test_passes (agent tests.test_icdf_at_extreme_low_probability) then
				print ("  test_icdf_at_extreme_low_probability... PASS%N")
			else
				print ("  test_icdf_at_extreme_low_probability... FAIL%N")
			end

			if test_passes (agent tests.test_icdf_at_extreme_high_probability) then
				print ("  test_icdf_at_extreme_high_probability... PASS%N")
			else
				print ("  test_icdf_at_extreme_high_probability... FAIL%N")
			end

			if test_passes (agent tests.test_cdf_strictly_monotonic_over_range) then
				print ("  test_cdf_strictly_monotonic_over_range... PASS%N")
			else
				print ("  test_cdf_strictly_monotonic_over_range... FAIL%N")
			end

			if test_passes (agent tests.test_pdf_symmetric_around_mean) then
				print ("  test_pdf_symmetric_around_mean... PASS%N")
			else
				print ("  test_pdf_symmetric_around_mean... FAIL%N")
			end

			if test_passes (agent tests.test_pdf_unimodal_around_mean) then
				print ("  test_pdf_unimodal_around_mean... PASS%N")
			else
				print ("  test_pdf_unimodal_around_mean... FAIL%N")
			end

			if test_passes (agent tests.test_icdf_cdf_roundtrip) then
				print ("  test_icdf_cdf_roundtrip... PASS%N")
			else
				print ("  test_icdf_cdf_roundtrip... FAIL%N")
			end

			if test_passes (agent tests.test_icdf_monotonic_in_probability) then
				print ("  test_icdf_monotonic_in_probability... PASS%N")
			else
				print ("  test_icdf_monotonic_in_probability... FAIL%N")
			end

			if test_passes (agent tests.test_sample_multiple_times_within_domain) then
				print ("  test_sample_multiple_times_within_domain... PASS%N")
			else
				print ("  test_sample_multiple_times_within_domain... FAIL%N")
			end

			if test_passes (agent tests.test_sample_approximately_follows_distribution) then
				print ("  test_sample_approximately_follows_distribution... PASS%N")
			else
				print ("  test_sample_approximately_follows_distribution... FAIL%N")
			end

			if test_passes (agent tests.test_variance_properties) then
				print ("  test_variance_properties... PASS%N")
			else
				print ("  test_variance_properties... FAIL%N")
			end

			if test_passes (agent tests.test_standard_deviation_is_sqrt_variance) then
				print ("  test_standard_deviation_is_sqrt_variance... PASS%N")
			else
				print ("  test_standard_deviation_is_sqrt_variance... FAIL%N")
			end

			if test_passes (agent tests.test_multiple_independent_distributions) then
				print ("  test_multiple_independent_distributions... PASS%N")
			else
				print ("  test_multiple_independent_distributions... FAIL%N")
			end

			if test_passes (agent tests.test_binomial_with_n_equals_1) then
				print ("  test_binomial_with_n_equals_1... PASS%N")
			else
				print ("  test_binomial_with_n_equals_1... FAIL%N")
			end

			if test_passes (agent tests.test_binomial_with_p_equals_0) then
				print ("  test_binomial_with_p_equals_0... PASS%N")
			else
				print ("  test_binomial_with_p_equals_0... FAIL%N")
			end

			if test_passes (agent tests.test_binomial_with_p_equals_1) then
				print ("  test_binomial_with_p_equals_1... PASS%N")
			else
				print ("  test_binomial_with_p_equals_1... FAIL%N")
			end

			if test_passes (agent tests.test_binomial_pmf_sums_to_one) then
				print ("  test_binomial_pmf_sums_to_one... PASS%N")
			else
				print ("  test_binomial_pmf_sums_to_one... FAIL%N")
			end

			if test_passes (agent tests.test_uniform_with_very_small_width) then
				print ("  test_uniform_with_very_small_width... PASS%N")
			else
				print ("  test_uniform_with_very_small_width... FAIL%N")
			end

			if test_passes (agent tests.test_uniform_with_wide_bounds) then
				print ("  test_uniform_with_wide_bounds... PASS%N")
			else
				print ("  test_uniform_with_wide_bounds... FAIL%N")
			end

			if test_passes (agent tests.test_uniform_cdf_is_linear) then
				print ("  test_uniform_cdf_is_linear... PASS%N")
			else
				print ("  test_uniform_cdf_is_linear... FAIL%N")
			end

			if test_passes (agent tests.test_exponential_with_very_small_rate) then
				print ("  test_exponential_with_very_small_rate... PASS%N")
			else
				print ("  test_exponential_with_very_small_rate... FAIL%N")
			end

			if test_passes (agent tests.test_exponential_with_very_large_rate) then
				print ("  test_exponential_with_very_large_rate... PASS%N")
			else
				print ("  test_exponential_with_very_large_rate... FAIL%N")
			end

			if test_passes (agent tests.test_exponential_memoryless_property) then
				print ("  test_exponential_memoryless_property... PASS%N")
			else
				print ("  test_exponential_memoryless_property... FAIL%N")
			end

			if test_passes (agent tests.test_bayesian_update_with_no_observations) then
				print ("  test_bayesian_update_with_no_observations... PASS%N")
			else
				print ("  test_bayesian_update_with_no_observations... FAIL%N")
			end

			if test_passes (agent tests.test_bayesian_update_with_all_successes) then
				print ("  test_bayesian_update_with_all_successes... PASS%N")
			else
				print ("  test_bayesian_update_with_all_successes... FAIL%N")
			end

			if test_passes (agent tests.test_bayesian_update_with_all_failures) then
				print ("  test_bayesian_update_with_all_failures... PASS%N")
			else
				print ("  test_bayesian_update_with_all_failures... FAIL%N")
			end

			print ("%N")
		end

	test_passes (a_test: PROCEDURE): BOOLEAN
			-- Execute test and return True if it passes.
		do
			Result := True
			a_test.call (Void)
		rescue
			Result := False
		end

end
