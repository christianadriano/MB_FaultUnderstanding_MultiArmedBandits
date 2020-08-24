"""
Stopping rule based on budget to ask questions.

The stopping rule checks if asking more questions will change the diagnotics, which 
is the ranking of ranking by number of YES.
"""

def compute_markov_inequality(self, question_answers):
    """how to do this for Thompsom sampling (beta distributions)"""
    pass

def compute_probabiity_of_asking_questions(self, questions_list):
    """"how to compute this, maybe I need to hallucinate sampling for each question 
    or do something like experience replay
    """
    pass

def sort_questions_by_probability_of_asking(self, question_list):
    """
    sort questions in descending order of probability of being asked
    """
    pass

def compute_probability_of_permutation(self, top_ranked, candidate_ranked):
    """
    Compute the chances that the top_ranked list will be over taken by
    the candidate_ranked (which is a permutation of the top_ranked)
    1- identify the questions that change positions and the question that was overtaken
    2- for each question that changed position, compute the markov-inequality
    3- for each question that changed position, compute the probability of being asked
    4- multiply 2 and 3 for all questions that move placed
    5- add all terms in 4
    6- return 5 as the probability of a permutation.
    """
    
    pass

 