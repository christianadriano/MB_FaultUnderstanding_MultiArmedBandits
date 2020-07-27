"
Plot results from Bandit Algorithms

"

#-------------------------------------------------------------------------
#Plots: selected questions, cumulative reward, cumulative regret, precision recall.

plot_results <- function(sampled_df, accumStatistics){
  
  #Which question was selected at each step (nice to mark the correct ones)
  ggplot(sampled_df,aes(Question.ID)) + 
    geom_histogram(binwidth = 1) +
    labs(title=paste("Answer per Question - ",failing_methods[failed_method])) +
    labs(x="Question.ID", y="Total answers") + 
    scale_x_continuous(breaks=seq(1,K, 1)
    );
  #Which question gave the higher reward?
  ggplot(sampled_df,aes(y=Answer.reward, x=Question.ID)) + 
    geom_bar(stat="identity") +
    labs(title=paste("Reward per Question - ",failing_methods[failed_method])) +
    labs(x="Question.ID", y="Reward");
  
  #cumulative rewards (number of YES)
  ggplot(sampled_df,aes(Iteration,Cumulative.reward)) + 
    geom_line() +
    labs(y="reward",x="iteration") + 
    labs(title=paste("Cumulative Reward - ",failing_methods[failed_method]));
  
  #Which question gave the more regrets?
  ggplot(sampled_df,aes(y=Answer.regret, x=Question.ID)) + 
    geom_bar(stat="identity") +
    labs(title=paste("Regret per Question - ",failing_methods[failed_method])) +
    labs(x="Question.ID", y="Regret");
  
  #cumulative regret (answers on questions that did not cover bug)
  ggplot(sampled_df,aes(Iteration,Cumulative.regret)) + 
    geom_line() +
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
  
}
