"""
Run different bandit algorithms and plot their results

"""
import numpy as np
import matplotlib.pyplot as plt

import Bandit as Bandit
from Bandits_Bernoulli import BernGreedy
from Bandits_Bernoulli import BernThompson
from Bandit_UCB_Bernoulli import UCB
from Bandit_EpsilonGreedy_Bernoulli import EpsilonGreedy

class Simulator():

    def multi_plot_data(self, data, names):
        """ data, names are lists of vectors """
        x = np.arange(data[0].size)
        for i, y in enumerate(data):
            plt.plot(x, y, 'o', markersize=2, label=names[i])
        plt.legend(loc='upper right', prop={'size': 16}, numpoints=10)
        plt.show()
    
    def simulate(self, simulations, timesteps, arm_count, Algorithm):
        """ Simulates the algorithm over 'simulations' epochs """
        sum_regrets = np.zeros(timesteps)
        for e in range(simulations):
            bandit = Bandit.Bandit(arm_count)
            algo = Algorithm(bandit)
            regrets = np.zeros(timesteps)
            for i in range(timesteps):
                action = algo.get_action()
                reward, regret = algo.get_reward_regret(action)
                regrets[i] = regret
                sum_regrets += regrets  
        mean_regrets = sum_regrets / simulations
        return mean_regrets

    def experiment(self,arm_count, timesteps=1000, simulations=1000):
        """ 
        Standard setup across all experiments 
        Args:
            timesteps: (int) how many steps for the algo to learn the bandit
            simulations: (int) number of epochs
        """
        algos = [BernGreedy, UCB, BernThompson]
        regrets = []
        names = []
        for algo in algos:
            regrets.append(self.simulate(simulations, timesteps, arm_count, algo))
            names.append(algo.name())
        self.multi_plot_data(regrets, names)

#Main
simulator = Simulator()
simulator.__init__()

arm_count = 2 # number of arms in bandit
epsilon = 0.1
ucb_c = 2
stationary=True
simulator.experiment(arm_count)
