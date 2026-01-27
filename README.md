# simple_probability

[Documentation](https://simple-eiffel.github.io/simple_probability/) • [GitHub](https://github.com/simple-eiffel/simple_probability) • [Issues](https://github.com/simple-eiffel/simple_probability/issues)

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Eiffel 25.02](https://img.shields.io/badge/Eiffel-25.02-purple.svg)
![DBC: Contracts](https://img.shields.io/badge/DBC-Contracts-green.svg)

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
