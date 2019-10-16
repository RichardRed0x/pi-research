
library(jsonlite)
library(RCurl)
library(plyr)
library(dplyr)

source("functions-pi-analysis.R")

props = read.csv("Decred-proposals-all-augmented.csv", stringsAsFactors = FALSE)

table(props$state)

sprops = props[props$cost <= 1000000,]

decred = read.csv("decred-proposals.csv", stringsAsFactors = FALSE)
decred$approval = round((decred$yes_votes/decred$total_votes)*100, 1)
props$approval = round((props$yes_votes/props$total_votes)*100, 1)

p.decred = ggplot(decred, aes(voter_participation))+
  geom_histogram(bins = 20)+
  xlab("Voter participation %")+
  ylab("Number of proposals")+
  ggtitle("Politeia Proposals")

ggsave("Politeia-proposals-participation.png", width = 9.55, height = 5)

p.approval = ggplot(decred, aes(approval))+
  geom_histogram(bins = 20)+
  xlab("Voter participation %")+
  ylab("Number of proposals")+
  ggtitle("Politeia Proposals")

ggsave("Politeia-proposals-approval.png", width = 9.55, height = 5)


#props per category, fill status

p.domain = ggplot(props)+
  aes(x = domain, fill = domain)+
  geom_bar()+
  labs(x = "Proposal Domain", y = "No. of Proposals")

ggsave("Politeia-proposals-domain.png", width = 9.55, height = 5)

p.domain.status = ggplot(props)+
  aes(x = domain, fill = state)+
  geom_bar()+
  labs(x = "Proposal Domain", y = "No. of Proposals")

ggsave("Politeia-proposals-domain-state.png", width = 9.55, height = 5)


props.noreum = props[props$cost <= 1000000,]
p.cost.duration = ggplot(props.noreum)+
  aes(x = cost, y = duration)+
  geom_point(aes(colour = state))+
  geom_smooth(method = "lm", se = FALSE)+
  labs(x = "Proposal Maximum Cost", y = "Proposal Approximate/Maximum Duration")+
  scale_x_continuous(labels = scales::comma)+
  scale_y_continuous(breaks = c(0, 3, 6, 9, 12))
ggsave("Politeia-proposals-cost-duration.png", width = 9.55, height = 5)  

# bar chart showing cumulative budget of approved proposals per domain
approved.props = props[props$state == "Approved",]

p.domain.costs = ggplot(approved.props)+
  aes(x = domain, fill = domain, y = cost)+
  geom_bar(stat = "sum")+
  labs(x = "Proposal Domain", y = "Cumulative maximum cost of approved proposals")+
  scale_y_continuous(labels = scales::comma)

ggsave("Politeia-proposals-domain-maxcost.png", width = 9.55, height = 5)

props$contractor[props$contractor == "TRUE"] = "Contractor"
props$contractor[props$contractor == "FALSE"] = "Not a Contractor"

# success rates of contractor/non-contractor proposals

sprops = props[props$state != "Live",]
p.status.contractor = ggplot(sprops)+
  aes(x = state, fill = domain)+
  geom_bar()+
  facet_grid(contractor~.)+
  labs(x = "Proposal Outcome", y = "No. of Proposals")


ggsave("Politeia-proposals-contractor-domain.png", width = 9.55, height = 5)


#scatterplot participation x approval, colour = domain, size = cost

vprops = sprops[sprops$state != "Abandoned",]
p.proposals = ggplot(vprops)+
  aes(x = approval, y = ticket_representation, size = cost, colour = domain)+
        geom_point()+
  labs(x = "Approval %", y = "Voter turnout")


ggsave("Politeia-proposals-scatterplot.png", width = 9.55, height = 5)


#scatterplot proposal cost X duration


for(p in props$url)
{
  props$submitted_at[props$url == p] = proposals$published_at_unix[proposals$url == p]
}
props$submitted_at = as.POSIXct(props$submitted_at, origin = "1960-01-01", tz = "GMT")

p.propcomments.time = ggplot(props)+
  aes(x = submitted_at, y = comments, colour = state, size = cost)+
  geom_point()
  
comments.df$starttime = 0
for(p in proposals$prop.id)
{
  df.comments$starttime[df.comments$token == p] = proposals$published_at_unix[proposals$prop.id == p] 
}
df.comments$delay = df.comments$timestamp - df.comments$starttime
df.comments$day = df.comments$delay/(60*60*24)
sdf.comments = df.comments[df.comments$day<=40,]

p.comments.day = ggplot(sdf.comments, aes(day))+
  geom_histogram(bins = 20)+
  labs(y = "Comments", x = "Days after Proposal Published")+
  theme(axis.text=element_text(size=8))

ggsave("Politeia-comment-timing.png", width = 9.55, height = 5)

df.comment.votes$starttime = 0
for(p in proposals$prop.id)
{
  df.comment.votes$starttime[df.comment.votes$token == p] = proposals$published_at_unix[proposals$prop.id == p] 
}
df.comment.votes$delay = df.comment.votes$timestamp - df.comment.votes$starttime
df.comment.votes$day = df.comment.votes$delay/(60*60*24)
sdf.comment.votes = df.comment.votes[df.comment.votes$day<=40,]

p.commentvotes.day = ggplot(sdf.comment.votes, aes(day))+
  geom_histogram(bins = 20)+
  labs(y = "Votes on Comments", x = "Days after Proposal Published")+
  theme(axis.text=element_text(size=8))

ggsave("Politeia-comment-vote-timing.png", width = 9.55, height = 5)

nrow(df.comments[df.comments$day <= 10,])/nrow(df.comments)
nrow(df.comments[df.comments$day <= 5,])/nrow(df.comments)
nrow(df.comments[df.comments$day <= 2,])/nrow(df.comments)

nrow(df.comment.votes[df.comment.votes$day <= 10,])/nrow(df.comment.votes)
nrow(df.comment.votes[df.comment.votes$day <= 5,])/nrow(df.comment.votes)
nrow(df.comment.votes[df.comment.votes$day <= 2,])/nrow(df.comment.votes)


p.participation.time = ggplot(decred.proposals.pi)+
  aes(x = seq, y = ticket_representation)+
  geom_bar(stat = "identity", fill = "#2970FF")+
  geom_point(aes(x = seq, y = ticket_support, colour = Outcome), size = 3)+
  geom_text(aes(label=shortname), position=position_stack(vjust=0.5), angle = 90, size = 4)+
  labs(y = "% of eligible tickets", title = "Decred Politeia proposals - voter participation (bars) and outcomes (points)")+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

ggsave("proposal-participation-and-approval-in-order.png", width = 10, height = 5.625)




