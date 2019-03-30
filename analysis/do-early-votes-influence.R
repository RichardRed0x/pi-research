
source("functions-pi-analysis.R")


library(jsonlite)
library(RCurl)
library(plyr)


setwd("C:\\Users\\richa\\Documents\\GitHub\\mainnet")

prop = proposals$prop.id[!is.na(proposals$voting_endtime)]
title = "test"

props.df = data.frame(prop, title)

voted.props = proposals[!is.na(proposals$voting_endtime),]

#prepare commits and chart
proposal.commits = apply(voted.props, 1, function(y) prepare.votes.commits(y['prop.id'], y['name']))
commits.df <- do.call("rbind", proposal.commits)

#filter out late votes
commits.df = commits.df[commits.df$days_since_start <= 7.2,]


commits.df$new_votes = commits.df$Yes+commits.df$No

#make a df which goes up in 0.2 increments of days_since and for each interval sums all the new_votes

interval_from = seq(from = 0, to = 8, by = 0.5)
interval_to = seq(from = 0.5, to = 8.5, by = 0.5)
newvotes = seq(1:length(interval_from))
interval.votes = data.frame(interval_from, interval_to, newvotes)

for(i in interval.votes$interval_from)
{
  interval_to = interval.votes$interval_to[interval.votes$interval_from == i] 
  interval.votes$newvotes[interval.votes$interval_from == i] = sum(commits.df$new_votes[commits.df$days_since_start > i & commits.df$days_since_start <= interval_to])
}

p.interval.votes = ggplot(interval.votes, aes(x = interval_to, y = newvotes))+
  geom_bar(stat = "identity")+
  labs(x = "Day of voting period - 12 hour intervals", y = "New votes cast in this period")

ggsave(file = "timing-of-proposal-ticket-votes.png", width = 6, height = 4)

sum(commits.df$new_votes[commits.df$days_since_start <= 2.5])/sum(commits.df$new_votes)
sum(commits.df$new_votes[commits.df$days_since_start > 2.5 & commits.df$days_since_start<= 5])/sum(commits.df$new_votes)
sum(commits.df$new_votes[commits.df$days_since_start > 5])/sum(commits.df$new_votes)

#tack on "final 3rd" variables for proposals

for(p in voted.props$prop.id)
{
  relrows = commits.df[commits.df$prop == p & commits.df$days_since_start <= 5,]
  futurerows = commits.df[commits.df$prop == p & commits.df$days_since_start > 5,]
  relrow = relrows[nrow(relrows),]
  voted.props$fin3.approval[voted.props$prop.id == p] = relrow$yesper
  voted.props$fin3.existingvotes[voted.props$prop.id == p] = relrow$cumulative.votes
  voted.props$fin3.newyes[voted.props$prop.id == p] = sum(futurerows$Yes)
  voted.props$fin3.newno[voted.props$prop.id == p] = sum(futurerows$No)
}

voted.props$fin3.newvotes = voted.props$fin3.newno + voted.props$fin3.newyes
voted.props$fin3.metquorum = "No"
voted.props$fin3.metquorum[voted.props$fin3.existingvotes > 8192] = "Yes"

voted.props$fin3.approval.close = "No"
voted.props$fin3.approval.close[voted.props$fin3.approval >= 45 & voted.props$fin3.approval <= 75] = "Yes"

voted.props$fin3.approval.distance = voted.props$fin3.approval - 60
voted.props$fin3.approval.distance = abs(voted.props$fin3.approval.distance)


fin3.p1 = glm(fin3.newvotes~ fin3.approval.close + fin3.metquorum, data = voted.props, family = poisson)
fin3.p2 = glm(fin3.newvotes~ fin3.approval.distance + fin3.metquorum, data = voted.props, family = poisson)
fin3.p3 = glm(fin3.newvotes~ fin3.metquorum * fin3.approval.distance, data = voted.props, family = poisson)


#try "final 2 thirds"
for(p in voted.props$prop.id)
{
  relrows = commits.df[commits.df$prop == p & commits.df$days_since_start <= 2.5,]
  futurerows = commits.df[commits.df$prop == p & commits.df$days_since_start > 2.5,]
  relrow = relrows[nrow(relrows),]
  voted.props$fin2.approval[voted.props$prop.id == p] = relrow$yesper
  voted.props$fin2.existingvotes[voted.props$prop.id == p] = relrow$cumulative.votes
  voted.props$fin2.newyes[voted.props$prop.id == p] = sum(futurerows$Yes)
  voted.props$fin2.newno[voted.props$prop.id == p] = sum(futurerows$No)
}

voted.props$fin2.newvotes = voted.props$fin2.newno + voted.props$fin2.newyes
voted.props$fin2.metquorum = "No"
voted.props$fin2.metquorum[voted.props$fin2.existingvotes > 8192] = "Yes"

voted.props$fin2.approval.close = "No"
voted.props$fin2.approval.close[voted.props$fin2.approval >= 45 & voted.props$fin2.approval <= 75] = "Yes"

voted.props$fin2.approval.distance = voted.props$fin2.approval - 60
voted.props$fin2.approval.distance = abs(voted.props$fin2.approval.distance)

fin2.m1 = lm( fin2.newvotes~ fin2.approval.close * fin2.metquorum, voted.props)

fin2.m2 = lm( fin2.newvotes~ fin2.approval.distance , voted.props)


#make variables to fill by approval (50-70 or outside) and quorum (above/below) seperately, for seperate plots





#divergence from final score
for(p in voted.proposals$prop.id)
{
  propcommits = commits.df[commits.df$prop == p,]
  final_yesper =  propcommits$yesper[nrow(propcommits)]
  commits.df$final_yesper[commits.df$prop == p] = final_yesper
}

commits.df$yesper_divergence = commits.df$yesper - commits.df$final_yesper

p.yesper.divergence = ggplot(commits.df, aes(x = cumulative.votes, y = yesper_divergence, colour = prop))+
  geom_smooth(se = FALSE, size = 0.1)+
  geom_point(size = 0.6)+
  theme(legend.position = "none")+
  xlab("Cumulative number of votes cast at commit")+
  ylab("Approval % distance from final result")
  
ggsave("distance-from-final-outcome-by-votes-cast.png", width = 10, height = 5)  

#how many props were within 10% of final core after 5000 votes?

unique(commits.df$prop[commits.df$cumulative.votes >= 5000 & (commits.df$yesper_divergence < -10 | commits.df$yesper_divergence > 10)])



p.yesper.divergence.time = ggplot(commits.df, aes(x = days_since_start, y = yesper_divergence, colour = prop))+
  geom_line()

#define result, for each commit say whether result is same, over or under

commits.df$result = "rejected"
commits.df$result[commits.df$final_yesper > 60] = "approved"

commits.df$currentresult = "rejected"
commits.df$currentresult[commits.df$yesper > 60] = "approved"

commits.df$predicts.result[commits.df$currentresult == commits.df$result] = "Correct"
commits.df$predicts.result[commits.df$currentresult != commits.df$result & commits.df$yesper < 60] = "Under"
commits.df$predicts.result[commits.df$currentresult != commits.df$result & commits.df$yesper > 60] = "Over"
commits.df$predicts.result = factor(commits.df$predicts.result, levels = c("Correct", "Under", "Over"))

p.predict = ggplot(commits.df, aes(x = commit_num, fill = predicts.result))+
  geom_histogram(bins = max(commits.df$commit_num))+
  scale_fill_manual(values=c("Green", "Blue", "Red"))+
  ylab("Commit number")+xlab("Number of proposals")

ggsave("tally-at-commit-x-predicts-result.png", width = 6, height = 4)


