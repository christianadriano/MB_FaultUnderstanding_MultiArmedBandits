"
ThompsonSampling_RankingYES 

TODO: 
- modularize in functions.
- compute aveage of the statistics per step
- plot % of optimal arm choosen for each step
- clean up plots (only the ones that matter, maybe parameterized)

- substitute cumulative_statistics with answer_df
"

library(ggplot2)

path <- "C://Users//Christian//Documents//GitHub//"

source(paste0(path,"//RL_ContextualBayesianBandits//util//plotBanditResults.R"));
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
#"HIT01_8-1,4,","HIT02_24-10,14","HIT03_6-20,23,30,32",,"HIT04_7-55,56,57,58,59,,","HIT05_35-72,73,77","HIT06_51"-84,92,95","HIT07_33-97,102,104","HIT08_54-115,119,123"

actual_bugs <- c(1,4)

#select one bug
answer_df <- answerPopulation_df[answerPopulation_df$FailingMethod==failing_methods[failed_method],]
question_id_list <- unique(answer_df$Question.ID)
first_question_id <- min(question_id_list)

#Initialize datastructures 
Total_Simulations = 100 #how many times the algorithm will run from scratch
avg_cumulative_rewards = integer(Total_Simulations) #one reward for each iteration
avg_cumulative_regrets = integer(Total_Simulations) #one regret for each time it does not ask a bug covering question
avg_cumulative_statistics <- data.frame(list(precision=0, recall=0, sensitivity=0, accuracy=0, answers=0,mean_precision=0,mean_recall=0));
answers_df <- data.frame(matrix(nrow = 0,ncol = 6)) #data frame with the samples of the arms
colnames(answers_df) <- c("Question.ID","Answer.reward","Cumulative.reward","
                          Answer.regret","Cumulative.regret","Simulation","Iteration")

#Initilize algorithm configurations
percentage_budget = 2
answers_per_question = 20
K = length(question_id_list)  #number of arms (questions) starts with zero.
Horizon = percentage_budget*answers_per_question * K #number of iterations (Horizon or budget, total answers obtained)
questions_selected = integer(0);



for(simulation in 1:Total_Simulations){
  cumulative_rewards = integer(Horizon) #one reward for each iteration
  cumulative_regrets = integer(Horizon) #one regret for each time it does not ask a bug covering question
  
  cumulative_statistics <- data.frame(list(precision=0, recall=0, sensitivity=0, accuracy=0, answers=0,mean_precision=0,mean_recall=0));
  
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
    regret = compute_regret(question_id, actual_bugs);
    if(question==1){
      cumulative_rewards[question] = reward;
      cumulative_regrets[question] = regret;
    }else{
      cumulative_rewards[question] = cumulative_rewards[question-1] + reward;
      cumulative_regrets[question] = cumulative_regrets[question-1] + regret;
    }
    #store the sample obtained
    answers_df <- rbind(answers_df,data.frame("Question.ID"=question,"Answer.reward"=reward,
                                              "Cumulative.reward"=cumulative_rewards[question],
                                              "Answer.regret"=regret,
                                              "Cumulative.regret"=cumulative_regrets[question],
                                              "Simulation"=simulation,
                                              "Iteration"=question)
                        );
    
    #obtain the total of YES for each question
    df_agg <- aggregate(Answer.reward ~ Question.ID, data=answers_df, sum)
    #Sort descending
    df_agg_sort <- df_agg[order(df_agg$Answer.reward, decreasing=TRUE),]
    predicted_bugs <- df_agg_sort[1:ranking_top,]$Question.ID
    statistics_f<- computeStatistics(predicted_bugs,actual_bugs); #change name of computeOutcomes to computeStat
    statistics_f$answers <- dim(answers_df)[1];
    
    cumulative_statistics <- rbind(cumulative_statistics,statistics_f);
    
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
    cumulative_rewards[h] = cumulative_rewards[h-1] + reward;
    regret = compute_regret(question_id,actual_bugs)
    cumulative_regrets[h] = cumulative_regrets[h-1] + regret;
    
    answers_df <- rbind(answers_df,data.frame("Question.ID"=question,"Answer.reward"=reward,
                                              "Cumulative.reward"=cumulative_rewards[h],
                                              "Answer.regret"=regret,
                                              "Cumulative.regret"=cumulative_regrets[h],
                                              "Simulation"=simulation,
                                              "Iteration"=h)
                        );
    #------------------------------
    #Compute precision and recall
    #obtain the total of YES for each question
    df_agg <- aggregate(Answer.reward ~ Question.ID, data=answers_df, sum)
    #Sort descending
    df_agg_sort <- df_agg[order(df_agg$Answer.reward, decreasing=TRUE),]
    predicted_bugs <- df_agg_sort[1:ranking_top,]$Question.ID
    statistics_f<- computeStatistics(predicted_bugs,actual_bugs); #change name of computeOutcomes to computeStat
    statistics_f$answers <- dim(answers_df)[1];
    statistics_f$mean_precision <- compute_incremental_mean(n=dim(cumulative_statistics)[1],
                                                            original_mean=mean(cumulative_statistics$precision),
                                                            new_datapoint=statistics_f$precision)
    
    statistics_f$mean_recall <- compute_incremental_mean(n=dim(cumulative_statistics)[1],
                                                         original_mean=mean(cumulative_statistics$recall),
                                                         new_datapoint=statistics_f$recall)
    
    cumulative_statistics <- rbind(cumulative_statistics,statistics_f);
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
  
  #compute averages
  avg_cumulative_statistics$simulation <- simulation
  avg_cumulative_statistics$precision <- mean(cumulative_statistics$precision)
  avg_cumulative_statistics$recall <- mean(cumulative_statistics$recall)
  avg_cumulative_statistics$sensitivity<- mean(cumulative_statistics$sensitivity)
  avg_cumulative_statistics$accuracy<- mean(cumulative_statistics$accuracy)
  avg_cumulative_statistics$avg_regret <- mean(cumulative_regrets)
  avg_cumulative_statistics$avg_reward <- mean(cumulative_rewards)

}


#Which question gave the higher reward?
ggplot(avg_cumulative_statistics_df,aes(y=avg_regret, x=Question.ID)) + 
  geom_bar(stat="identity") +
  labs(title=paste("Reward per Question - ",failing_methods[failed_method])) +
  labs(x="Question.ID", y="Reward");







