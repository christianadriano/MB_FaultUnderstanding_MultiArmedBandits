"
Example Implementation of Thompson Sampling 
Source: https://rpubs.com/markloessi/502098
"

#Data source from Kaggle - https://www.kaggle.com/akram24/ads-ctr-optimisation/data
dataset = read.csv(".//data//datasets_21128_27235_Ads_CTR_Optimisation.csv")

N = 10000 #number of iterations
d = 10 #number of arms
ads_selected = integer(0)
# UCB and Thompson Sampling algorithm are very similar but use different variables
# those variables are here
numbers_of_rewards_1 = integer(d) # the d defined above sets the initial as 10
numbers_of_rewards_0 = integer(d)
# These two variables will be put in place in the for loops
total_reward = 0
for (n in 1:N) {
  ad = 0
  max_random = 0
  #Sample and Take the arm with highest reward
  for (i in 1:d) {
    #sample
    #adding 1 because they start with zero, so it is using beta(1,1) flat prior
    random_beta = rbeta(n = 1,
                        shape1 = numbers_of_rewards_1[i] + 1,
                        shape2 = numbers_of_rewards_0[i] + 1) 
    #argmax
    if (random_beta > max_random) { 
      max_random = random_beta
      ad = i
    }
  }
  ads_selected = append(ads_selected, ad)
  #pull the best arm
  reward = dataset[n, ad] 
  #update believe about its reward distribution
  if (reward == 1) {
    numbers_of_rewards_1[ad] = numbers_of_rewards_1[ad] + 1
  } else {
    numbers_of_rewards_0[ad] = numbers_of_rewards_0[ad] + 1
  }
  total_reward = total_reward + reward
}

#Plot outcomes
hist(ads_selected,
     col = 'grey',
     main = 'Histogram of ads selections (Thompson Sampling R)',
     xlab = 'Ads',
     ylab = 'Number of times each ad was selected'
     )
