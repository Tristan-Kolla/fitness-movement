# Repository contents

| File or folder | Description |
| --- | --- |
| `output/` | Contains generated figures. |
| `c.common_model` | Defines the default AUTO continuation settings. |
| `common_model.f90` | Defines the ODE model and the AUTO starting point. |
| `run_all_experiments.ipynb` | Runs the main experiments from a single notebook. |

> **Note:** AUTO may generate working files named `fort.*`, `b.*`, `s.*`, and `d.*`. 

# Required Software

- [Docker Desktop](https://docs.docker.com/desktop/)
- [Git](https://git-scm.com/downloads/)

# Running the experiments

The experiments are launched from a Jupyter notebook inside an AUTO-Docker container.

1. Open `run_all_experiments.ipynb`.
2. Confirm that the notebook working directory is the repository root.
3. Select **Run All Cells**.
4. Review the generated files in the `output/` directory.

# Important simulation variables, parameters, and settings

## Model parameters

| PAR | Name | Default | Meaning |
| ---: | --- | ---: | --- |
| 1 | `r` | 0.40 | Baseline intrinsic growth rate of foragers |
| 2 | `a` | 0.05 | Baseline predator attack-rate coefficient |
| 3 | `m` | 0.10 | Mortality rate |
| 4 | `b` | 0.06 | Forager density-dependence coefficient |
| 5 | `s` | 0.005 | Predation saturation coefficient |
| 6 | `e` | 0.10 | Forager conversion efficiency |
| 7 | `fec` | 1.00 | Predator fecundity |
| 8 | `g` | 0.30 | Maximum juvenile maturation rate |
| 9 | `q` | 0.15 | Juvenile-forager interaction rate |
| 10 | `c` | 0.02 | Juvenile-predator interaction rate |
| 11 | — | — | Reserved for AUTO |
| 12 | `dF` | 10.00 | Forager movement rate |
| 13 | `dJ` | 10.00 | Juvenile movement rate |
| 14 | `mu` | 0.00 | Fishing effort; principal continuation parameter |
| 15 | `deltar` | 0.00 | Productivity contrast between habitats |
| 16 | `deltas` | 0.00 | Consumption contrast between habitats (scales `a`, `q`, and `c`) |
| 17 | `beta` | 0.25 | Sensitivity of movement to the fitness difference |
| 18 | `toggle` | 1.00 | Movement switch: 1 = on and 0 = off |
| 19 | `dP` | 10.00 | Predator movement rate |

> **Notes:**
>
> - The defaults are assigned in `STPNT` in `common_model.f90`.
> - Parameter numbers are the indices used by AUTO (`PAR`).


## Important AUTO continuation settings

| Setting | Default value | Purpose |
| --- | --- | --- |
| `ICP` | 14 | Initially continue fishing effort, `mu` |
| `DS` | `5e-4` | Initial pseudo-arclength step size |
| `DSMIN` / `DSMAX` | `1e-4` / `5e-2` | Minimum and maximum step sizes |
| `NMX` | 1000 | Maximum continuation steps |
| `EPSL` / `EPSU` / `EPSS` | `1e-8` / `1e-8` / `1e-6` | Convergence tolerances |

The defaults are defined in `c.common_model` and overridden where specified in `run_all_experiments.ipynb`.

## Experiment settings

| Experiment | Driver (PAR) | Range | Fixed settings |
| --- | --- | --- | --- |
| 1. Productivity | `deltar` (15) | 0 to 1 | `deltas = 0`; `beta = 0` and `beta = 5` in separate runs |
| 2. Interaction strength | `deltas` (16) | 0 to 1 | `deltar = 0`; `beta = 0` and `beta = 5` in separate runs |
| 3. Fitness-based movement | `beta` (17) | 0 to 5 | `deltar = 0.4`; `deltas = 0.4` |

Fishing effort, `mu`, varies along the recovery and collapse curves with the driver; all other model parameters remain fixed at their defaults or the settings shown above.

## MIT License (MIT)

Copyright © 2026 Tristan Kolla

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# References

- [AUTO-07p Manual](https://tinyurl.com/45449y9r)