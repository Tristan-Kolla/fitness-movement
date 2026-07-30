# This file contains plotting settings for two figure types:
# 1. A one-dimensional bifurcation diagram showing predator abundance against fishing effort.
# 2. A 3x3 grid showing collapse and recovery thresholds at nine different movement rates.

# This file only converts the resulting AUTO branches into Matplotlib figures.

import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

# ------------------------------------------------------------------------------------------------------------


# Stores the figure display settings for the three experiments.
# driver_name: name of the AUTO parameter plotted along the horizontal axis.
   

PLOT_SETTINGS = {
    1: {
        "driver_name": "deltar",
        "x_limits": (0.0, 1.0),
        "y_limits": (0.09, 0.22),
        "y_ticks": [0.10, 0.125, 0.15, 0.175, 0.20],
        "x_label": "variation in productivity (Δr)",
        "title": "productivity variation",
        "filename": "2d_experiment_1_productivity.png",
    },
    2: {
        "driver_name": "deltas",
        "x_limits": (0.0, 1.0),
        "y_limits": (0.11, 0.14),
        "y_ticks": [0.11, 0.12, 0.13, 0.14],
        "x_label": "variation in attack rate (Δs)",
        "title": "Attack-rate variation",
        "filename": "2d_experiment_2_attack_rate.png",
    },
    3: {
        "driver_name": "beta",
        "x_limits": (0.0, 20.0),
        "y_limits": (0.10, 0.15),
        "y_ticks": [0.10, 0.11, 0.12, 0.13, 0.14, 0.15],
        "x_label": "sensitivity to fitness-dependent movement (β)",
        "title": "Movement sensitivity",
        "filename": "2d_experiment_3_fitness_dependent_movement.png",
    },
}

# ------------------------------------------------------------------------------------------------------------

# INPUT:
# equilibrium : an iterable AUTO continuation result. Each branch must provide:
#               branch["mu"] = fishing-effort values
#               branch["PP"] = pelagic predator abundance values
#
# OUTPUT:
# A Matplotlib Figure 

def plot_equilibrium_diagram(equilibrium):
    
    figure, axis = plt.subplots(figsize=(4.2, 3.2), constrained_layout=True)

    # An AUTO result may contain multiple solution branches.
    for branch in equilibrium:
        predator = branch["PP"]

        # if even one value is below -1.0e-7, the complete branch is excluded from the figure.
        if min(predator) >= -1.0e-7:
            axis.plot(branch["mu"], predator, color="black", linewidth=1.5)

    # The small negative y margin leaves visual space below zero.
    axis.set_xlim(0.0, 0.15)
    axis.set_ylim(-0.04, 1.35)
    
    axis.set_xlabel("fishing effort (μ)", fontsize=8)
    axis.set_ylabel("pelagic predator abundance", fontsize=8)
    axis.set_title("Pelagic predator bifurcation (movement rate = 2)", fontsize=9)
    axis.grid(True, alpha=0.2, linewidth=0.4)
    axis.tick_params(labelsize=7)

    return figure

# ------------------------------------------------------------------------------------------------------------

# INPUTS:
# panels       : a sequence of movement-rate result dictionaries. 
#                Each panel must have the following structure:
#                {
#                    "movement_rate": numeric rate displayed above the panel,
#                    "bp_curve": iterable of recovery-threshold branches,
#                    "lp_curve": iterable of collapse-threshold branches,
#                }
#                Each curve branch must provide branch[driver_name] and branch["mu"]. 

# experiment   : experiment number 1, 2, or 3; selects PLOT_SETTINGS.
# output_folder: pathlib.Path directory in which the figures are saved.
# save_svg     : if True, save an SVG in addition to the default PNG.
#
# OUTPUT:
# Saves the completed figure and closes it. This function does not return the
# Figure object.

def save_3x3_plot(panels, experiment, output_folder, save_svg=False):
    
    settings = PLOT_SETTINGS[experiment]
    driver_name = settings["driver_name"]

    # Create nine plotting axes arranged in three rows and three columns.
    figure, axes = plt.subplots(
        3,
        3,
        figsize=(6.5, 5.0),
        sharex=True,
        sharey=True,
    )

    # Makes space between the panels. 
    figure.subplots_adjust(
        left=0.11,
        right=0.985,
        bottom=0.12,
        top=0.80,
        wspace=0.28,
        hspace=0.42,
    )


    for axis, panel in zip(axes.flat, panels):
        # BP is the recovery threshold.
        for branch in panel["bp_curve"]:
            axis.plot(
                branch[driver_name],
                branch["mu"],
                color="black",
                linewidth=1.5,
            )

        # LP is the collapse threshold. 
        for branch in panel["lp_curve"]:
            axis.plot(
                branch[driver_name],
                branch["mu"],
                color="#d62728",
                linewidth=1.5,
            )

        # Label this subplot with its movement rate. The :g format removes unnecessary trailing zeros
        axis.set_title(
            f'movement rate is {panel["movement_rate"]:g}',
            fontsize=7,
            pad=4,
        )

        axis.set_xlim(settings["x_limits"])
        axis.set_ylim(settings["y_limits"])
        axis.set_yticks(settings["y_ticks"])

        axis.grid(True, alpha=0.2, linewidth=0.4)
        axis.tick_params(labelsize=6, pad=2, labelleft=True)

    figure.suptitle(
        settings["title"],
        y=0.985,
        fontsize=9,
        fontweight="semibold",
    )
    figure.supxlabel(settings["x_label"], y=0.035, fontsize=8)
    figure.supylabel("fishing effort (μ)", x=0.025, fontsize=8)
    
    # Legend
    legend_lines = [
        Line2D([], [], color="#d62728", label="collapse threshold"),
        Line2D([], [], color="black", label="recovery threshold"),
    ]

    # Place legend above the grid
    figure.legend(
        handles=legend_lines,
        loc="upper center",
        ncol=2,
        frameon=False,
        bbox_to_anchor=(0.5, 0.935),
        fontsize=7,
    )

    # Output directory
    png_path = output_folder / settings["filename"]
    figure.savefig(png_path, dpi=200, bbox_inches="tight")

    # Optionally save a svg file
    if save_svg:
        figure.savefig(png_path.with_suffix(".svg"), bbox_inches="tight")

    # Delete figure from memory
    plt.close(figure)
