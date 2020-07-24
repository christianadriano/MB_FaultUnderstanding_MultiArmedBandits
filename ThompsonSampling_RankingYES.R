"
ThompsonSampling_RankingYES 

"

library(ggplot2)

path <- "C://Users//Christian//Documents//GitHub//"

source(paste0(path,"//ML_VotingAggregation//aggregateVotes.R"));
source(paste0(path,"ML_QuestionUtility//computeConfusionMatrix.R"));


# Import data
source(paste0(path,"//ML_VotingAggregation//loadAllAnswers.R"));
answerPopulation_df <- loadAnswers("answerList_data.csv");
summary(answerPopulation_df)

#List of failing methods
#"HIT01_8","HIT02_24","HIT03_6","HIT06_51","HIT04_7","HIT05_35","HIT07_33","HIT08_54"
failing_methods <- c(levels(unique(answerPopulation_df$FailingMethod)))

#ranking_top
ranking_top <- 3
failed_method <- 6
#questionList <- c(1,4,10,14,20,23,30,32,55,56,57,58,59,72,73,77,84,92,95,97,102,104,115,119,123);
#"HIT01_8-1,4,","HIT02_24-10,14","HIT03_6-20,23,30,32",,"HIT04_7-55,56,57,58,59,,","HIT05_35-72,73,77","HIT06_51"-84,92,95","HIT07_33-97,102,104","HIT08_54-115,119,123"

actual_bugs <- c(84,92,95)+1

#select one bug
answer_df <- answerPopulation_df[answerPopulation_df$FailingMethod==failing_methods[failed_method],]
question_id_list <- unique(answer_df$Question.ID)
first_question_id <- min(question_id_list)

percentage_budget = 2
answers_per_question = 20
K = length(question_id_list)  #number of arms (questions) starts with zero.
Horizon = percentage_budget*answers_per_question * K #number of iterations (Horizon or budget, total answers obtained)
questions_selected = integer(0);
cumulative_reward_list = integer(Horizon) #one reward for each iteration
cumulative_regret_list = integer(Horizon) #one regret for each time it does not ask a bug covering question

accumStatistics <- data.frame(list(precision=0, recall=0, sensitivity=0, accuracy=0, answers=0,mean_precision=0,mean_recall=0));

numbers_of_rewards_1 = integer(K) #k arms or questions
numbers_of_rewards_0 = integer(K)
# These two variables will be put in place in the for loops
total_reward = 0
reward=0

#data frame with the samples of the arms
sampled_df <- data.frame(matrix(nrow = 0,ncol = 6))
colnames(sampled_df) <- c("Question.ID","Answer.reward","Cumulative.reward","
                          Answer.regret","Cumulative.regret","Iterations")

#------------------------------------------------------------------
#Call each question once before deciding between explore/exploit
#pull the best arm
for(question in 1:K){
  question_id = question + first_question_id - 1 #Convert back to the Question.ID scale
  answer_id <- trunc(runif(n=1,min=1,max=answers_per_question))
  reward = answer_df[answer_df$Question.ID==question_id,"Answer.reward"][answer_id] #this should done by sampling, not in order.
  regret = compute_regret(question_id, actual_bugs);
  if(question==1){
    cumulative_reward_list[question] = reward;
    cumulative_regret_list[question] = regret;
  }else{
    cumulative_reward_list[question] = cumulative_reward_list[question-1] + reward;
    cumulative_regret_list[question] = cumulative_regret_list[question-1] + reward;
  }
  #store the sample obtained
  sampled_df <- rbind(sampled_df,data.frame("Question.ID"=question,"Answer.reward"=reward,
                                            "Cumulative.reward"=cumulative_reward_list[question],
                                            "Answer.regret"=regret,
                                            "Cumulative.regret"=cumulative_reward_list[h],
                                            "Iteration"=question));

  #obtain the total of YES for each question
  df_agg <- aggregate(Answer.reward ~ Question.ID, data=sampled_df, sum)
  #Sort descending
  df_agg_sort <- df_agg[order(df_agg$Answer.reward, decreasing=TRUE),]
  predicted_bugs <- df_agg_sort[1:ranking_top,]$Question.ID
  statistics_f<- computeStatistics(predicted_bugs,actual_bugs); #change name of computeOutcomes to computeStat
  statistics_f$answers <- dim(sampled_df)[1];
  
  accumStatistics <- rbind(accumStatistics,statistics_f);

  #update believe about its reward distribution
  if (reward == 1) {
    numbers_of_rewards_1[question] = numbers_of_rewards_1[question] + 1
  } else {
    numbers_of_rewards_0[question] = numbers_of_rewards_0[question] + 1
  }
}

#----------------------------------------------------------------

start = K+1 #because it has already initialized K arms.
#Now look for the best ARM
for (h in start:Horizon) {
  question=0
  max_probability = 0
  #-----------------------------
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
  
  #------------------------------
  #Pull the best arm
  question_id = question + first_question_id - 1 #Convert back to the Question.ID scale
  answer_id <- trunc(runif(n=1,min=1,max=answers_per_question))
  reward = answer_df[answer_df$Question.ID==question_id,"Answer.reward"][answer_id] #sample an answer
  cumulative_reward_list[h] = cumulative_reward_list[h-1] + reward
  regret = compute_regret(question_id,actual_bugs)
  cumulative_regret_list[h] = cumulative_regret_list[h-1] + regret
  
  sampled_df <- rbind(sampled_df,data.frame("Question.ID"=question,"Answer.reward"=reward,
                                            "Cumulative.reward"=cumulative_reward_list[h],
                                            "Answer.regret"=regret,
                                            "Cumulative.regret"=cumulative_reward_list[h],
                                            "Iteration"=h))
  #------------------------------
  #Compute precision and recall
  #obtain the total of YES for each question
  df_agg <- aggregate(Answer.reward ~ Question.ID, data=sampled_df, sum)
  #Sort descending
  df_agg_sort <- df_agg[order(df_agg$Answer.reward, decreasing=TRUE),]
  predicted_bugs <- df_agg_sort[1:ranking_top,]$Question.ID
  statistics_f<- computeStatistics(predicted_bugs,actual_bugs); #change name of computeOutcomes to computeStat
  statistics_f$answers <- dim(sampled_df)[1];
  statistics_f$mean_precision <- compute_incremental_mean(n=dim(accumStatistics)[1],
                                                          original_mean=mean(accumStatistics$precision),
                                                          new_datapoint=statistics_f$precision)
  
  statistics_f$mean_recall <- compute_incremental_mean(n=dim(accumStatistics)[1],
                                                       original_mean=mean(accumStatistics$recall),
                                                       new_datapoint=statistics_f$recall)
  
  accumStatistics <- rbind(accumStatistics,statistics_f);
  #-------------

  #--------------------------------------------
  #Bayesian Update the believe about the reward distribution of the question
  if (reward == 1) {
    numbers_of_rewards_1[question] = numbers_of_rewards_1[question] + 1
  } else {
    numbers_of_rewards_0[question] = numbers_of_rewards_0[question] + 1
  }
  #-----------
  
}



#-------------------------------------------------------------------------
#Three plots: selected questions, cumulative reward, precision recall.

#Which question was selected at each step (nice to mark the correct ones)
ggplot(sampled_df,aes(Question.ID)) + 
  geom_histogram(binwidth = 1) +
  labs(title=paste("Answer per Question - ",failing_methods[failed_method])) +
  labs(x="Question.ID", y="Total answers") + 
  scale_x_continuous(breaks=seq(1,K, 1)
                     );
#Which question gave the higher reward?
ggplot(df_agg,aes(y=Answer.reward, x=Question.ID)) + 
  geom_bar(stat="identity") +
  labs(title=paste("Reward per Question - ",failing_methods[failed_method])) +
  labs(x="Question.ID", y="Reward");

#cumulative rewards (number of YES)
ggplot(sampled_df,aes(Iteration,Cumulative.reward)) + 
  geom_line() +#aes(y=100*precision, colour="precision"))+
  #geom_point(aes(x=answers,y=100*precision), shape=1) +
  labs(y="reward",x="iteration") + 
  labs(title=paste("Cumulative Reward - ",failing_methods[failed_method]));


#Which question gave the more regrets?
ggplot(sampled_df,aes(y=Answer.regret, x=Question.ID)) + 
  geom_bar(stat="identity") +
  labs(title=paste("Regret per Question - ",failing_methods[failed_method])) +
  labs(x="Question.ID", y="Regret");

#cumulative regret (answers on questions that did not cover bug)
ggplot(sampled_df,aes(Iteration,Cumulative.regret)) + 
  geom_line() +#aes(y=100*precision, colour="precision"))+
  #geom_point(aes(x=answers,y=100*precision), shape=1) +
  labs(y="regret",x="iteration") + 
  labs(title=paste("Cumulative Regret - ",failing_methods[failed_method]));


#--------------------
#Plot reward and answers side-by-side
df_agg_QID <-  data.frame(table(sampled_df$Question.ID))
colnames(df_agg_QID) <- c("Question.ID","Count")
df_agg_QID$Type <- "Answers"

colnames(df_agg) <- c("Question.ID","Count")
df_agg$Type <- "Rewards"

answer_reward_df <- data.frame(matrix(nrow=0,ncol=3))
colnames(answer_reward_df) <- c("Question.ID","Count","Type")
answer_reward_df <- rbind(df_agg_QID,df_agg)

ggplot(answer_reward_df,aes(y=Count, x=Question.ID, fill=Type)) + 
  geom_bar(stat="identity",position=position_dodge()) +
  labs(title=paste("Reward and Answer by Question - ",failing_methods[failed_method])) +
  labs(x="Question.ID", y="Count")+
  theme_minimal()+
  scale_fill_brewer(palette="Blues");


#--------------------


#precision and recall
ggplot(accumStatistics,aes(answers)) + 
  geom_line(aes(y=100*mean_precision, colour="precision")) + 
  geom_line(aes(y=100*mean_recall, colour="recall")) + 
  geom_point(aes(x=answers,y=100*mean_precision), shape=1) +
  geom_point(aes(x=answers,y=100*mean_recall), shape=1) + 
  labs(y="%",x="answers") + 
  labs(title =paste("Mean precision, recall: ",failing_methods[failed_method]));
  #scale_x_cntinuous(limits=c(0,40));








