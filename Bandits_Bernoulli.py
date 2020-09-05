"""
Bernoulli Multi-Armed bandits

Three implementations: 
- Bernoulli Greedy
- Bayesian (Thompson sampling)

Codes only the pulling of arms
"""

import numpy as np
import matplotlib.pyplot as plt
from pdb import set_trace
import Bandit as Bandit

class BanditAlgo():
  """
  The algos try to learn which Bandit arm is the best to maximize reward.
  
  It does this by modelling the distribution of the Bandit arms with a Beta, 
  assuming the true probability of success of an arm is Bernoulli distributed.
  Adapted from: https://github.com/andrecianflone/thompson/blob/master/thompson.ipynb
  """
  def __init__(self, bandit):
    """
    Args:
      bandit: the bandit class the algo is trying to model
    """
    self.bandit = bandit
    self.arm_count = bandit.arm_count
    #Keep track the number of pulls for each arm because
    self.pull_count = np.zeros(self.arm_count)

    #Prior distribution of rewards for each arm
    self.alpha = np.ones(self.arm_count)
    self.beta = np.ones(self.arm_count)
  
  def get_reward_regret(self, arm):
    reward, regret = self.bandit.get_reward_regret(arm)
    self._update_params(arm, reward)
    return reward, regret
  
  def _update_params(self, arm, reward):
    self.pull_count[arm] += 1
    n = self.pull_count[arm]

    #Now update the variance incrementally
    self.alpha[arm] += reward
    self.beta[arm] += 1 - reward


class BernGreedy(BanditAlgo):
  def __init__(self, bandit):
    super().__init__(bandit)
      
  @staticmethod
  def name():
    return 'beta-greedy'
      
  def get_action(self):
    """ Bernouilli parameters are the expected values of the beta"""
    theta = self.alpha / (self.alpha + self.beta) # Theta is the mean of the distribution.
    return theta.argmax()


class BernThompson(BanditAlgo):
  def __init__(self, bandit):
    super().__init__(bandit)

  @staticmethod
  def name():
    return 'thompson'
      
  def get_action(self):
    """ Bernouilli parameters are sampled from the beta"""
    theta = np.random.beta(self.alpha, self.beta)
    return theta.argmax()

#-----------------------------------------------
def plot_data(y):
  """ y is a 1D vector """
  x = np.arange(y.size)
  _ = plt.plot(x, y, 'o')
  
