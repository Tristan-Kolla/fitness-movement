# Pre-Submission Review To-Do List

Use this checklist to review the model, code, figures, and manuscript before submission.

## Critical Items

- [ ] Locate or create the canonical manuscript file.
  The repository currently has no substantive manuscript file. A single source of truth is needed so the equations, parameter table, figure captions, and claims can be checked against the implementation.

- [ ] Verify every manuscript equation against `common_model.f90`.
  Check the signs, state variables, functional responses, maturation terms, movement terms, mortality terms, and patch labels. Pay special attention to whether habitat contrasts are multiplicative or additive.

- [ ] Resolve the mismatch between old manuscript-style equations and the live Fortran model.
  The deleted old notebook describes different productivity contrasts and parameter values from the current implementation. Decide which formulation is correct and update all materials accordingly.

- [ ] Recheck Experiment 3 beta continuation.
  The current Fortran default sets `beta = 1`, so the plotted beta continuation appears to cover beta 1 to 4 rather than beta 0 to 4. Any claim about beta 0 or random/unbiased movement needs a rerun from beta 0.

- [ ] Decide whether predator movement is genuinely fitness-dependent.
  Predator fitness is currently fixed at zero in both patches, which makes predator movement symmetric rather than payoff-driven. Either justify this biologically or revise the movement rule and text.

- [ ] Separate or remove `movement_tests.py` from manuscript evidence.
  This script is movement-only and uses parameter values that differ from the Fortran/AUTO model. It should not be cited as reproducing the manuscript model unless it is rewritten and documented as a validation tool.

- [ ] Preserve raw AUTO output data.
  The notebooks currently delete `b.*`, `s.*`, and `d.*` files after plotting. Keep these files, or export equivalent CSV/JSON data, so reviewers can inspect the actual continuation results.

- [ ] Add a reproducible environment specification.
  Add a `requirements.txt`, Conda environment file, Dockerfile, or clear setup instructions including AUTO, `AUTOclui`, `pyvirtualdisplay`, Python, gfortran, NumPy, SciPy, and Matplotlib versions.

## Model Formulation

- [ ] Define all state variables, parameters, and units in one table.
  The model uses predators, foragers, and juveniles in littoral and pelagic patches. A complete table will make dimensions, biological interpretation, and parameter provenance reviewable.

- [ ] Check dimensional consistency.
  Confirm that logistic growth, type III predation, maturation, fecundity, mortality, movement, and fitness/payoff terms are dimensionally compatible.

- [ ] Justify the forager payoff definition.
  The code uses a log-transformed expected lineage multiplier based on forager per-capita growth. Explain why this is the appropriate movement cue and how it relates to fitness.

- [ ] Review the juvenile payoff definition.
  The Fortran model uses log maturation-to-death odds. Confirm that this matches the manuscript and is biologically defensible for juvenile habitat choice.

- [ ] Review the maturation function.
  The maturation term `gJ/(1+J^2)` is nonmonotonic at high juvenile density. Explain the ecological mechanism or consider a more standard saturating form.

- [ ] Establish positivity and boundedness.
  Provide analytical or numerical evidence that biologically relevant solutions remain nonnegative and bounded under the parameter ranges used.

- [ ] Define admissible ranges for `deltar` and `deltas`.
  Because the live code uses multiplicative contrasts, values above 1 can create negative rates. State and enforce the biologically meaningful range.

- [ ] Clarify the role of `mu`.
  The figures use `mu` as an added predator mortality parameter. The manuscript should explain whether this represents harvest, stress, mortality, or a bifurcation control parameter.

## Numerical Workflow

- [ ] Convert notebooks into a reproducible pipeline.
  Provide a script or Makefile that regenerates all figures from a clean checkout without hidden notebook state.

- [ ] Record solver and continuation settings.
  Document `NMX`, `NPR`, `DS`, `DSMIN`, `DSMAX`, `UZSTOP`, tolerances, branch seeds, and stopping criteria for every figure.

- [ ] Check branch-seed assumptions.
  The notebooks assume labels such as `BP1` and `LP1`. Add checks that fail clearly if labels are absent or if the wrong branch is selected.

- [ ] Filter biologically inadmissible branches.
  AUTO may follow branches with tiny negative abundances or nonphysical states. Decide which branches are biologically meaningful and filter or annotate figures accordingly.

- [ ] Remove stale notebook outputs.
  Some saved outputs appear inconsistent with notebook source, especially the extra productivity cusp check. Rerun or clear outputs to prevent reviewers from seeing contradictory provenance.

- [ ] Add regression tests for key bifurcation values.
  Test that the baseline predator-invasion branch point and selected continuation endpoints remain stable after code edits.

- [ ] Add RHS parity tests.
  If both Python and Fortran versions remain in the project, test that they calculate the same derivatives for the same states and parameters.

## Figures and Results

- [ ] Redraw publication-quality figures.
  Current figures include AUTO labels and minimal captions. Prepare clean Oikos-ready figures with clear legends, line meanings, stability conventions, and units.

- [ ] Explain why Experiments 1 and 2 share the same 1D baseline.
  Both begin at `deltar = 0` and `deltas = 0`, so identical 1D panels are expected. Make this explicit or avoid redundant panels.

- [ ] Recreate extra symmetry checks and save their outputs.
  The symmetry notebooks exist but output folders are not present in the active repo. Rerun and retain outputs if these analyses support manuscript claims.

- [ ] Reassess the productivity cusp analysis.
  Confirm whether the cusp check should stop at `deltar = 1` or extend farther. Do not interpret results outside the biologically admissible range without justification.

- [ ] Archive figure source data.
  For each final figure, save the plotted data and the exact script/notebook cell that generated it.

## Scientific Interpretation

- [ ] Add sensitivity analyses.
  Vary movement rates, beta, productivity contrast, attack-rate contrast, mortality, maturation, conversion efficiency, and fecundity to test whether conclusions are robust.

- [ ] Add uncertainty or parameter justification.
  Explain where parameter values come from and whether conclusions depend on arbitrary choices.

- [ ] Test alternative movement rules.
  Compare the logistic movement rule with simpler diffusion, ideal-free movement, or no-movement baselines to show what is caused by fitness-dependent movement.

- [ ] Analyze equilibria and stability beyond plotted branches.
  Include local stability, invasion criteria, and possible bistability or hysteresis where relevant.

- [ ] Clarify ecological novelty.
  State what the two-patch tri-trophic lake model adds beyond existing habitat-coupled food web, predator-prey, and movement literature.

- [ ] Avoid overclaiming biological generality.
  Limit conclusions to the modeled assumptions unless sensitivity analyses show broader robustness.

## Submission Package

- [ ] Write a complete README.
  The current README is a placeholder. Include project purpose, file map, setup instructions, figure-generation commands, and expected outputs.

- [ ] Add a code/data availability statement.
  Prepare a statement that satisfies Oikos expectations for custom simulation code and reproducible analysis materials.

- [ ] Clean ignored and temporary files.
  Ensure `.Trash-0`, checkpoints, caches, and local artifacts are not part of the submission package.

- [ ] Create a final pre-submission verification run.
  From a clean checkout, rerun the full workflow, compare generated figures to manuscript figures, and record the run date and environment.
