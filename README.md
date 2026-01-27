<p align="center">
  <svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <circle cx="100" cy="100" r="95" fill="#667eea" stroke="#fff" stroke-width="2"/>
    <text x="100" y="120" font-size="50" font-weight="bold" text-anchor="middle" fill="#fff">Prob</text>
  </svg>
</p>

<h1 align="center">simple_probability</h1>

<p align="center">
  <a href="https://simple-eiffel.github.io/simple_probability/">Documentation</a> •
  <a href="https://github.com/simple-eiffel/simple_probability">GitHub</a> •
  <a href="https://github.com/simple-eiffel/simple_probability/issues">Issues</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Eiffel-25.02-purple.svg" alt="Eiffel 25.02">
  <img src="https://img.shields.io/badge/DBC-Contracts-green.svg" alt="Design by Contract">
</p>

Type-safe probability distributions and Bayesian inference for Eiffel.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- Multiple distributions (Normal, Uniform, Exponential, Beta, Binomial)
- Bayesian conjugate priors and credible intervals
- Design by Contract throughout

## Quick Start

```eiffel
local
    l_dist: NORMAL_DISTRIBUTION
do
    create l_dist.make (100.0, 15.0)  -- mean, std_dev
    print (l_dist.pdf (95.0))         -- Probability density
    print (l_dist.sample)             -- Random sample
end
```

For complete documentation, see [our docs site](https://simple-eiffel.github.io/simple_probability/).

## Features

- **Continuous:** Normal (Gaussian), Uniform, Exponential, Beta
- **Discrete:** Binomial
- **All distributions:** PDF/PMF, CDF, ICDF (inverse CDF), sampling
- **Bayesian inference:** Conjugate priors, credible intervals, posterior estimation
- **Design by Contract:** Full DBC throughout
- **Type-safe:** Void-safe implementation

For details, see the [User Guide](https://simple-eiffel.github.io/simple_probability/user-guide.html).

## Installation

```bash
# Add to your ECF:
<library name="simple_probability" location="$SIMPLE_EIFFEL/simple_probability/simple_probability.ecf"/>
```

## License

MIT License - See LICENSE file

## Support

- **Docs:** https://simple-eiffel.github.io/simple_probability/
- **GitHub:** https://github.com/simple-eiffel/simple_probability
- **Issues:** https://github.com/simple-eiffel/simple_probability/issues
