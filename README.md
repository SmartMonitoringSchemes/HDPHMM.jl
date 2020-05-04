<p align="center">
  <img src="/docs/src/assets/logo.png" height="150"><br/>
  <i>Infinite Hidden Markov Models for Julia.</i><br/><br/>
  <a href="https://github.com/SmartMonitoringSchemes/HDPHMM.jl/actions">
    <img src="https://github.com/SmartMonitoringSchemes/HDPHMM.jl/workflows/CI/badge.svg">
  </a>
</p>

**TODO**
- [ ] Multivariate obs.
- [ ] pre-commit, formatter, linter, ...
- [ ] Test for type stability
- [ ] Dataset is from Shao ...
- [ ] Docs, CONTRIBUTING.md

## Installation

The package can be installed with the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```
pkg> registry add git@github.com:maxmouchet/JuliaRegistryPrivate.git
pkg> add HDPHMM
```

## Documentation

- [**STABLE**][docs-stable-url] &mdash; **documentation of the most recently tagged version.**
- [**DEVEL**][docs-dev-url] &mdash; *documentation of the in-development version.*

## Project Status

The package is tested against Julia 1.0 and Julia 1.2.  

Starting with v1.0, we follow [semantic versioning]():

> Given a version number MAJOR.MINOR.PATCH, increment the:
> 1. MAJOR version when you make incompatible API changes,
> 2. MINOR version when you add functionality in a backwards compatible manner, and
> 3. PATCH version when you make backwards compatible bug fixes.

## Questions and Contributions

Contributions are very welcome, as are feature requests and suggestions.
Please open an [issue][issues-url] if you encounter any problems.

*Logo: infinite by Knut M. Synstad from the Noun Project.*

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg?style=flat
[docs-stable-url]: https://maxmouchet.github.io/HDPHMM.jl/stable

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg?style=flat
[docs-dev-url]: https://maxmouchet.github.io/HDPHMM.jl/dev

[issues-url]: https://github.com/maxmouchet/HDPHMM.jl/issues
