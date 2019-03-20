require(vcd)
require(MASS)

#define set of dummy proposals
yes = seq(from = 4000, to = 10000, by = 100)
no = seq(from = 0, to = 6000, by = 100)
yesno = expand.grid(yes, no)

yesno$yes = as.numeric(yesno$Var1)
yesno$no = as.numeric(yesno$Var2)

yesno$total.votes = yesno$yes + yesno$no
yesno$approval = (yesno$yes/yesno$total.votes)*100

#define quorum thresholds and classify dummy props
yesno$current = "Quorum not met"
yesno$current[yesno$total.votes > 8192] = "Quorum met"

yesno$yes12 = "Quorum not met"
yesno$yes12[yesno$yes > 4915] = "Quorum met"

yesno$yes16 = "Quorum not met"
yesno$yes16[yesno$yes > 6554] = "Quorum met"

yesno$yes20 = "Quorum not met"
yesno$yes20[yesno$yes > 8192] = "Quorum met"

yesno$current[yesno$approval < 60] = "Approval not met"
yesno$yes12[yesno$approval < 60] = "Approval not met"
yesno$yes16[yesno$approval < 60] = "Approval not met"
yesno$yes20[yesno$approval < 60] = "Approval not met"


yesno.m = melt(yesno, id.vars = c("yes", "no"), measure.vars = c("current", "yes12", "yes16", "yes20"))

p.yesno = ggplot(yesno.m, aes(x = no, y = yes, colour = value) )+
  facet_grid(variable ~ .)+
  geom_point(size = 0.2)+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")

ggsave("simulated-proposal-outcomes-4-scenarios.png", width = 6, height = 12, dpi = 500)


voted.proposals = proposals[!is.na(proposals$voting_endtime),]

p.proposals.yesno = ggplot(voted.proposals, aes(x = no_votes, y  = yes_votes))+
  geom_point()+
  geom_point(data = yesno, mapping = aes(x = no, y = yes, colour = current))+
  geom_point(data = voted.proposals, aes(x = no_votes, y  = yes_votes))+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")

ggsave("Proposal-outcomes-historic-and-simulated.png", width = 7, height = 5, dpi = 500)
