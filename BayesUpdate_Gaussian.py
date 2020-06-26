"
Update a Gaussian distribution
"
import numpy as np
import scipy.stats.norm as norm

class GaussianAlgo():
  """
  The algos try to learn which Bandit arm is the best to maximize reward.
  
  It does this by modelling the distribution of the Bandit arms with a Beta, 
  assuming the true probability of success of an arm is Normally distributed.
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

class BernGreedy(BetaAlgo):
  def __init__(self, bandit):
    super().__init__(bandit)
  
  @staticmethod
  def name():
    return 'beta-greedy'
   
  def get_action(self):
    """ Bernouilli parameters are the expected values of the beta"""
    theta = self.alpha / (self.alpha + self.beta)
    return theta.argmax()
  
class BernThompson(BetaAlgo):
  def __init__(self, bandit):
    super().__init__(bandit)

  @staticmethod
  def name():
    return 'thompson'
  
  def get_action(self):
    """ Bernouilli parameters are sampled from the beta"""
    theta = np.random.beta(self.alpha, self.beta)
    return theta.argmax()

class GaussianModel():
    def likelihood(mean,variance):
        return np.norm(mean,variance)