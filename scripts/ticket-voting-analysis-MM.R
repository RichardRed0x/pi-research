

votes.of.interest = votes.df[votes.df$castvote.token == "82ce113827140caaaf8b5779ab30402d3ed39f1911fdd2e8fa64cf0dc9e09ecb" |  votes.df$castvote.token == "4becbe00bd5ae93312426a8cf5eeef78050f5b8b8430b45f3ea54ca89213f82b" | votes.df$castvote.token == "2eb7ddb29f151691ba14ac8c54d53f6692c1f5e8fe06244edf7d3c33fb440bd9" ,]
tickets.of.interest = votes.of.interest$castvote.ticket

votes.of.tickets.of.interest = votes.df[votes.df$castvote.ticket %in% tickets.of.interest,]

#show a table of prop short name and yes/no breakdown


#first add shortnames
proposals$shortname[proposals$prop.id == "82ce113827140caaaf8b5779ab30402d3ed39f1911fdd2e8fa64cf0dc9e09ecb"] = "MMTantra"
proposals$shortname[proposals$prop.id == "4becbe00bd5ae93312426a8cf5eeef78050f5b8b8430b45f3ea54ca89213f82b"] = "MMGrapefruit"
proposals$shortname[proposals$prop.id == "2eb7ddb29f151691ba14ac8c54d53f6692c1f5e8fe06244edf7d3c33fb440bd9"] = "MMi2"


votoi.df = votes.of.tickets.of.interest
vi.df = votes.of.interest

vi.df$shortname = ""
for(p in unique(vi.df$castvote.token))
{
  shortname = proposals$shortname[proposals$prop.id == p]
  vi.df$shortname[vi.df$castvote.token == p] = shortname
}

vi.df$vote = ""
vi.df$vote[vi.df$castvote.votebit == 2] = "Yes"
vi.df$vote[vi.df$castvote.votebit == 1] = "No"

vi.df$voten = 0
vi.df$voten[vi.df$castvote.votebit == 2] = 1
vi.df$voten[vi.df$castvote.votebit == 1] = -1

#needs a ticket by proposal breakdown df
dcast.v = dcast(vi.df, castvote.ticket ~ shortname, value.var = "vote")

#for the tickets that voted on any MM, how many MM have they voted on? bar chart
names(dcast.v)[names(dcast.v) == 'castvote.ticket'] = "ticket"

dcast.v$mmvotes = 0
for(t in dcast.v$ticket)
{
  dcast.v$mmvotes[dcast.v$ticket == t] = nrow(vi.df[vi.df$castvote.ticket == t,])
}

p.votes.per.ticket = ggplot(dcast.v, aes(x = mmvotes))+
  geom_bar()+
  labs(x = "Number of MM proposals voted on", y = "Number of tickets")

ggsave("number-of-MM-proposals-voted-on.png", width = 7, height = 4)



#breakdown of YNN, YYY, etc.
#facet grid plot with 3 panes, 1 for the tickets that voted yes on each proposal. Within each set, plot the yes and no votes for each proposal
#do it as 3 plots, much easier
i2support = dcast.v[dcast.v$MMi2 == "Yes" & !is.na(dcast.v$MMi2),]
i2support = subset(i2support, select = -c(mmvotes))

m.i2support = melt(i2support, id.vars = "ticket", value.vars = c("MMGrapefruit", "MMi2", "MMTantra"))
m.i2support$value[is.na(m.i2support$value)] = "Did not vote"

p.i2voters = ggplot(m.i2support, aes(x = variable, fill = value))+
  geom_bar(position = "dodge")+
  scale_fill_manual(values = c("#70cbff", "#ed6d47", "#41bf53"))+
  labs(x = "Proposal", y = "Votes", fill = "Vote type", title = "Tickets that voted Yes on i2 Trading")
  
ggsave("tickets-voting-yes-on-i2.png", width = 10, height = 5)

tantrasupport = dcast.v[dcast.v$MMTantra == "Yes" & !is.na(dcast.v$MMTantra),]
tantrasupport = subset(tantrasupport, select = -c(mmvotes))

m.tantrasupport = melt(tantrasupport, id.vars = "ticket", value.vars = c("MMGrapefruit", "MMi2", "MMTantra"))
m.tantrasupport$value[is.na(m.tantrasupport$value)] = "Did not vote"

p.tantravoters = ggplot(m.tantrasupport, aes(x = variable, fill = value))+
  geom_bar(position = "dodge")+
  scale_fill_manual(values = c("#70cbff", "#ed6d47", "#41bf53"))+
  labs(x = "Proposal", y = "Votes", fill = "Vote type", title = "Tickets that voted Yes on Tantra Labs")

ggsave("tickets-voting-yes-on-tantra.png", width = 10, height = 5)

grapefruitsupport = dcast.v[dcast.v$MMGrapefruit == "Yes" & !is.na(dcast.v$MMGrapefruit),]
grapefruitsupport = subset(grapefruitsupport, select = -c(mmvotes))

m.grapefruitsupport = melt(grapefruitsupport, id.vars = "ticket", value.vars = c("MMGrapefruit", "MMi2", "MMTantra"))
m.grapefruitsupport$value[is.na(m.grapefruitsupport$value)] = "Did not vote"

p.grapefruitvoters = ggplot(m.grapefruitsupport, aes(x = variable, fill = value))+
  geom_bar(position = "dodge")+
  scale_fill_manual(values = c("#70cbff", "#ed6d47", "#41bf53"))+
  labs(x = "Proposal", y = "Votes", fill = "Vote type", title = "Tickets that voted Yes on Grapefruit Trading")

ggsave("tickets-voting-yes-on-grapefruit.png", width = 10, height = 5)

#for the tickets that vote Yes on each MM, how many previous proposals have they voted on?
dcast.v$prevotes = 0

prevotes.of.tickets.of.interest = votes.of.tickets.of.interest[votes.of.tickets.of.interest$castvote.token != "82ce113827140caaaf8b5779ab30402d3ed39f1911fdd2e8fa64cf0dc9e09ecb" & votes.of.tickets.of.interest$castvote.token != "4becbe00bd5ae93312426a8cf5eeef78050f5b8b8430b45f3ea54ca89213f82b" & votes.of.tickets.of.interest$castvote.token != "2eb7ddb29f151691ba14ac8c54d53f6692c1f5e8fe06244edf7d3c33fb440bd9",]

for(t in dcast.v$ticket)
{
  dcast.v$prevotes[dcast.v$ticket == t] = nrow(prevotes.of.tickets.of.interest[prevotes.of.tickets.of.interest$castvote.ticket == t,])
}


#for the MM proposals, how did the tickets that votes yes on each proposal vote on the other 2


#number of tickets voting no or yes to everything
novotes = nrow(dcast.v[dcast.v$MMGrapefruit == "No" & dcast.v$MMi2 == "No" & dcast.v$MMTantra == "No" & !is.na(dcast.v$MMGrapefruit) & !is.na(dcast.v$MMTantra) & !is.na(dcast.v$MMi2),])
perno = round((novotes/nrow(dcast.v)*100), 2)

yesvotes = nrow(dcast.v[dcast.v$MMGrapefruit == "Yes" & dcast.v$MMi2 == "Yes" & dcast.v$MMTantra == "Yes" & !is.na(dcast.v$MMGrapefruit) & !is.na(dcast.v$MMTantra) & !is.na(dcast.v$MMi2),])
peryes = round((yesvotes/nrow(dcast.v)*100), 2)

cat(paste(novotes, " tickets (", perno, "%) have voted No on all proposals.", sep=""), file = "MM-oputput.md", sep = '\n')
cat(paste(yesvotes, " tickets (", peryes, "%) have voted Yes on all proposals.", sep=""), file = "MM-oputput.md", sep = '\n', append = TRUE)


#mean number of previous votes of the tickets that voted Yes on each MM prop
pre.grapefruit = mean(dcast.v$prevotes[dcast.v$MMGrapefruit == "Yes"], na.rm = TRUE)
pre.i2 = mean(dcast.v$prevotes[dcast.v$MMi2 == "Yes"], na.rm = TRUE)
pre.tantra = mean(dcast.v$prevotes[dcast.v$MMTantra == "Yes"], na.rm = TRUE)


cat(paste("The tickets that voted Yes to Grapefruit had voted on a mean ", round(pre.grapefruit, 2), " proposals previously.", sep=""), file = "MM-oputput.md", sep = '\n', append = TRUE)
cat(paste("The tickets that voted Yes to i2 Trading had voted on a mean ", round(pre.i2, 2), " proposals previously.", sep=""), file = "MM-oputput.md", sep = '\n', append = TRUE)
cat(paste("The tickets that voted Yes to Tantra Labs had voted on a mean ", round(pre.tantra, 2), " proposals previously.", sep=""), file = "MM-oputput.md", sep = '\n', append = TRUE)

