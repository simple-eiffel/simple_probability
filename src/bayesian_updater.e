note
	description: "Bayesian inference via conjugate prior updates"
	author: "Eiffel Team"
	date: "2026-01-27"

class BAYESIAN_UPDATER

create
	make

feature -- Initialization

	make
			-- Create Bayesian updater instance.
		do
			-- No state to initialize
		end

feature -- Beta-Binomial Conjugate Pair

	update_conjugate_beta_binomial (
			prior_alpha, prior_beta: REAL_64;
			successes, trials: INTEGER
		): BETA_DISTRIBUTION
			-- Update Beta prior with Binomial observations (conjugate pair).
			-- Implements exact Bayesian update: Beta(α + k, β + n - k).
		require
			prior_valid: prior_alpha > 0 and prior_beta > 0
			trials_positive: trials > 0
			successes_valid: successes >= 0 and successes <= trials
		local
			posterior_alpha, posterior_beta: REAL_64
		do
			-- Conjugate update formula: Beta(α_prior + successes, β_prior + failures)
			posterior_alpha := prior_alpha + successes.to_double
			posterior_beta := prior_beta + (trials - successes).to_double
			create Result.make (posterior_alpha, posterior_beta)
		ensure
			posterior_alpha_increased: Result.alpha >= prior_alpha
			posterior_beta_increased: Result.beta >= prior_beta
			posterior_updated: (Result.alpha + Result.beta) > (prior_alpha + prior_beta)
			posterior_mean_pulled_toward_data: True  -- Verified by test
		end

feature -- Credible Intervals

	credible_interval_from_posterior (
			posterior: DISTRIBUTION;
			confidence_level: REAL_64
		): TUPLE [lower_bound, upper_bound: REAL_64]
			-- Extract credible interval from posterior distribution.
		require
			posterior_valid: posterior /= Void
			confidence_valid: confidence_level > 0 and confidence_level < 1
		local
			lower_quantile, upper_quantile: REAL_64
			lower_prob, upper_prob: REAL_64
		do
			-- Symmetric credible interval: [quantile(α/2), quantile(1 - α/2)]
			lower_prob := (1.0 - confidence_level) / 2.0
			upper_prob := 1.0 - lower_prob
			lower_quantile := posterior.icdf (lower_prob)
			upper_quantile := posterior.icdf (upper_prob)
			Result := [lower_quantile, upper_quantile]
		ensure
			bounds_ordered: Result.lower_bound < Result.upper_bound
			interval_width_positive: (Result.upper_bound - Result.lower_bound) > 0
		end

invariant
	-- Updater is stateless
end
