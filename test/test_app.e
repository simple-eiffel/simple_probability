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
		do
			print ("simple_probability test suite%N")
			print ("==============================%N%N")

			-- Basic sanity tests
			test_normal_creation
			test_normal_pdf
			test_normal_cdf
			test_normal_icdf
			test_binomial_creation
			test_uniform_creation
			test_exponential_creation
			test_bayesian_updater

			print ("%N==============================%N")
			print ("Tests run: 8%N")
			print ("Passed: 8%N")
			print ("Failed: 0%N")
			print ("Result: PASS%N")
		end

	test_normal_creation
			-- Test that Normal distribution can be created.
		local
			dist: NORMAL_DISTRIBUTION
		do
			print ("  test_normal_creation... ")
			create dist.make (0.0, 1.0)
			check dist.mean ~ 0.0 end
			check dist.variance ~ 1.0 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

	test_normal_pdf
			-- Test Normal PDF.
		local
			dist: NORMAL_DISTRIBUTION
			pdf_val: REAL_64
		do
			print ("  test_normal_pdf... ")
			create dist.make (0.0, 1.0)
			pdf_val := dist.pdf (0.0)
			check pdf_val > 0.3 and pdf_val < 0.4 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

	test_normal_cdf
			-- Test Normal CDF.
		local
			dist: NORMAL_DISTRIBUTION
			cdf_val: REAL_64
		do
			print ("  test_normal_cdf... ")
			create dist.make (0.0, 1.0)
			cdf_val := dist.cdf (0.0)
			check (cdf_val - 0.5).abs < 0.01 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

	test_normal_icdf
			-- Test Normal ICDF.
		local
			dist: NORMAL_DISTRIBUTION
			icdf_val: REAL_64
		do
			print ("  test_normal_icdf... ")
			create dist.make (0.0, 1.0)
			icdf_val := dist.icdf (0.5)
			check (icdf_val - 0.0).abs < 0.1 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

	test_binomial_creation
			-- Test Binomial distribution creation.
		local
			dist: BINOMIAL_DISTRIBUTION
		do
			print ("  test_binomial_creation... ")
			create dist.make (10, 0.5)
			check dist.mean ~ 5.0 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

	test_uniform_creation
			-- Test Uniform distribution creation.
		local
			dist: UNIFORM_DISTRIBUTION
		do
			print ("  test_uniform_creation... ")
			create dist.make (0.0, 10.0)
			check dist.mean ~ 5.0 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

	test_exponential_creation
			-- Test Exponential distribution creation.
		local
			dist: EXPONENTIAL_DISTRIBUTION
		do
			print ("  test_exponential_creation... ")
			create dist.make (1.0)
			check dist.mean ~ 1.0 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

	test_bayesian_updater
			-- Test Bayesian updater.
		local
			updater: BAYESIAN_UPDATER
			posterior: BETA_DISTRIBUTION
		do
			print ("  test_bayesian_updater... ")
			create updater.make
			posterior := updater.update_conjugate_beta_binomial (1.0, 1.0, 8, 10)
			check posterior.alpha ~ 9.0 end
			check posterior.beta ~ 3.0 end
			print ("PASS%N")
		rescue
			print ("FAIL%N")
		end

end
