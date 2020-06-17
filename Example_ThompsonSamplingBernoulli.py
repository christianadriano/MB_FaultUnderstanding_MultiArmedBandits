from thompson_sampling.bernoulli import BernoulliExperiment

experiment = BernoulliExperiment(arms=2)
from thompson_sampling.bernoulli import BernoulliExperiment
from thompson_sampling.priors import BetaPrior

pr = BetaPrior()
pr.add_one(mean=0.5, variance=0.2, effective_size=10, label="option1")
pr.add_one(mean=0.6, variance=0.3, effective_size=30, label="option2")
experiment = BernoulliExperiment(priors=pr)

experiment.choose_arm()

#Update rewards
rewards = [{"label":"option1", "reward":1}, {"label":"option2", "reward":0}]
experiment.add_rewards(rewards)