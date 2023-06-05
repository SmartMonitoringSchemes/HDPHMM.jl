<p align="center">
  <img src="/.github/logo.png" height="150"><br/>
  <i>Infinite Hidden Markov Models for Julia.</i><br/><br/>
  <a href="https://app.codecov.io/gh/SmartMonitoringSchemes/HDPHMM.jl">
    <img src="https://img.shields.io/codecov/c/github/SmartMonitoringSchemes/HDPHMM.jl?logo=codecov&logoColor=white">
  </a>
  <a href="https://github.com/SmartMonitoringSchemes/HDPHMM.jl/actions/workflows/tests.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/SmartMonitoringSchemes/HDPHMM.jl/tests.yml?logo=github&label=tests">
  </a>
</p>

## Installation

The package can be installed with the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```
pkg> registry add https://github.com/SmartMonitoringSchemes/Registry
pkg> add HDPHMM
```

### Python bindings

To install the Python bindings (requires a working Julia installation):

```bash
pip install git+https://github.com/SmartMonitoringSchemes/HDPHMM.jl.git
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
