"
ThompsonSampling_RankingYES 

"

library(ggplot2)


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
first_question_id <- min(question_id_list)

answers_per_question = 20
K = length(question_id_list)  #number of arms (questions) starts with zero.
H = answers_per_question * K #number of iterations (Horizon or budget, total answers obtained)
questions_selected = integer(0);
cumulative_reward_list = integer(H) #one reward for each iteration

numbers_of_rewards_1 = integer(K) #k arms or questions
numbers_of_rewards_0 = integer(K)
# These two variables will be put in place in the for loops
total_reward = 0
reward=0

#------------------------------------------------------------------
#Call each question once before deciding between explore/exploit
#pull the best arm
for(question in 1:K){
  question_id = question + first_question_id - 1 #Convert back to the Question.ID scale
  answer_id <- trunc(runif(n=1,min=1,max=answers_per_question))
  reward = answer_df[answer_df$Question.ID==question_id,"Answer.reward"][answer_id] #this should done by sampling, not in order.
  cumulative_reward_list[question] = reward
  questions_selected <- append(questions_selected,question)
  
  #update believe about its reward distribution
  if (reward == 1) {
    numbers_of_rewards_1[question] = numbers_of_rewards_1[question] + 1
  } else {
    numbers_of_rewards_0[question] = numbers_of_rewards_0[question] + 1
  }
  total_reward = total_reward + reward
}
#----------------------------------------------------------------


#Now look for the best ARM
for (h in 1:H) {
  question=0
  max_probability = 0
  #Sample and Take the arm with highest reward
  for (k in 1:K) {
    #sample
    #adding 1 because they start with zero, so it is using beta(1,1) flat prior
    sampled_probability = rbeta(n = 1,
                        shape1 = numbers_of_rewards_1[k] + 1,
                        shape2 = numbers_of_rewards_0[k] + 1); 
    #argmax
    #continue until it finds a probability of 1 that is the highest 
    if(sampled_probability > max_probability){
      max_probability <- sampled_probability;
      question <-  k;
    }
  }
  questions_selected = append(questions_selected, question);
  
  #pull the best arm
  question_id = question + first_question_id - 1 #Convert back to the Question.ID scale
  answer_id <- trunc(runif(n=1,min=1,max=answers_per_question))
  reward = answer_df[answer_df$Question.ID==question_id,"Answer.reward"][answer_id] #sample an answer
  cumulative_reward_list[h] = cumulative_reward_list[h-1] + reward

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

#Which question was selected at each step (nice to mark the correct ones)
hist(questions_selected,freq=TRUE,bin=1,
     col = 'grey',
     main = 'Histogram of questions answered',
     xlab = 'Questions',
     ylab = '#answers'
)


ggplot(sampled_dataf,aes(sampled_dataf$Question.ID)) + 
  geom_histogram(binwidth = 1) +
  labs(title=paste("Answer per Question","")) +
  labs(x="Question.ID", y="Total answers") + 
  xlim(c(1,130));


#cumulative rewards (number of YES)
plot(type="l", cumulative_reward_list, xlab="iterations",ylab="reward", main="Cumulative rewards")


#precision and recall

