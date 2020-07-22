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
failed_method <- 1
#questionList <- c(1,4,10,14,20,23,30,32,55,56,57,58,59,72,73,77,84,92,95,97,102,104,115,119,123);
actual_bugs <- c(1,4)+1

#select one bug
answer_df <- answerPopulation_df[answerPopulation_df$FailingMethod==failing_methods[failed_method],]
question_id_list <- unique(answer_df$Question.ID)
first_question_id <- min(question_id_list)

answers_per_question = 20
K = length(question_id_list)  #number of arms (questions) starts with zero.
H = answers_per_question * K #number of iterations (Horizon or budget, total answers obtained)
questions_selected = integer(0);
cumulative_reward_list = integer(H) #one reward for each iteration
accumStatistics<- data.frame(matrix(nrow=0,ncol=5))
colnames(accumStatistics) <- c("precision","recall","sensitivity", "accuracy", "answers");

numbers_of_rewards_1 = integer(K) #k arms or questions
numbers_of_rewards_0 = integer(K)
# These two variables will be put in place in the for loops
total_reward = 0
reward=0

#data frame with the samples of the arms
sampled_df <- data.frame(matrix(nrow = 0,ncol = 4))
colnames(sampled_df) <- c("Question.ID","Answer.reward","Cumulative.reward","Iterations")

#------------------------------------------------------------------
#Call each question once before deciding between explore/exploit
#pull the best arm
for(question in 1:K){
  question_id = question + first_question_id - 1 #Convert back to the Question.ID scale
  answer_id <- trunc(runif(n=1,min=1,max=answers_per_question))
  reward = answer_df[answer_df$Question.ID==question_id,"Answer.reward"][answer_id] #this should done by sampling, not in order.
  if(question==1){
    cumulative_reward_list[question] =  reward;
  }else{
    cumulative_reward_list[question] = cumulative_reward_list[question-1] + reward;
  }
  #store the sample obtained
  sampled_df <- rbind(sampled_df,data.frame("Question.ID"=question,"Answer.reward"=reward,
                                            "Cumulative.reward"=cumulative_reward_list[question],
                                            "Iteration"=question));
  
  #compute precision and recall (will be all Zero)
  predicted_bugs=c(1000,2000)#force all negatives
  statistics_f<- computeStatistics(predicted_bugs,actual_bugs)
  statistics_f$answers <- question
  accumStatistics <- rbind(accumStatistics,statistics_f)
  
  #update believe about its reward distribution
  if (reward == 1) {
    numbers_of_rewards_1[question] = numbers_of_rewards_1[question] + 1
  } else {
    numbers_of_rewards_0[question] = numbers_of_rewards_0[question] + 1
  }
}
#----------------------------------------------------------------

predictedBugs=c(1000,2000)
actualBugs <- actual_bugs
statistics_df <- data.frame(matrix(nrow=1,ncol=5))
colnames(statistics_df)  <- c("precision","recall","sensitivity", "accuracy","answers");

countMatch<- length(match(actualBugs,predictedBugs));
TP <- countMatch;

FP <- abs(countMatch - dim(predictedBugs)[1]);

FN <- abs(countMatch - length(actualBugs));

TN <- 129 - TP - FP - FN;

statistics_df$precision <-  (TP/(TP+FP));
statistics_df$recall <-  (TP/(TP+FN));
statistics_df$sensitivity <- ((TN)/(FP+TN));
statistics_df$accuracy <- ((TN+TP)/(FP+TN+TP+FN));


start = K+1 #because it has already initialized K arms.
#Now look for the best ARM
for (h in start:H) {
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
  
  sampled_df <- rbind(sampled_df,data.frame("Question.ID"=question,"Answer.reward"=reward,
                                            "Cumulative.reward"=cumulative_reward_list[h],
                                            "Iteration"=h))
  #------------------------------
  #Compute precision and recall
  #obtain the total of YES for each question
  df_agg <- aggregate(Answer.reward ~ Question.ID, data=sampled_df, sum)
  #Sort descending
  df_agg_sort <- df_agg[order(df_agg$Answer.reward, decreasing=TRUE),]
  predicted_bugs <- df_agg_sort[1:ranking_top,]$Question.ID
  statistics_f<- computeStatistics(predictedBugs,actualBugs); #change name of computeOutcomes to computeStat
  statistics_f$answers <- dim(sampled_df)[1];
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

#TODO precision recall

#Which question was selected at each step (nice to mark the correct ones)
ggplot(sampled_df,aes(Question.ID)) + 
  geom_histogram(binwidth = 1) +
  labs(title=paste("Answer per Question - ",failing_methods[failed_method])) +
  labs(x="Question.ID", y="Total answers") + 
  scale_x_continuous(breaks=seq(1,K, 1)
                     );

#cumulative rewards (number of YES)
plot(type="l", cumulative_reward_list, xlab="iterations",ylab="reward", main="Cumulative rewards")

ggplot(sampled_df,aes(Iteration,Cumulative.reward)) + 
  geom_line() +#aes(y=100*precision, colour="precision"))+
  #geom_point(aes(x=answers,y=100*precision), shape=1) +
  labs(y="reward",x="iteration") + 
  labs(title=paste("Cumulative Reward - ",failing_methods[failed_method]));
  
accumStatistics_df$precision <- as.numeric(accumStatistics_df$precision)
accumStatistics_df$recall <- as.numeric(accumStatistics_df$recall)

#precision and recall
ggplot(accumStatistics_df,aes(answers)) + 
  geom_line(aes(y=100*precision, colour="precision")) + 
  geom_line(aes(y=100*recall, colour="recall")) + 
  geom_point(aes(x=answers,y=100*precision), shape=1) +
  geom_point(aes(x=answers,y=100*recall), shape=1) + 
  labs(y="%",x="answers") + 
  labs(title =paste("precision, recall by answers",failed_method));





