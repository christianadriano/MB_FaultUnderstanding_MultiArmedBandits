"
ThompsonSampling_RankingYES 

"

source("C://Users//Christian//Documents//GitHub//ML_VotingAggregation//aggregateVotes.R");

# Import data
source("C://Users//Christian////Documents//GitHub//ML_VotingAggregation//loadAllAnswers.R");
answerPopulation_df <- loadAnswers("answerList_data.csv");
summary(answerPopulation_df)

#List of failing methods
#"HIT01_8","HIT02_24","HIT03_6","HIT06_51","HIT04_7","HIT05_35","HIT07_33","HIT08_54"
failing_methods <- c(levels(unique(answerPopulation_df$FailingMethod)))

#select one bug
answer_df <- answerPopulation_df[answerPopulation_df$FailingMethod==failing_methods[1],]
question_id_list <- unique(answer_df$Question.ID)

H = 100 #number of iterations (Horizon or budget)
K = length(question_id_list) #number of arms (questions)
questions_selected = integer(0)
cumulative_reward_list = integer(H+1)
cumularive_reward_list[1] = 0

numbers_of_rewards_1 = integer(K) # the K above sets the initial as 10
numbers_of_rewards_0 = integer(K)
# These two variables will be put in place in the for loops
total_reward = 0
for (h in 1:H) {
  question = question_id_list[1] #maybe I do not need to set this up.
  max_random = 0
  #Sample and Take the arm with highest reward
  for (k in 1:K) {
    #sample
    #adding 1 because they start with zero, so it is using beta(1,1) flat prior
    random_beta = rbeta(n = 1,
                        shape1 = numbers_of_rewards_1[k] + 1,
                        shape2 = numbers_of_rewards_0[k] + 1) 
    #argmax
    if (random_beta > max_random) { 
      max_random = random_beta
      question = k
    }
  }
  questions_selected = append(questions_selected, question)
  #pull the best arm
  reward = dataset[n, question] 
  cumulative_reward_list[h+1] = cumulative_reward_list[h] + reward
  #update believe about its reward distribution
  if (reward == 1) {
    numbers_of_rewards_1[question] = numbers_of_rewards_1[question] + 1
  } else {
    numbers_of_rewards_0[question] = numbers_of_rewards_0[question] + 1
  }
  total_reward = total_reward + reward
}





#-------------------------------------------------------------------------
#Three plots: selected questions, cumulative reward, precision recall.

#which question was selected at each step (nice to mark the correct ones)

#cumulative rewards (number of YES)

#precision and recall

