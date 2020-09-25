<p align="center">
  <img src="/docs/src/assets/logo.png" height="150"><br/>
  <i>Infinite Hidden Markov Models for Julia.</i><br/><br/>
  <a href="https://github.com/SmartMonitoringSchemes/HDPHMM.jl/actions">
    <img src="https://github.com/SmartMonitoringSchemes/HDPHMM.jl/workflows/CI/badge.svg">
  </a>
  <a href="https://codecov.io/gh/SmartMonitoringSchemes/HDPHMM.jl">
    <img src="https://codecov.io/gh/SmartMonitoringSchemes/HDPHMM.jl/branch/master/graph/badge.svg?token=ufprqw9fEt">
  </a>
</p>

## Installation

The package can be installed with the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```
pkg> registry add git@github.com:SmartMonitoringSchemes/Registry.git
pkg> add HDPHMM
```

### Python bindings

To install the Python bindings (requires a working Julia installation):

```bash
pip install git+ssh://git@github.com/SmartMonitoringSchemes/HDPHMM.jl.git
python -c 'import hdphmm; hdphmm.install()'
```

## Documentation

For the Julia package, see [`test/`](/test/).  
For the Python bindings, see [`python/tests/test_hdphmm.py`](python/tests/test_hdphmm.py).

## Project Status

The package is tested against Julia 1.5  

## Questions and Contributions

Contributions are very welcome, as are feature requests and suggestions.
Please open an [issue][issues-url] if you encounter any problems.

*Logo: infinite by Knut M. Synstad from the Noun Project.*

[issues-url]: https://github.com/SmartMonitoringSchemes/HDPHMM.jl/issues
