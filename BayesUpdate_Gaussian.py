"""
Bayesian Update of a Gaussian data generation process
"""
import numpy as np
import scipy.stats as stats

class BayesUpdate_Guassian():
  """
  The algorithm updates a univariate Gaussian posterior distribution based on 
  new data observed.
  
  The parameters of the Gaussian (Meand and Variance) are also modeled as 
  Gaussian distributions.
  """
  def __init__(self,prior):
    """
    Args:
      prior: the prior probability to be used
    """
    self.mean = 0.0
    self.variance = 1.0

  def _likelihood(self, mean, variance):
    return np.random.norm(mean,variance)

  def _update(self, prior, observation):
    """
    Peforms a single update and returns the posterior
    Args:
      prior: the current probability distribution of the target variable
    """
    
    #Now update the mean incrementally 
    #math explanation here: http://datagenetics.com/blog/november22017/index.html
    previous_mean = self.mean
    self.mean += (1/n) * (observation + n*previous_mean - previous_mean)

    #Now update the variance incrementally
    previous_variance += self.variance
    self.variance += previous_variance + (observation - previous_mean)*(observation - self.mean)
    
    likelihood = self._likelihood(mean,variance)
    posterior = (likelihood * prior) / sum(posterior)
    return posterior

### MAIN
observation_list = [1, 0, 0.5, 0.6, 0.7, 0.5, 0.4, 0.3, 0.3, 0.5, 0.4]
prior = np.random.beta(1,1) #uses an uninformative prior
update_algo = BayesUpdate_Guassian(prior)
for observation in observation_list:
  prior = update_algo._update(prior,observation)
  #plot(prior)
  

