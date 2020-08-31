"""
Bernoulli Multi-Armed bandits

Three implementations: 
- Bernoulli Greedy
- Bernouilli e-Greedy
- Bernoulli UCB
- Bayesian (Thompson sampling)

Codes only the pulling of arms
"""

#from BayesianBandit_Gaussian import BernThompson

import numpy as np
import matplotlib.pyplot as plt
from pdb import set_trace


class BanditAlgo():
  """
  The algos try to learn which Bandit arm is the best to maximize reward.
  
  It does this by modelling the distribution of the Bandit arms with a Beta, 
  assuming the true probability of success of an arm is Normally distributed.
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
    #we needed to compute the mean and variance incrementally
    self.pull_count = np.zeros(self.arm_count)

    #Prior distribution of rewards for each arm is normal(0,1)
    self.mean = np.zeros(self.arm_count)
    self.variance = np.ones(self.arm_count)
    #self.alpha = np.ones(self.arm_count)
    #self.beta = np.ones(self.arm_count)
  
  def get_reward_regret(self, arm):
    reward, regret = self.bandit.get_reward_regret(arm)
    self._update_params(arm, reward)
    return reward, regret
  
  def _update_params(self, arm, reward):
    self.pull_count[arm] += 1
    n = self.pull_count[arm]
    
    #Now update the mean 
    #math explanation here: http://datagenetics.com/blog/november22017/index.html
    previous_mean = self.mean[arm]
    self.mean[arm] += (1/n) * (reward + n*previous_mean - previous_mean)

    #Now update the variance incrementally
    previous_variance += self.variance[arm]
    self.variance[arm] += previous_variance + (reward - previous_mean)*(reward - self.mean[arm])
    #self.alpha[arm] += reward
    #self.beta[arm] += 1 - reward


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

ucb_c = 2
class UCB():
  """
  Epsilon Greedy with incremental update.
  Based on Sutton and Barto pseudo-code, page. 24
  """
  def __init__(self, bandit):
    global ucb_c
    self.ucb_c = ucb_c
    self.bandit = bandit
    self.arm_count = bandit.arm_count
    self.Q = np.zeros(self.arm_count) # q-value of actions
    self.N = np.zeros(self.arm_count) + 0.0001 # action count
    self.timestep = 1
  
  @staticmethod
  def name():
    return 'ucb'
  
  def get_action(self):
    ln_timestep = np.log(np.full(self.arm_count, self.timestep))
    confidence = self.ucb_c * np.sqrt(ln_timestep/self.N)
    action = np.argmax(self.Q + confidence)
    self.timestep += 1
    return action
  
  def get_reward_regret(self, arm):
    reward, regret = self.bandit.get_reward_regret(arm)
    self._update_params(arm, reward)
    return reward, regret
  
  def _update_params(self, arm, reward):
    self.N[arm] += 1 # increment action count
    self.Q[arm] += 1/self.N[arm] * (reward - self.Q[arm]) # inc. update rule
    
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
  
def multi_plot_data(data, names):
  """ data, names are lists of vectors """
  x = np.arange(data[0].size)
  for i, y in enumerate(data):
    plt.plot(x, y, 'o', markersize=2, label=names[i])
  plt.legend(loc='upper right', prop={'size': 16}, numpoints=10)
  plt.show()
  
def simulate(simulations, timesteps, arm_count, Algorithm):
  """ Simulates the algorithm over 'simulations' epochs """
  sum_regrets = np.zeros(timesteps)
  for e in range(simulations):
    bandit = Bandit(arm_count)
    algo = Algorithm(bandit)
    regrets = np.zeros(timesteps)
    for i in range(timesteps):
      action = algo.get_action()
      reward, regret = algo.get_reward_regret(action)
      regrets[i] = regret
    sum_regrets += regrets  
  mean_regrets = sum_regrets / simulations
  return mean_regrets

def experiment(arm_count, timesteps=1000, simulations=1000):
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
    regrets.append(simulate(simulations, timesteps, arm_count, algo))
    names.append(algo.name())
  multi_plot_data(regrets, names)


#Main instantiates bandit
bandit = Bandit(arms=3)
bandit_Algo = BanditAlgo(bandit)
banditBernThompson = BernThompsom(bandit_Algo)


#BanditAlgo algo =  BanditAlgo(BernThompson)
#algo = Algorithm(bandit)
