# Repository contents

| File or folder | Description |
| --- | --- |
| `output/` | Contains generated figures. |
| `c.common_model` | Defines the default AUTO continuation settings. |
| `common_model.f90` | Defines the ODE model and the AUTO starting point. |
| `experiment_1_productivity.ipynb` | Runs the variation in productivity simulation |
| `experiment_2_attack_rate.ipynb` | Runs the variation in attack-rate simulation. |
| `experiment_3_fitness_dependent_movement.ipynb` | Runs the sensitivity to fitness-dependent movement simulation |
| `plot_3x3.py` | Output figures graphics settings |
| `run_all_experiments.ipynb` | Runs the main experiments from a single notebook. |

> **Note:** AUTO may generate working files named `fort.*`, `b.*`, `s.*`, and
> `d.*`. These are intermediate outputs and should be automatically deleted
> once the script finishes running.

# Required Software

- [Docker Desktop](https://docs.docker.com/desktop/)
- [Git](https://git-scm.com/downloads/)

# Installation

Run the following complete block in Terminal (MAC OS): 

```
cd "$HOME"
open -a Docker

git clone --depth 1 https://github.com/rhparker/AUTOdocker.git
git clone https://github.com/Tristan-Kolla/fitness-movement.git

cp AUTOdocker/docker-compose-arm.yml fitness-movement/docker-compose.yml
printf 'services:\n  auto:\n    working_dir: /auto/workspace\n' \
  > fitness-movement/docker-compose.override.yml

cd fitness-movement

until docker info >/dev/null 2>&1; do sleep 2; done
docker compose up
```

These commands:

1. Start Docker Desktop.
2. Download AUTOdocker and the `fitness-movement` repository.
3. Configure the Apple Silicon container to use the repository as its Jupyter workspace.
4. Wait for Docker to become available.
5. Start the AUTO-07p container and display the Jupyter access URL.


# Running the experiments

The scripts are launched from Jupyter notebooks inside an AUTO-Docker container.

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
| 12 | `dF` | 0.50 | Forager movement rate |
| 13 | `dJ` | 0.50 | Juvenile movement rate |
| 14 | `mu` | 0.00 | Fishing effort; principal continuation parameter |
| 15 | `deltar` | 0.00 | Productivity contrast between habitats |
| 16 | `deltas` | 0.00 | Attack-rate contrast between habitats |
| 17 | `beta` | 0.25 | Sensitivity of movement to the fitness difference |
| 18 | `toggle` | 1.00 | Movement switch: 1 = on and 0 = off |
| 19 | `dP` | 0.50 | Predator movement rate |

> **Notes:**
>
> - The defaults are assigned in `STPNT` in `common_model.f90`.
> - Parameter numbers are the indices used by AUTO (`PAR`).

## Habitat-specific values

| Expression | Meaning |
| --- | --- |
| `rL = r(1 - deltar)` | Littoral growth rate |
| `rP = r(1 + deltar)` | Pelagic growth rate |
| `aL = a(1 - deltas)` | Littoral attack rate |
| `aP = a(1 + deltas)` | Pelagic attack rate |

## Important AUTO continuation settings

| Setting | Shared value | Purpose |
| --- | --- | --- |
| `ICP` | 14 | Initially continue fishing effort, `mu` |
| `DS` | `5e-4` | Initial pseudo-arclength step size |
| `DSMIN` / `DSMAX` | `1e-4` / `5e-2` | Minimum and maximum step sizes |
| `NMX` | 1000 | Maximum continuation steps |
| `EPSL` / `EPSU` / `EPSS` | `1e-8` / `1e-8` / `1e-6` | Convergence tolerances |

The shared defaults are defined in `c.common_model`.

## Experiment settings

| Experiment | Driver (PAR) | Range | Fixed contrasts |
| --- | --- | --- | --- |
| 1. Productivity | `deltar` (15) | 0 to 1 | `deltas = 0` |
| 2. Attack rate | `deltas` (16) | 0 to 1 | `deltar = 0` |
| 3. Fitness-based movement | `beta` (17) | 0 to 20 | `deltar = 0.2`; `deltas = 0.02` |

Unless specified in the **Fixed contrasts** column, all variables are fixed.

## MIT License (MIT)

Copyright © 2026 Tristan Kolla

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# References

- [AUTO-07p Manual](https://tinyurl.com/45449y9r)
