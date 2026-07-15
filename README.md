# Diagnostics

Simulation diagnostics for habitat movement and food web experiments.

## Contents

- `movement_tests.py` runs movement-only simulation experiments and generates summary plots.
- `common_model.f90` contains the shared Fortran model implementation.
- `experiment_*.ipynb` notebooks explore productivity, attack-rate, and fitness-dependent movement scenarios.
- `output_experiment_*/` folders contain generated figure outputs used for inspection and reporting.

## Setup

Install the Python dependencies in your preferred environment:

```sh
python3 -m pip install numpy matplotlib scipy
```

## Running

Run the main diagnostics script from the project root:

```sh
python3 movement_tests.py
```

