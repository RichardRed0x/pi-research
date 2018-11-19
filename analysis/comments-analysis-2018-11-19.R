library(ggplot2)

comments = read.csv("pi-comments.csv", stringsAsFactors = FALSE)
votes = read.csv("pi-comment-votes.csv", stringsAsFactors = FALSE)

#how many comments and votes
nrow(comments)
nrow(votes)

#how many contributors
length(unique(df$publickey))
length(unique(comments$publickey))
length(unique(votes$publickey))


#% downvotes
nrow(votes[votes$vote == -1,])/(nrow(votes[votes$vote == -1,])+nrow(votes[votes$vote == 1,]))


#add a unique ID for comments
comments$cid = paste(comments$prop.title, comments$commentid, sep="-")
votes$cid = paste(votes$prop.title, votes$commentid, sep="-")


#voting for own comment - set a variable
votes$own.comment = FALSE
for(c in votes$cid)
{
votes$comment.owner[votes$cid==c] = comments$publickey[comments$cid == c]
}
votes$own.comment[votes$publickey == votes$comment.owner] = TRUE


#voting rate by day after first comment - can show events like edits and voting start time

#set a start time, to the earliest comment
comments$starttime = 0
for(p in unique(comments$token))
{
  relcomments = comments[comments$token == p,]
  comments$starttime[comments$token == p] = min(relcomments$timestamp)
}

comments$delay = comments$timestamp - comments$starttime
comments$day = comments$delay/(60*60*24)

#same for votes
votes$starttime = 0
for(p in unique(votes$token))
{
  relvotes = votes[votes$token == p,]
  votes$starttime[votes$token == p] = min(relvotes$timestamp)
}
votes$delay = votes$timestamp - votes$starttime
votes$day = votes$delay/(60*60*24)

#remove late DCC comment outliers, set max to 20 days
s.comments = comments[comments$day <= 20,]
s.votes = votes[votes$day <= 20,]

#plot comments per day
p.day.all = ggplot(comments, aes(day))+
  geom_histogram(bins = 20)+
  labs(y = "comments")+
  theme(axis.text=element_text(size=8))
ggsave("comments-by-day.png", height = 2.5, width = 3)

p.day.prop = ggplot(s.comments, aes(day))+
  geom_histogram(bins = 20)+
  facet_grid(prop.title~.)+
  labs(y = "comments")+
  theme(axis.text=element_text(size=5))+
  theme(axis.title=element_text(size=8))+
  theme(strip.text=element_text(size=7) )
ggsave("comments-by-day-by-proposal.png", height = 6, width = 3)

#plot votes per day
p.day.all = ggplot(s.votes, aes(day))+
  geom_histogram(bins = 20)+
  labs(y = "votes")+
  theme(axis.text=element_text(size=8))
ggsave("votes-by-day.png", height = 2.5, width = 3)

p.day.prop = ggplot(s.votes, aes(day))+
  geom_histogram(bins = 20)+
  facet_grid(prop.title~.)+
  labs(y = "votes")+
  theme(axis.text=element_text(size=5))+
  theme(axis.title=element_text(size=8))+
  theme(strip.text=element_text(size=7) )
ggsave("votes-by-day-by-proposal.png", height = 8, width = 4)


#comments and votes per pubkey
pubkey = unique(df$publickey)
no.comments = seq(1:length(pubkey))
no.votes =  seq(1:length(pubkey))
pk.df = data.frame(pubkey, no.comments,no.votes)

for(pk in pk.df$pubkey)
{
  relcomments = comments[comments$publickey == pk,]
  pk.df$no.comments[pk.df$pubkey == pk] = nrow(comments[comments$publickey == pk,])
  pk.df$no.votes[pk.df$pubkey == pk] = nrow(votes[votes$publickey == pk,])
  pk.df$comments.score[pk.df$pubkey == pk] = sum(comments$score[comments$publickey == pk]) 
}

#scatterplot comments vs votes

cor(pk.df$no.comments, pk.df$no.votes, method = "spearman")

p.comments.votes = ggplot(pk.df, aes(no.comments, no.votes))+
  geom_point()+
  labs(x = "Number of Comments", y = "Number of Votes", title = "Comments and votes per user (public key)")+
  geom_smooth(method='lm',formula=y~x, se = FALSE)

ggsave("comments-votes-per-pubkey.png", height = 4, width = 5)


#calculate % comments/votes made within 1/2/3 days
nrow(comments[comments$day <= 1,])/nrow(comments)
nrow(comments[comments$day <= 2,])/nrow(comments)
nrow(comments[comments$day <= 3,])/nrow(comments)

nrow(votes[votes$day <= 1,])/nrow(votes)
nrow(votes[votes$day <= 2,])/nrow(votes)
nrow(votes[votes$day <= 3,])/nrow(votes)


