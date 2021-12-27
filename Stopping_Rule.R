"
Stopping Rule

Compute the chances that the top_ranked list will be over taken by
the candidate_ranked (which is a permutation of the top_ranked)

There are two types of stopping rule: budget-based and confidence-based

Budget-based assumes that there is maximum of times that arms can be pulled, 
either total pulls across all arms or a maximum pulls per arm. These rules 
correspond respectively to the functions stop_by_total_budget and
stop_by_arm_budget.

The confidence-based stopping rule assumes a minimum threshold probability that
the top arms will change. The change could be either (1) a reshuffling of the arms 
(i.e., generating a new permutation with the same arms) or (2) a replacement of any of the
top arms (i.e., one or more arms being supplanted by other arms w.r.t. their reward).
The parameterization of these two types of confidence rules 
require the number of top arms to consider and the threshold. The functions
implementing these rules correspond to stop_confident_reshuffle and
stop_confident_replacement
"

"Generates permutations of the elements of x
source: https://stackoverflow.com/questions/11095992/generating-all-distinct-permutations-of-a-list-in-r
"
generate_permutations <- function(x) {
  if (length(x) == 1) {
    return(x)
  }
  else {
    res <- matrix(nrow = 0, ncol = length(x))
    for (i in seq_along(x)) {
      res <- rbind(res, cbind(x[i], Recall(x[-i])))
    }
    return(res)
  }
}

"
Compute distance in terms of samples from each permutation and 
the current ranking_top. The distance is in how many sampled answers
are necessary for the original become the permutations.
"
compute_min_max_distance <- function(permutation,current_top){
  "the trick here is what is the minimum number of yes answers
  necessary to be added to transform current_top -> permutation.
  Can I use the Wasserstein distance for that?
  
  1- check which item change position. If it did not change, then keeps same number of answers
  2- for the ones that changed position, find the lowest one
  3- compute the difference between the changed position and the antecedent. Add difference +1
  4- save the information of how many extra answers for that item
  5- go the the next up in the ranking an repeat 3 until end of ranking
  
  
  Note that these addition of answers assumes optimistically that all items have
  equal chance of receiving a positive answer that has high accuracy. Realistically, 
  we knwo that certain questions have lower chances than others of obtaining a 
  positive and high accurate answer. However, this would make the algorithm 
  more pessimistic, i.e., allow for ealier stopping. This is not what we are 
  aiming at, i.e., we want min max solution. Miminum number of answers that would
  cause a maximum change in the ranking.
  "
}

"
Determines if should stop or not given the remaining budget.
 budget: how many samples could still be drawn
 top: how many arms are considered at the top
 ranking: the current ranking of arms
"
stop_budget <- function(budget,top_m, ranking){
  stop <- stop_permutation(budget,top_m, ranking)
  "pseudo-code if the "
  
}

stop_confidence <- function(confidence,ranking){}

