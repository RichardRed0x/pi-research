library(ggplot2)
library(reshape2)

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
