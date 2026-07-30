===============================================================================
0. TABLE OF CONTENTS
===============================================================================

1. PROJECT OVERVIEW
2. REPOSITORY CONTENTS
3. INSTALLATION
4. RUNNING THE EXPERIMENTS
5. IMPORTANT SIMULATION VARIABLES / PARAMETERS / SETTINGS
6. LICENSE
7. REFERENCES


===============================================================================
1. PROJECT OVERVIEW 
===============================================================================

This repository contains a two-patch tri-trophic model analyzed with AUTO-07p.
The model describes predators, foragers, and juveniles in littoral and pelagic
habitats.

The scripts are launched from Jupyter notebooks inside AUTO-Docker container.


===============================================================================
2. REPOSITORY CONTENTS
===============================================================================

FILE OR FOLDER
    DESCRIPTION

common_model.f90
    Defines the six-dimensional ODE model and the AUTO starting point.

c.common_model
    Defines the default AUTO continuation settings.

plot_3x3.py
    Applies the shared formatting for the three 3-by-3 figures 
    codimension-2 plots. 

experiment_1_productivity.ipynb
    Runs the productivity analysis.

experiment_2_attack_rate.ipynb
    Runs the attack-rate analysis.

experiment_3_fitness_dependent_movement.ipynb
    Runs the fitness-dependent movement analysis.

run_all_experiments.ipynb
    Runs the main experiments from a single notebook.

movement_tests.py
    Tests movement and fitness calculations independently of AUTO.

Extra_Experiments/
    Contains supplementary analyses.

output/
    Contains generated figures and analysis outputs.

NOTE: AUTO may generate working files named fort.*, b.*, s.*, and d.*. These 
are intermediate outputs and should be automatically deleted once the script
finished running.


===============================================================================
3. INSTALLATION
===============================================================================

3.1 Required software
--------------------

-Docker Desktop:
     https://docs.docker.com/desktop/

-Git:
     https://git-scm.com/downloads/

** AUTOdocker packages AUTO and its required software inside the container 
and launches Jupyter itself. 

1. Install AUTOdocker
---------------------

Follow the installation instructions in the AUTOdocker repository:
https://github.com/rhparker/AUTOdocker

2. Download this repository
---------------------------

git clone https://github.com/Tristan-Kolla/fitness-movement.git
cd fitness-movement

** Alternatively, you can download the repository as a ZIP file:
https://github.com/Tristan-Kolla/fitness-movement


3. Connect the repository to AUTOdocker
---------------------------------------

Copy the appropriate AUTOdocker compose file into the root directory of this
repository. If using docker-compose-arm.yml, rename the copied file to
docker-compose.yml.

From the repository root, start AUTOdocker:

docker compose up

The repository root is mounted as /auto/workspace in the container. Open that
directory in Jupyter before running the notebooks. Files written to output/
are retained in the local repository after the container stops.


===============================================================================
4. RUNNING THE EXPERIMENTS
===============================================================================

1. Open run_all_experiments.ipynb.

2. Confirm that the notebook working directory is the repository root.

3. Select "Run All Cells."

4. Review the generated files in the output/ directory.

** Alternatively, you can run each experiment individually by "Run All Cells"
in their respective jupyter notebook. 


===============================================================================
5. IMPORTANT SIMULATION VARIABLES / PARAMETERS / SETTINGS
===============================================================================

5.1 Model parameters
--------------------

PAR  NAME     DEFAULT  MEANING
---  -------  -------  -------------------------------------------------------
 1   r         0.40    Baseline intrinsic growth rate of foragers
 2   a         0.05    Baseline predator attack-rate coefficient
 3   m         0.10    Mortality rate
 4   b         0.06    Forager density-dependence coefficient
 5   s         0.005   Predation saturation coefficient
 6   e         0.10    Forager conversion efficiency
 7   fec       1.00    Predator fecundity
 8   g         0.30    Maximum juvenile maturation rate
 9   q         0.15    Juvenile-forager interaction rate
10   c         0.02    Juvenile-predator interaction rate
11   dP        0.50    Predator movement rate
12   dF        0.50    Forager movement rate
13   dJ        0.50    Juvenile movement rate
14   mu        0.00    Fishing effort; principal continuation parameter
15   deltar    0.00    Productivity contrast between habitats
16   deltas    0.00    Attack-rate contrast between habitats
17   beta      0.25    Sensitivity of movement to the fitness difference
18   toggle    1.00    Movement switch: 1 = on and 0 = off
**The defaults below are assigned in STPNT in common_model.f90.
***Parameternumbers are the indices used by AUTO (PAR). 


5.2 Habitat-specific values
---------------------------

rL = r(1 - deltar)   Littoral growth rate     
rP = r(1 + deltar)   Pelagic growth rate
aL = a(1 - deltas)   Littoral attack rate      
aP = a(1 + deltas)   Pelagic attack rate


5.3 Important AUTO continuation settings
---------------------------------------------

SETTING             SHARED VALUE       PURPOSE
------------------  -----------------  ---------------------------------------
ICP                 14                 Initially continue fishing effort, mu
DS                  5e-4               Initial pseudo-arclength step size
DSMIN / DSMAX       1e-4 / 5e-2        Minimum and maximum step sizes
NMX                 1000               Maximum continuation steps
EPSL / EPSU / EPSS  1e-8/1e-8/1e-6     Convergence tolerances
** The shared defaults are defined in c.common_model.


5.4 Experiment settings
-----------------------

EXPERIMENT                  DRIVER (PAR)  RANGE    FIXED CONTRASTS
--------------------------  ------------  -------  ----------------------------
1. Productivity             deltar (15)   0 to 1   deltas = 0
2. Attack rate              deltas (16)   0 to 1   deltar = 0
3. Fitness-based movement   beta (17)     0 to 20  deltar = 0.2; deltas = 0.02
** Unless specified in the 'FIXED CONTRASTS' column, all variables are fixed.

===============================================================================
6. LICENSE
===============================================================================


===============================================================================
6. REFERENCES
===============================================================================

AUTO-07p Manual:
https://tinyurl.com/45449y9r
