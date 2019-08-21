library(ggplot2)
library(reshape2)


users = read.csv("pi-users.csv", stringsAsFactors = FALSE)


users$prop.negative.votes = users$downvotes/users$votes
users$prop.negative.votes[is.na(users$prop.negative.votes)] = 0

#remove the outlier - bee
users.nobee = users[users$username!="bee",]

#histograms of comments and votes per user, facet_grid
p.comments.hist = ggplot(users.nobee)+
  aes(comments)+
  geom_histogram()+
  labs(x = "Number of comments", y = "Number of users", title = "Politeia Users")+
  theme(text = element_text(size=20))



ggsave("pi-users-comments-histogram.png", width = 10, height = 5.625)



p.votes.hist = ggplot(users.nobee)+
  aes(votes)+
  geom_histogram()+
  labs(x = "Number of votes", y = "Number of users", title = "Politeia Users")+
  theme(text = element_text(size=20))

ggsave("pi-users-votes-histogram.png", width = 10, height = 5.625)


# scatterplot of user votes and comments, color by proportion negative votes


p.scatter = ggplot(users.nobee)+
  aes(comments, votes)+
  geom_point()+
  labs(x = "Number of comments", y = "Number of votes", title = "Politeia Users")+
  theme(text = element_text(size=20))
  

ggsave("pi-users-votes-comments-scatterplot.png", width = 10, height = 5.625)
  
users$actions = users$comments+users$votes
users$voteprop = users$votes/users$actions

nrow(users[users$voteprop<=0.05 | users$voteprop >= 0.95,])
nrow(users[users$voteprop<=0.00 | users$voteprop >= 1,])
nrow(users[users$voteprop<=0.00,])
nrow(users[users$voteprop==1,])
sum(users$votes[users$voteprop==1])

#comment score table

       
















decred.proposals.pi$voting_enddate = as.POSIXct(decred.proposals.pi$voting_enddate  ) 

decred.proposals.pi = decred.proposals.pi[order(decred.proposals.pi$voting_enddate),]
decred.proposals.pi$seq = seq(1:nrow(decred.proposals.pi))
decred.proposals.pi$outcome = "Approved"
decred.proposals.pi$outcome[(decred.proposals.pi$yes_votes/decred.proposals.pi$total_votes) < 0.6] = "Rejected"
decred.proposals.pi$Outcome = factor(decred.proposals.pi$outcome, levels = c("Rejected", "Approved"))

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
