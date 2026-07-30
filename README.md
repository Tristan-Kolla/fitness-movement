# Fitness-Dependent Movement

## Table of contents

1. [Project overview](#project-overview)
2. [Repository contents](#repository-contents)
3. [Installation](#installation)
4. [Running the experiments](#running-the-experiments)
5. [Important simulation variables, parameters, and settings](#important-simulation-variables-parameters-and-settings)
6. [License](#license)
7. [References](#references)

## Project overview

This repository contains a two-patch tri-trophic model analyzed with AUTO-07p.
The model describes predators, foragers, and juveniles in littoral and pelagic
habitats.

The scripts are launched from Jupyter notebooks inside an AUTO-Docker container.

## Repository contents

| File or folder | Description |
| --- | --- |
| `common_model.f90` | Defines the six-dimensional ODE model and the AUTO starting point. |
| `c.common_model` | Defines the default AUTO continuation settings. |
| `plot_3x3.py` | Applies the shared formatting for the three 3-by-3 codimension-2 plots. |
| `experiment_1_productivity.ipynb` | Runs the productivity analysis. |
| `experiment_2_attack_rate.ipynb` | Runs the attack-rate analysis. |
| `experiment_3_fitness_dependent_movement.ipynb` | Runs the fitness-dependent movement analysis. |
| `run_all_experiments.ipynb` | Runs the main experiments from a single notebook. |
| `movement_tests.py` | Tests movement and fitness calculations independently of AUTO. |
| `Extra_Experiments/` | Contains supplementary analyses. |
| `output/` | Contains generated figures and analysis outputs. |

> **Note:** AUTO may generate working files named `fort.*`, `b.*`, `s.*`, and
> `d.*`. These are intermediate outputs and should be automatically deleted
> once the script finishes running.

## Installation

### Prerequisites

- [Docker Desktop](https://docs.docker.com/desktop/)
- [Git](https://git-scm.com/downloads/)

No separate installation of Python, Jupyter, or AUTO-07p is required.
AUTOdocker provides these dependencies inside a Docker container.

### Apple Silicon macOS

The following commands perform a clean installation on a Mac with an Apple
Silicon processor (M1 or newer). Run the complete block in Terminal:

```bash
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

The first launch may take several minutes while Docker downloads the AUTOdocker
image. When Jupyter is ready, Terminal displays a URL similar to:

```text
http://127.0.0.1:8888/tree?token=...
```

Open this URL in a browser. Jupyter starts in the `fitness-movement` repository,
which is mounted inside the container as `/auto/workspace`.

Keep the Terminal window open while using Jupyter. Press <kbd>Control</kbd> +
<kbd>C</kbd> to stop the container.

### Subsequent launches

After the initial installation, start the environment with:

```bash
cd "$HOME/fitness-movement"
open -a Docker
until docker info >/dev/null 2>&1; do sleep 2; done
docker compose up
```

Files created in the repository, including files written to `output/`, remain
available after the container stops.

## Running the experiments

1. Open `run_all_experiments.ipynb`.
2. Confirm that the notebook working directory is the repository root.
3. Select **Run All Cells**.
4. Review the generated files in the `output/` directory.

Alternatively, you can run each experiment individually by selecting
**Run All Cells** in its respective Jupyter notebook.

## Important simulation variables, parameters, and settings

### Model parameters

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

### Habitat-specific values

| Expression | Meaning |
| --- | --- |
| `rL = r(1 - deltar)` | Littoral growth rate |
| `rP = r(1 + deltar)` | Pelagic growth rate |
| `aL = a(1 - deltas)` | Littoral attack rate |
| `aP = a(1 + deltas)` | Pelagic attack rate |

### Important AUTO continuation settings

| Setting | Shared value | Purpose |
| --- | --- | --- |
| `ICP` | 14 | Initially continue fishing effort, `mu` |
| `DS` | `5e-4` | Initial pseudo-arclength step size |
| `DSMIN` / `DSMAX` | `1e-4` / `5e-2` | Minimum and maximum step sizes |
| `NMX` | 1000 | Maximum continuation steps |
| `EPSL` / `EPSU` / `EPSS` | `1e-8` / `1e-8` / `1e-6` | Convergence tolerances |

The shared defaults are defined in `c.common_model`.

### Experiment settings

| Experiment | Driver (PAR) | Range | Fixed contrasts |
| --- | --- | --- | --- |
| 1. Productivity | `deltar` (15) | 0 to 1 | `deltas = 0` |
| 2. Attack rate | `deltas` (16) | 0 to 1 | `deltar = 0` |
| 3. Fitness-based movement | `beta` (17) | 0 to 20 | `deltar = 0.2`; `deltas = 0.02` |

Unless specified in the **Fixed contrasts** column, all variables are fixed.

## License

## References

- [AUTO-07p Manual](https://tinyurl.com/45449y9r)
