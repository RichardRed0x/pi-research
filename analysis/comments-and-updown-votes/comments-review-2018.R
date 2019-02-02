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


p.commentscore = ggplot(comments, aes(score))+
  geom_histogram(binwidth = 1)+
  labs(x = "Comment Score", y = "Number of Comments")

ggsave("comments-scores.png", height = 5, width = 6)

median(comments$score)

#how many negative and 0 scoring comments
length(comments$score[comments$score == 0])
length(comments$score[comments$score < 0])


#voting for own comment - set a variable
votes$own.comment = FALSE
for(c in votes$cid)
{
votes$comment.owner[votes$cid==c] = comments$publickey[comments$cid == c]
}
votes$own.comment[votes$publickey == votes$comment.owner] = TRUE

#median score by level
median(comments$score[comments$parentid == 0])

mean(comments$score[comments$parentid == 0])
mean(comments$score[comments$parentid > 0])

#proposal outcome and comment intensity graph




#comment levels analysis

comments$level = "Reply to comment"
comments$level[comments$parentid == 0] = "Top-level"
comments$flevel = factor(comments$level, levels = c("Top-level", "Reply to comment"))

t.test(score ~ level, data = comments, alternative =  "two.sided", paired = FALSE)

p.level.effect = ggplot(comments, aes(score))+
  geom_histogram(binwidth = 1)+
  labs(x = "Comment Score", y = "Number of Comments")+
  facet_wrap(~ flevel, nrow = 2)

ggsave("comments-scores-level.png", height = 5, width = 6)





#graph showing no. comments and voting outcome (0-100, with Abandoned being 0) per proposal - are very poor proposals more or less discussed?

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


#plot votes per day
p.day.all = ggplot(s.votes, aes(day))+
  geom_histogram(bins = 20)+
  labs(y = "votes")+
  theme(axis.text=element_text(size=8))
ggsave("votes-by-day.png", height = 2.5, width = 3)


#look at effect of notifications on timing of comment votes?




#calculate % comments/votes made within 1/2/3 days
nrow(comments[comments$day <= 1,])/nrow(comments)
nrow(comments[comments$day <= 2,])/nrow(comments)
nrow(comments[comments$day <= 3,])/nrow(comments)

nrow(votes[votes$day <= 1,])/nrow(votes)
nrow(votes[votes$day <= 2,])/nrow(votes)
nrow(votes[votes$day <= 3,])/nrow(votes)


