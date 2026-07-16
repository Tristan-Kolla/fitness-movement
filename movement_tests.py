import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp


r = 0.400
a = 0.05

bL = 0.060
bP = 0.060
sL = 0.005
sP = 0.005

eL = 0.2
eP = 0.2

gL = 0.2
gP = 0.2

mJ = 0.1
qL = 0.2
qP = 0.2
cL = 0.02
cP = 0.02

dP = 0.1
dF = 0.1
dJ = 0.1

alphaP = 0.25
alphaF = 0.25
alphaJ = 0.25
PAYOFF_FLOOR = 1e-12


def sig(x):
    return 1 / (1 + np.exp(-x))


def emig(d, alpha, win, wout, beta):
    return d * sig(beta * alpha * (wout - win))


def habitat_attack_rates(deltas):
    return a * (1 - deltas), a * (1 + deltas)


def get_fitness(y, deltar, deltas):
    PL, FL, JL, PP, FP, JP = y

    rL = r * (1 + deltar)
    rP = r * (1 - deltar)

    aL = a * (1 - deltas)
    aP = a * (1 + deltas)
    
    fitPL = 0
    fitPP = 0

    RF_L = (
        (rL - bL * FL)
        - (aL * PL * FL) / (1 + sL * FL * FL)
        + eL * qL * JL
    )

    RF_P = (
        (rP - bP * FP)
        - (aP * PP * FP) / (1 + sP * FP * FP)
        + eP * qP * JP
    )

    fitFL = np.log(max(np.exp(RF_L), PAYOFF_FLOOR))
    fitFP = np.log(max(np.exp(RF_P), PAYOFF_FLOOR))

    juvenile_maturation_L = gL / (1 + JL * JL)
    juvenile_death_L = mJ + qL * FL + cL * PL
    juvenile_maturation_P = gP / (1 + JP * JP)
    juvenile_death_P = mJ + qP * FP + cP * PP

    fitJL = np.log(
        max(juvenile_maturation_L, PAYOFF_FLOOR)
        / max(juvenile_death_L, PAYOFF_FLOOR)
    )
    fitJP = np.log(
        max(juvenile_maturation_P, PAYOFF_FLOOR)
        / max(juvenile_death_P, PAYOFF_FLOOR)
    )

    return fitPL, fitFL, fitJL, fitPP, fitFP, fitJP


def movement_only_model(t, y, beta, deltar, deltas):
    PL, FL, JL, PP, FP, JP = y

    fitPL, fitFL, fitJL, fitPP, fitFP, fitJP = get_fitness(y, deltar, deltas)

    PL_to_PP = emig(dP, alphaP, fitPL, fitPP, beta)
    PP_to_PL = emig(dP, alphaP, fitPP, fitPL, beta)

    FL_to_FP = emig(dF, alphaF, fitFL, fitFP, beta)
    FP_to_FL = emig(dF, alphaF, fitFP, fitFL, beta)

    JL_to_JP = emig(dJ, alphaJ, fitJL, fitJP, beta)
    JP_to_JL = emig(dJ, alphaJ, fitJP, fitJL, beta)

    dPL = -PL_to_PP * PL + PP_to_PL * PP
    dPP = -PP_to_PL * PP + PL_to_PP * PL

    dFL = -FL_to_FP * FL + FP_to_FL * FP
    dFP = -FP_to_FL * FP + FL_to_FP * FL

    dJL = -JL_to_JP * JL + JP_to_JL * JP
    dJP = -JP_to_JL * JP + JL_to_JP * JL

    return [dPL, dFL, dJL, dPP, dFP, dJP]


def simulate(y0, beta, deltar, deltas, t_end=100):
    t_eval = np.linspace(0, t_end, 1000)

    return solve_ivp(
        movement_only_model,
        [0, t_end],
        y0,
        t_eval=t_eval,
        args=(beta, deltar, deltas),
        rtol=1e-9,
        atol=1e-12,
    )


def plot_experiment(name, y0, deltar=0.0, deltas=0.0, t_end=100):
    beta_values = [0, 1, 5]

    fig, axes = plt.subplots(3, 3, figsize=(13, 9), sharex=True, sharey=True)

    for row, beta in enumerate(beta_values):
        sol = simulate(y0, beta, deltar, deltas, t_end)

        PL, FL, JL, PP, FP, JP = sol.y

        groups = [
            ("Forager", FL, FP, (FL + FP) / 2),
            ("Predator", PL, PP, (PL + PP) / 2),
            ("Juvenile", JL, JP, (JL + JP) / 2),
        ]

        for col, (title, littoral, pelagic, total) in enumerate(groups):
            ax = axes[row, col]

            ax.plot(sol.t, pelagic, label="pelagic")
            ax.plot(sol.t, littoral, label="littoral")
            ax.plot(sol.t, total, "--", label="patch average")

            ax.set_ylim(0, 5)
            ax.grid(alpha=0.25)

            if row == 0:
                ax.set_title(title, fontsize=13)

            if col == 0:
                ax.text(
                    -0.28,
                    0.5,
                    f"beta = {beta}",
                    transform=ax.transAxes,
                    rotation=90,
                    va="center",
                    ha="center",
                    fontsize=12,
                )

    handles, labels = axes[0, 0].get_legend_handles_labels()

    fig.legend(
        handles,
        labels,
        loc="upper center",
        ncol=3,
        frameon=False,
        bbox_to_anchor=(0.5, 0.965),
    )

    fig.suptitle(name, fontsize=16, y=1.03)
    fig.supxlabel("Time", fontsize=20)
    fig.supylabel("Abundance", fontsize=20)

    plt.tight_layout(rect=[0.04, 0.04, 1, 0.92])
    plt.show()


experiments = [
    {
        "name": "Experiment 1: Equal initial abundance, no habitat heterogeneity",
        "y0": [2, 2, 2, 2, 2, 2],
        "deltar": 0.0,
        "deltas": 0.0,
    },
    {
        "name": "Experiment 2: Unequal initial abundance, no habitat heterogeneity",
        "y0": [2.3, 2.3, 2.3, 1.7, 1.7, 1.7],
        "deltar": 0.0,
        "deltas": 0.0,
    },
    {
        "name": "Experiment 3: Equal initial abundance, variation in productivity delta r = 0.2",
        "y0": [2, 2, 2, 2, 2, 2],
        "deltar": 0.2,
        "deltas": 0.0,
    },
    {
        "name": "Experiment 4: Equal initial abundance, variation in attack rate delta a = 0.025",
        "y0": [2, 2, 2, 2, 2, 2],
        "deltar": 0.0,
        "deltas": 0.025,
    },
    {
        "name": "Experiment 5: Equal initial abundance (predator extinct), variation in attack rate delta a = 0.025",
        "y0": [0, 2, 2, 0, 2, 2],
        "deltar": 0.0,
        "deltas": 0.025,
    },
    {
        "name": "Experiment 6: Unequal initial abundance, variation in productivity detar = 0.2 and attack rate delta a = 0.025",
        "y0": [1.7, 1.7, 1.7, 2.3, 2.3, 2.3],
        "deltar": 0.2,
        "deltas": 0.025,
    },
    {
        "name": "Experiment 7 Unequal initial abundance, variation in productivity detar = 0.2 and attack rate delta a = 0.005",
        "y0": [1.6, 1.6, 1.6, 2.4, 2.4, 2.4],
        "deltar": 0.2,
        "deltas": 0.005,
    }
]


for experiment in experiments:
    plot_experiment(
        name=experiment["name"],
        y0=experiment["y0"],
        deltar=experiment["deltar"],
        deltas=experiment["deltas"],
    )
