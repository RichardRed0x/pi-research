source("functions-pi-analysis.R")


library(jsonlite)
library(RCurl)
library(plyr)


setwd("mainnet")


#populate full list of proposals and version numbers
prop.id = fetch.proposals()

version = seq(1:length(prop.id))
proposals = data.frame(prop.id, version)
proposals$version = 0
proposals$prop.id = as.character(proposals$prop.id)

proposals$version = apply(proposals, 1, function(y) latest.version(y['prop.id']))

prop.comments = apply(proposals, 1, function(y) get.comments(y['prop.id'], y['version']))

df <- do.call("rbind", prop.comments)
df$comment.uid = paste(df$token, "/comments/", df$commentid, sep="")

df.comments = df[df$action == "add",]
df.comment.votes = df[df$action == "addlike",]


df.comments$score = 0
df.comments$votes = 0
for(p in unique(df.comments$token))
{
  votes = df.comment.votes[df.comment.votes$token == p,]
  comments = unique(votes$commentid)
  for(c in comments)
  {
    relvotes = votes[votes$commentid == c,]
    score = sum(as.numeric(relvotes$vote))
    commentvotes = length(as.numeric(relvotes$vote))
    df.comments$score[df.comments$token == p & df.comments$commentid == c] = score
    df.comments$votes[df.comments$token == p & df.comments$commentid == c] = commentvotes
  }
}


write.csv(df.comments, file = paste("pi-comments.csv", sep=""), row.names = FALSE)
write.csv(df.comment.votes, file = paste("pi-comment-votes.csv", sep=""), row.names = FALSE)



df.comment.votes$vote = as.numeric(df.comment.votes$vote)



#process metadata.txt files
apply(proposals, 1, function(y) process00(y['prop.id'], y['version']))
proposals$updated_at = as.POSIXct(proposals$updated_at_unix, origin="1970-01-01")

apply(proposals, 1, function(y) process02(y['prop.id'], y['version']))
proposals$published_at = as.POSIXct(proposals$published_at_unix, origin="1970-01-01")



#starts breaking down here
eligibletickets = apply(proposals, 1, function(y) process15(y['prop.id'], y['version']))

#humanreadable dates
for(p in proposals$prop.id)
{
  tryCatch({
    proposals$voting_starttime[proposals$prop.id == p] = get.time(proposals$voting_startblock[proposals$prop.id == p])
    proposals$voting_endtime[proposals$prop.id == p] = get.time(proposals$voting_endblock[proposals$prop.id == p])
    assign('proposals', proposals, envir=.GlobalEnv)
    Sys.sleep(1)
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

proposals$voting_startdate = as.POSIXlt(proposals$voting_starttime, origin = "1970-01-01")
proposals$voting_enddate = as.POSIXlt(proposals$voting_endtime, origin = "1970-01-01")

#voting results
prop.votes = apply(proposals, 1, function(y) process.ballot(y['prop.id'], y['version']))
votes.df <- do.call("rbind", prop.votes)


#update proposal comment and voting status
apply(proposals, 1, function(y) update.voting.status(y['prop.id']))


#output pi digest headers
props = c("60adb9c0946482492889e85e9bce05c309665b3438dd85cb1a837df31fbf57fb", "fb8e6ca361c807168ea0bd6ddbfb7e05896b78f2576daf92f07315e6f8b5cd83", "a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f", "c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e", "d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509", "aea224a561cfed183f514a9ac700d68ba8a6c71dfbee71208fb9bff5fffab51d", "5431da8ff4eda8cdbf8f4f2e08566ffa573464b97ef6d6bae78e749f27800d3a")

sapply(props, print.results)


#top recent commenters
recent.comments = df.comments[df.comments$timestamp > 1550533138,]

pubkey = unique(df$publickey)
no.comments = seq(1:length(pubkey))
pk.df = data.frame(pubkey, no.comments)

for(pk in pk.df$pubkey)
{
  relcomments = recent.comments[recent.comments$publickey == pk,]
  
  pk.df$no.comments[pk.df$pubkey == pk] = nrow(recent.comments[recent.comments$publickey == pk,])
  pk.df$comments.score[pk.df$pubkey == pk] = sum(recent.comments$score[recent.comments$publickey == pk]) 
}

write.csv(pk.df, file = "recent-commenters.csv", row.names = FALSE)

df.comments[df.comments$publickey == "2323bc09222c6f68ed63c96da24bc735d3b5b4bca674714b0130fedebe7e29e7",][1,]


#plot votes over time for a selection of proposals

#list of proposals

#script to run the piparser for each proposal
for(p in props.df$prop){print(paste("python vote_analysis.py ", p, sep=""))}




#plotting voting activity over time
#fetch and combine commits for all proposals

prop = c("a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f", "c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e", "d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509")
title = c("Tutorial-vids", "2019-Marketing", "2019-Events")

props.df = data.frame(prop, title)



proposal.commits = apply(props.df, 1, function(y) prepare.votes.commits(y['prop'], y['title']))
commits.df <- do.call("rbind", proposal.commits)

commits.df$datetime = as.POSIXct(commits.df$timestamp,  origin="1970-01-01")

plot.proposals(commits.df, "test")



for(p in props.df$prop){print(paste("python vote_analysis.py ", p, sep=""))}


#function to write a table file with all the statements needed for Pi digest


#New proposals




# produce a text with information that can be used by Journal



non.commenting.voters = df.comment.votes[!df.comment.votes$publickey %in% unique(df.comments$publickey),]


cat(paste("* There are currently ", prettyNum(nrow(df.comments), big.mark = ","), " comments on Politeia proposals from", length(unique(df.comments$publickey)),
          " different users (public keys)."), file = 'journal-pi.md', sep = '\n')
cat(paste("* There are a total of ", prettyNum(nrow(df.comment.votes), big.mark = ","), " up/down votes on comments from ", 
          length(unique(df.comment.votes$publickey)), " different voting users (public keys)."),
          file = 'journal-pi.md', append = T, sep = '\n')
cat(paste("* There have been ", prettyNum(nrow(df.comment.votes[df.comment.votes$vote == 1,]), big.mark = ","), 
          " upvotes (", round((nrow(df.comment.votes[df.comment.votes$vote == 1,])/nrow(df.comment.votes)),1)*100, "%) and ",
          nrow(df.comment.votes[df.comment.votes$vote == -1,]), " downvotes (",
          round((nrow(df.comment.votes[df.comment.votes$vote == -1,])/nrow(df.comment.votes)),1)*100, "%).", sep=""),
          file = 'journal-pi.md', append = T, sep = '\n')
cat(paste("* There are ", length(unique(non.commenting.voters$publickey)),
          " voting users who have never commented, and together they have cast ", nrow(non.commenting.voters), 
          " votes (", round((nrow(non.commenting.voters)/nrow(df.comment.votes))*100, digits = 1), "% of total).", sep=""),
          file = 'journal-pi.md', append = T, sep = '\n')

#print results for Pi digest
sapply(props, print.results)





#journal


#find total users and comments and votes


#find new users comments and votes since time X


#draw voting graphs - first run python vote_analysis.py propid

p.Decredex = plot.votes.yesno("e78bc28631d0e682912e3ece25944481bf978b906ea44b1ed36470c0f48b27fc", "Decredex")
p.Ditto = plot.votes.yesno("27f87171d98b7923a1bd2bee6affed929fa2d2a6e178b5c80a9971a92a5c7f50", "Ditto")
p.bounty = plot.votes.yesno("d33a2667469b56942adf42453def6cc2292325251e4cf791e806939ea9efc9e1", "Bounty")


p.marketing = plot.votes.yesno("c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e", "Marketing 2019")
p.events = plot.votes.yesno("d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509", "Events-2019")
p.tutorials = plot.votes.yesno("a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f", "Tutorial-videos")




#draw charts for a set of props
props = c("60adb9c0946482492889e85e9bce05c309665b3438dd85cb1a837df31fbf57fb", "fb8e6ca361c807168ea0bd6ddbfb7e05896b78f2576daf92f07315e6f8b5cd83", "a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f", "c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e", "d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509")

for(p in props)
{
  if(!exists("commits.df")){
    commits.df = prepare.votes.commits(p)
    }
  if(exists("commits.df")){
    commits.df = rbind(commits.df, prepare.votes.commits(p))
}

  for(p in props)
  {
    if(!exists("yesnovotes.df")){
      yesnovotes.df = prepare.votes.yesno(p)
    }
    if(exists("yesnovotes.df")){
      yesnovotes.df = rbind(yesnovotes.df, prepare.votes.yesno(p))
    }
  }
    
  head(yesnovotes.df)
  
  
  
  prop.votes.yesno = prepare.votes.yesno(props.df$proposal[1])
  for(p in props.df$proposal[2:length(props.df$proposal)])
  {
    t = prepare.votes.yesno(p)
    prop.votes.yesno = rbind(prop.votes.yesno, t)
  }
    


for(proposal in props)
{
  propvotes = read.csv(paste(proposal, "_votes.csv", sep=""), stringsAsFactors = FALSE)
  propvotes$time_since_start = propvotes$timestamp - min(propvotes$timestamp)
  propvotes$prop = proposal
  propcommits = dcast(propvotes, commit_num + prop  +  timestamp + time_since_start ~ vote)
  propcommits$cumulative.yes = cumsum(propcommits$Yes)
  propcommits$cumulative.no = cumsum(propcommits$No)
  propcommits$cumulative.votes = propcommits$cumulative.yes + propcommits$cumulative.no
  propcommits$yesper = propcommits$cumulative.yes/propcommits$cumulative.votes
  propcommits$yesper = propcommits$yesper*100
  propcommits$days_since_start = propcommits$time_since_start/(60*60*24)
  
  
  
  #make a plot showing votes over time
  m.commits.cumvotes = melt(propcommits, id.vars = "days_since_start", measure.vars = c("cumulative.votes"))
  p.cumulative.votes = ggplot(m.commits.cumvotes, aes(x = days_since_start, y = value))+
    geom_bar(stat = "identity")+
    geom_hline(aes(yintercept=8192))+
    labs(x = "", y = "Cumulative votes", title = paste("Proposal: ", name, sep=""))
  
  #show approval % over time
  p.approval = ggplot(propcommits, aes(x = days_since_start, y = yesper))+
    geom_line(size = 1.1, colour = "blue")+
    ylim(0,100)+
    geom_hline(yintercept = 60)+
    labs(x = "", y = "Percentage Yes votes")
  
  #show votes per commit (not cumulative)
  m.commits.yesno = melt(propcommits, id.vars = "days_since_start", measure.vars = c("No", "Yes"))
  p.votes.yesno = ggplot(m.commits.yesno, aes(x = days_since_start, y = value, fill = variable))+
    geom_bar(stat = "identity")+
    labs(fill = "Vote", x = "Days since voting opened", y = "Number of votes cast in hourly commit" )+
    theme(legend.position = c(0.05, 0.93))
  
  ggarrange(p.cumulative.votes,   p.approval, p.votes.yesno, ncol = 1, nrow = 3)
  
  ggsave(paste(name, "-proposal-voting-over-time.png", sep=""),  height = 12, width = 8)
  return(propcommits)
  
  
}


