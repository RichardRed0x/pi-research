library(klaR)
library(RMySQL)



#use eligibletickets to define abstains

# create a data frame for tickets, with columns for each proposal: not eligible, abstained, yes, no


tickets.df = do.call("rbind", eligibletickets)

tickets.df = tickets.df[tickets.df$propid %in% voted.props$prop.id,]

tickets.df.1 = tickets.df[1:250000,]
tickets.df.2 = tickets.df[250001:500000,]
tickets.df.3 = tickets.df[500001:nrow(tickets.df),]

write.csv(tickets.df.1, file = "eligible-tickets-1.csv", col.names = FALSE, row.names = FALSE)
write.csv(tickets.df.2, file = "eligible-tickets-2.csv", col.names = FALSE, row.names = FALSE)
write.csv(tickets.df.3, file = "eligible-tickets-3.csv", col.names = FALSE, row.names = FALSE)

votes.df = votes.df[votes.df$castvote.token %in% voted.props$prop.id,]

votes.df$vote = "No"
votes.df$vote[votes.df$castvote.votebit == 2] = "Yes"
votes.df$prop.id = votes.df$castvote.token
votes.df$ticket.id = votes.df$castvote.ticket

votes.df.clean = subset(votes.df, select = c(prop.id, ticket.id, vote))
write.csv(votes.df.clean, file = "ticket-votes-first17.csv", row.names = FALSE)

update.votes.table = function(proposal){
  propvotes = read.csv(paste(proposal, "_votes.csv", sep=""), stringsAsFactors = FALSE)
  propvotes$time_since_start = propvotes$timestamp - min(propvotes$timestamp)
  propvotes$prop.id = proposal
  colnames(propvotes)[colnames(propvotes)=="ticket"] <- "ticket.id"
  
  dbWriteTable(con, "votes_piparser", propvotes, append = TRUE, row.names = F)
}

#sapply(voted.props$prop.id, update.votes.table)

#join group by statements
# from votes_piparser group by ticket.id count total and yes and mean and sd for time-since_start
# from eligible group by ticket.id and count number of eligible props


tickets_eligible = dbGetQuery(con, "SELECT ticket_id, count(ticket_id) AS eligible FROM eligible GROUP BY ticket_id;")
tickets_voted = dbGetQuery(con, "SELECT ticket_id, 
								count(ticket_id) AS votes,
                           avg(time_since_start) AS mean_time_since_start,
                           stddev(time_since_start) AS sd_time_since_start
                           FROM votes_piparser GROUP BY ticket_id ;")


tickets = merge(tickets_eligible, tickets_voted, by = "ticket_id", all.x = TRUE)
tickets$votes[is.na(tickets$votes)] = 0

tickets$vote_proportion = tickets$votes/tickets$eligible

tickets$vote_proportion = tickets$vote_proportion*100

p.ticket.voting.proportion = ggplot(tickets, aes(x = vote_proportion))+
  geom_histogram(bins = 20)+
  xlab("Percentage of eligible proposals voted on")+
  ylab("Number of tickets")

ggsave("ticket-voting-on-eligible-proposals.png", height = 4, width = 6)

nrow(tickets)
nrow(tickets[tickets$vote_proportion == 0,])/nrow(tickets)
nrow(tickets[tickets$vote_proportion == 100,])/nrow(tickets)
nrow(tickets[tickets$vote_proportion < 100 & tickets$vote_proportion > 0,])/nrow(tickets)




