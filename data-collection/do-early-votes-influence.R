setwd("C:\\Users\\richa\\Documents\\GitHub\\pi-research\\data-collection")
source("functions-pi-analysis.R")


library(jsonlite)
library(RCurl)
library(plyr)


setwd("C:\\Users\\richa\\Documents\\GitHub\\mainnet")

prop = proposals$prop.id[!is.na(proposals$voting_endtime)]
title = "test"

props.df = data.frame(prop, title)

#generate batch file for piparser
#prep.batch(props.df$prop)

#prepare commits and chart
proposal.commits = apply(props.df, 1, function(y) prepare.votes.commits(y['prop'], y['title']))
commits.df <- do.call("rbind", proposal.commits)

#filter out late votes
commits.df = commits.df[commits.df$days_since_start <= 8,]

for(p in proposals$prop.id)
{
  final_yesper = proposals$yesper[proposals$prop.id == p]
  commits.df$final_yesper[commits.df$prop == p] = final_yesper
}

commits.df$yesper_divergence = commits.df$yesper - commits.df$final_yesper

p.yesper.divergence = ggplot(commits.df, aes(x = cumulative.votes, y = yesper_divergence, colour = prop))+
  geom_smooth(se = FALSE)+
  geom_point()

p.yesper.divergence.time = ggplot(commits.df, aes(x = days_since_start, y = yesper_divergence, colour = prop))+
  geom_line()

#define result, for each commit say whether result is same, over or under

commits.df$result = "rejected"
commits.df$result[commits.df$final_yesper > 60] = "approved"

commits.df$currentresult = "rejected"
commits.df$currentresult[commits.df$yesper > 60] = "approved"

commits.df$predicts.result[commits.df$currentresult == commits.df$result] = "Yes"
commits.df$predicts.result[commits.df$currentresult != commits.df$result & commits.df$yesper < 60] = "Under"
commits.df$predicts.result[commits.df$currentresult != commits.df$result & commits.df$yesper > 60] = "Over"


p.predict = ggplot(commits.df, aes(x = commit_num, fill = predicts.result))+
  geom_histogram(bins = max(commits.df$commit_num))

