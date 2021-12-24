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

