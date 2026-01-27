note
	description: "Test application entry point"
	author: "Eiffel Team"
	date: "2026-01-27"

class TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run test suite and report results.
		local
			tests: TEST_NORMAL_DISTRIBUTION
			adversarial_tests: TEST_DISTRIBUTION_ADVERSARIAL
			passed, failed: INTEGER
		do
			create tests
			create adversarial_tests

			print ("simple_probability test suite%N")
			print ("==============================%N%N")

			passed := 0
			failed := 0

			-- Test creation
			if run_test (agent tests.test_make_creates_distribution, "test_make_creates_distribution") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent tests.test_default_create_creates_standard_normal, "test_default_create_creates_standard_normal") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Test PDF
			if run_test (agent tests.test_pdf_at_mean_is_maximum, "test_pdf_at_mean_is_maximum") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent tests.test_pdf_positive, "test_pdf_positive") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Test CDF
			if run_test (agent tests.test_cdf_at_mean_is_half, "test_cdf_at_mean_is_half") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent tests.test_cdf_monotonic, "test_cdf_monotonic") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Test ICDF
			if run_test (agent tests.test_icdf_of_half_is_mean, "test_icdf_of_half_is_mean") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Test sampling
			if run_test (agent tests.test_sample_in_domain, "test_sample_in_domain") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent tests.test_seeding_produces_same_sequence, "test_seeding_produces_same_sequence") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			print ("%N-- ADVERSARIAL TESTS --%N%N")

			-- Normal boundary value tests
			if run_test (agent adversarial_tests.test_normal_with_very_small_sigma, "test_normal_with_very_small_sigma") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_normal_with_very_large_sigma, "test_normal_with_very_large_sigma") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_normal_with_negative_mean, "test_normal_with_negative_mean") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_normal_with_extreme_positive_mean, "test_normal_with_extreme_positive_mean") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_cdf_at_extreme_negative_x, "test_cdf_at_extreme_negative_x") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_cdf_at_extreme_positive_x, "test_cdf_at_extreme_positive_x") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_icdf_at_extreme_low_probability, "test_icdf_at_extreme_low_probability") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_icdf_at_extreme_high_probability, "test_icdf_at_extreme_high_probability") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Monotonicity tests
			if run_test (agent adversarial_tests.test_cdf_strictly_monotonic_over_range, "test_cdf_strictly_monotonic_over_range") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_pdf_symmetric_around_mean, "test_pdf_symmetric_around_mean") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_pdf_unimodal_around_mean, "test_pdf_unimodal_around_mean") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Inverse function tests
			if run_test (agent adversarial_tests.test_icdf_cdf_roundtrip, "test_icdf_cdf_roundtrip") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_icdf_monotonic_in_probability, "test_icdf_monotonic_in_probability") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Sampling tests
			if run_test (agent adversarial_tests.test_sample_multiple_times_within_domain, "test_sample_multiple_times_within_domain") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_sample_approximately_follows_distribution, "test_sample_approximately_follows_distribution") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Variance tests
			if run_test (agent adversarial_tests.test_variance_properties, "test_variance_properties") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_standard_deviation_is_sqrt_variance, "test_standard_deviation_is_sqrt_variance") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Multiple instances
			if run_test (agent adversarial_tests.test_multiple_independent_distributions, "test_multiple_independent_distributions") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Binomial tests
			if run_test (agent adversarial_tests.test_binomial_with_n_equals_1, "test_binomial_with_n_equals_1") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_binomial_with_p_equals_0, "test_binomial_with_p_equals_0") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_binomial_with_p_equals_1, "test_binomial_with_p_equals_1") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_binomial_pmf_sums_to_one, "test_binomial_pmf_sums_to_one") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Uniform tests
			if run_test (agent adversarial_tests.test_uniform_with_very_small_width, "test_uniform_with_very_small_width") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_uniform_with_wide_bounds, "test_uniform_with_wide_bounds") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_uniform_cdf_is_linear, "test_uniform_cdf_is_linear") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Exponential tests
			if run_test (agent adversarial_tests.test_exponential_with_very_small_rate, "test_exponential_with_very_small_rate") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_exponential_with_very_large_rate, "test_exponential_with_very_large_rate") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_exponential_memoryless_property, "test_exponential_memoryless_property") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Bayesian updater tests
			if run_test (agent adversarial_tests.test_bayesian_update_with_no_observations, "test_bayesian_update_with_no_observations") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_bayesian_update_with_all_successes, "test_bayesian_update_with_all_successes") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			if run_test (agent adversarial_tests.test_bayesian_update_with_all_failures, "test_bayesian_update_with_all_failures") then
				passed := passed + 1
			else
				failed := failed + 1
			end

			-- Summary
			print ("%N==============================%N")
			print ("Tests run: " + (passed + failed).out + "%N")
			print ("Passed: " + passed.out + "%N")
			print ("Failed: " + failed.out + "%N")
			if failed = 0 then
				print ("Result: PASS%N")
			else
				print ("Result: FAIL%N")
			end
		end

	run_test (a_test: PROCEDURE; a_name: STRING): BOOLEAN
			-- Run a single test and report result. Return True if passed.
		do
			print ("  " + a_name + "... ")
			Result := True
			a_test.call (Void)
			print ("PASS%N")
		rescue
			Result := False
			print ("FAIL%N")
		end

end
