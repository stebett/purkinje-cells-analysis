import neo
import elephant
import numpy as np
import glob
import quantities as pq
import matplotlib.pyplot as plt
import os

from elephant.gpfa import GPFA

spiketrains = []

filelist = glob.glob('data/couples/*.npy')
dictionary = {}
for x in filelist:
    key = x[:26] 
    group = dictionary.get(key,[])
    group.append(neo.SpikeTrain(np.load(x), t_stop=2000., units="ms"))
    dictionary[key] = group

spiketrains = list(dictionary.values())


X = spiketrains[:32]
y = spiketrains[32:]

bin_size = 1 * pq.ms
latent_dimensionality = 2
gpfa_2dim = GPFA(bin_size=bin_size, x_dim=latent_dimensionality)

gpfa_2dim.fit(X)
trajectories = gpfa_2dim.transform(y)


for i in os.listdir("data/trajectories"):
    os.remove("data/trajectories/"+i)

for i, t in enumerate(trajectories):
    for x in range(1, 3):
        np.save(f"data/trajectories/traj_{i+1}_{x}", t[x-1])












f, ax2 = plt.subplots(1, 1, figsize=(10, 10))

linewidth_single_trial = 0.5
color_single_trial = 'C0'
alpha_single_trial = 0.5

linewidth_trial_average = 2
color_trial_average = 'C1'

ax2.set_title('Latent dynamics extracted by GPFA')
ax2.set_xlabel('Dim 1')
ax2.set_ylabel('Dim 2')
ax2.set_aspect(1)
# single trial trajectories
for single_trial_trajectory in trajectories:
    ax2.plot(single_trial_trajectory[0], single_trial_trajectory[1], '-', lw=linewidth_single_trial, c=color_single_trial, alpha=alpha_single_trial)
# trial averaged trajectory
# average_trajectory = np.mean(trajectories, axis=0)
# ax2.plot(average_trajectory[0], average_trajectory[1], '-', lw=linewidth_trial_average, c=color_trial_average, label='Trial averaged trajectory')
# ax2.legend()

plt.tight_layout()
plt.show()
























X = spiketrains[:14]
y = spiketrains[14:]

bin_size = 1 * pq.ms
latent_dimensionality = 2
gpfa_2dim = GPFA(bin_size=bin_size, x_dim=latent_dimensionality)

gpfa_2dim.fit(X)
trajectories = gpfa_2dim.transform(y)
trajectories_all = gpfa_2dim.fit_transform(spiketrains)

linewidth_single_trial = 0.5
color_single_trial = 'C0'
alpha_single_trial = 0.5

linewidth_trial_average = 2
color_trial_average = 'C1'

f, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))
ax1.set_title('Latent dynamics extracted by GPFA')
ax1.set_xlabel('Dim 1')
ax1.set_ylabel('Dim 2')
ax1.set_aspect(1)
for single_trial_trajectory in trajectories_all:
    ax1.plot(single_trial_trajectory[0], single_trial_trajectory[1], '-', lw=linewidth_single_trial, c=color_single_trial, alpha=alpha_single_trial)
average_trajectory = np.mean(trajectories_all, axis=0)
ax1.plot(average_trajectory[0], average_trajectory[1], '-', lw=linewidth_trial_average, c=color_trial_average, label='Trial averaged trajectory')
ax1.legend()

trial_to_plot = 1
ax2.set_title(f'Trajectory for trial {trial_to_plot}')
ax2.set_xlabel('Time [s]')
times_trajectory = np.arange(len(trajectories_all[trial_to_plot][0])) * bin_size.rescale('s')
ax2.plot(times_trajectory, trajectories_all[0][0], c='C0', label="Dim 1, fitting with all trials")
ax2.plot(times_trajectory, trajectories[0][0], c='C0', alpha=0.2, label="Dim 1, fitting with a half of trials")
ax2.plot(times_trajectory, trajectories_all[0][1], c='C1', label="Dim 2, fitting with all trials")
ax2.plot(times_trajectory, trajectories[0][1], c='C1', alpha=0.2, label="Dim 2, fitting with a half of trials")
ax2.legend()

plt.tight_layout()
plt.show()

def plot3d():

    bin_size = 1 * pq.ms
    latent_dimensionality = 3

    gpfa_2dim = GPFA(bin_size=bin_size, x_dim=latent_dimensionality)

    gpfa_2dim.fit(X)

    trajectories = gpfa_2dim.transform(y)

    f = plt.figure(figsize=(8, 8))
    ax1 = f.add_subplot(1, 1, 1, projection='3d')

    linewidth_single_trial = 0.5
    color_single_trial = 'C0'
    alpha_single_trial = 0.5

    linewidth_trial_average = 2
    color_trial_average = 'C1'

    ax1.set_title('Latent dynamics extracted by GPFA')
    ax1.set_xlabel('Dim 1')
    ax1.set_ylabel('Dim 2')
    ax1.set_zlabel('Dim 3')
# single trial trajectories
    for single_trial_trajectory in trajectories:
        ax1.plot(single_trial_trajectory[0], single_trial_trajectory[1], single_trial_trajectory[2],
                 lw=linewidth_single_trial, c=color_single_trial, alpha=alpha_single_trial)
# trial averaged trajectory
    average_trajectory = np.mean(trajectories, axis=0)
    ax1.plot(average_trajectory[0], average_trajectory[1], average_trajectory[2], lw=linewidth_trial_average, c=color_trial_average, label='Trial averaged trajectory')
    ax1.legend()
    ax1.view_init(azim=-5, elev=60)  # an optimal viewing angle for the trajectory extracted from our fixed spike trains

    plt.tight_layout()
    plt.show()
