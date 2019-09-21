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


yesno$score = yesno$yes - yesno$no
yesno$score12 = "Quorum not met"
yesno$score12[yesno$score > 4915] = "Quorum met"
yesno$score12[yesno$approval < 60] = "Approval not met"

yesno.m = melt(yesno, id.vars = c("yes", "no"), measure.vars = c("current", "yes12", "yes16", "yes20", "score12"))

p.yesno = ggplot(yesno.m, aes(x = no, y = yes, colour = value) )+
  facet_grid(variable ~ .)+
  geom_point(size = 0.2)+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")

ggsave("simulated-proposal-outcomes-4-scenarios.png", width = 6, height = 12, dpi = 500)

p.yesno.1 = ggplot(yesno.m[yesno.m$variable == "current",], aes(x = no, y = yes, colour = value) )+
  geom_point(size = 0.3)+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")+
  theme(legend.position="bottom")+
  ggtitle("20% Yes/No votes")

p.yesno.2 = ggplot(yesno.m[yesno.m$variable == "yes12",], aes(x = no, y = yes, colour = value) )+
  geom_point(size = 0.3)+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")+
  ggtitle("12% Yes votes")

p.yesno.3 = ggplot(yesno.m[yesno.m$variable == "yes16",], aes(x = no, y = yes, colour = value) )+
  geom_point(size = 0.3)+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")+
  ggtitle("16% Yes votes")

p.yesno.4 = ggplot(yesno.m[yesno.m$variable == "yes20",], aes(x = no, y = yes, colour = value) )+
  geom_point(size = 0.3)+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")+
  ggtitle("20% Yes votes")

p.yesno.5 = ggplot(yesno.m[yesno.m$variable == "score12",], aes(x = no, y = yes, colour = value) )+
  geom_point(size = 0.3)+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")+
  ggtitle("12% Yes-No score")

g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

mylegend<-g_legend(p.yesno.1)


p.yesno.square = grid.arrange(p.yesno.1, p.yesno.2, p.yesno.3, p.yesno.4, nrow = 2)

p.yesno.square = grid.arrange(arrangeGrob(p.yesno.1 + theme(legend.position = "none"), 
                                          p.yesno.2 + theme(legend.position = "none"),
                                          p.yesno.3 + theme(legend.position = "none"),
                                          p.yesno.4 + theme(legend.position = "none"),
                                          nrow = 2),
                              mylegend, nrow=2,heights=c(10, 1))

mylegend2<-g_legend(p.yesno.2)
p.yesno.rectangle = grid.arrange(arrangeGrob(p.yesno.1 + theme(legend.position = "none"), 
                                          p.yesno.2 + theme(legend.position = "none"),
                                          p.yesno.3 + theme(legend.position = "none"),
                                          p.yesno.4 + theme(legend.position = "none"),
                                          p.yesno.5 + theme(legend.position = "none"),
                                          mylegend2,
                                          nrow = 3)
                                 )



ggsave("simulated-proposal-outcomes-5-scenarios.png", plot = p.yesno.rectangle, width = 7, height = 10.5, dpi = 500)


voted.proposals = proposals[!is.na(proposals$voting_endtime),]

p.proposals.yesno = ggplot(voted.proposals, aes(x = no_votes, y  = yes_votes))+
  geom_point()+
  geom_point(data = yesno, mapping = aes(x = no, y = yes, colour = current))+
  geom_point(data = voted.proposals, aes(x = no_votes, y  = yes_votes))+
  labs(colour = "Outcome", x = "No votes", y = "Yes votes")

ggsave("Proposal-outcomes-historic-and-simulated.png", width = 7, height = 5, dpi = 500)
