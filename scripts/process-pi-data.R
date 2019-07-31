
library(jsonlite)
library(RCurl)
library(plyr)
library(dplyr)




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





#process metadata.txt files
x = apply(proposals, 1, function(y) process00(y['prop.id'], y['version']))
proposals$updated_at = as.POSIXct(proposals$updated_at_unix, origin="1970-01-01")

x = apply(proposals, 1, function(y) process02(y['prop.id'], y['version']))
proposals$published_at = as.POSIXct(proposals$published_at_unix, origin="1970-01-01")


#update df to add username column



#create a data.frame which links usernames to public keys - this is time consuming and needs a function to pull the already collected data and seek updates
pubkey = unique(df$publickey)  
username = seq(1:length(pubkey))
keynames = data.frame(pubkey, username)  


#for(pk in keynames$pubkey)
#{
#  keynames$username[keynames$pubkey == pk] = process.pubkey(pk)
#}
#write.csv(keynames, file = "pi-user-keys-names.csv", row.names = FALSE)

keynames = read.csv("pi-user-keys-names.csv", stringsAsFactors = FALSE)

for(pk in df$publickey)
{
  df$username[df$publickey == pk] = keynames$username[keynames$pubkey == pk]
  
}


df.comments = df[df$action == "add",]
df.comment.votes = df[df$action == "addlike",]


#how to treat duplicate or cancelling up/down votes?

#make a crosstab of comment.uid and username, all rows with freq > 1 need attention
dupes = df.comment.votes %>%
  group_by(comment.uid, publickey) %>%
  filter(n()>1)

dupes = as.data.frame(dupes)


process.dupedata = function(dupedata){
  for(row in 1:nrow(dupedata)){
    if(row == 1){
      dupedata$running[row] = dupedata$vote[row]
      thisrow = dupedata[row,]
      df.comment.votes = df.comment.votes[!(df.comment.votes$comment.uid == thisrow$comment.uid & df.comment.votes$username == thisrow$username),]
      assign('df.comment.votes', df.comment.votes, envir=.GlobalEnv)
      print("removing from main df")
    }
    else if(row == nrow(dupedata))
       {
      prevrow = dupedata[row - 1,]
      thisrow = dupedata[row,]
      if(prevrow$running == thisrow$vote){
        dupedata$running[row] = 0
      }
      if(prevrow$running != thisrow$vote){
        dupedata$running[row] = thisrow$vote
      }      
          
         if(dupedata$running[row] != 0)
         {
           #add one appropriate row to the main df, if required
           thisrow = dupedata[row,]
           thisrow$vote = thisrow$running
           thisrow = data.frame(thisrow)
           thisrow = subset(thisrow, select = -c(running) )
           df.comment.votes = rbind(df.comment.votes, thisrow)
           print("added row to df")
           assign('df.comment.votes', df.comment.votes, envir=.GlobalEnv)
         }
    }
    else if(row > 1 & row != nrow(dupedata)){
      prevrow = dupedata[row - 1,]
      thisrow = dupedata[row,]
      if(prevrow$running == thisrow$vote){
        dupedata$running[row] = 0
      }
      if(prevrow$running != thisrow$vote){
        dupedata$running[row] = thisrow$vote
      }
    }
  }
}


for(c in unique(dupes$comment.uid))
{
  commentdata = dupes[dupes$comment.uid == c,]
  for(u in unique(commentdata$username))
  {
    dupedata = commentdata[commentdata$username == u,]
    process.dupedata(dupedata)
  }
}

df.comments$score = 0
df.comments$votes = 0
df.comments$upvotes = 0
df.comments$downvotes = 0
df.comments$selfvotes = 0
for(p in unique(df.comments$token))
{
  votes = df.comment.votes[df.comment.votes$token == p,]
  comments = unique(votes$commentid)
  for(c in comments)
  {
    commentowner = df.comments$username[df.comments$token == p & df.comments$commentid == c]
    relvotes = votes[votes$commentid == c,]
    score = sum(as.numeric(relvotes$vote))
    commentvotes = length(as.numeric(relvotes$vote))
    commentupvotes = length(as.numeric(relvotes$vote[relvotes$vote == 1]))
    commentdownvotes = length(as.numeric(relvotes$vote[relvotes$vote == -1]))
    commentselfvotes = sum(as.numeric(relvotes$vote[relvotes$username == commentowner]))
    df.comments$score[df.comments$token == p & df.comments$commentid == c] = score
    df.comments$votes[df.comments$token == p & df.comments$commentid == c] = commentvotes
    df.comments$upvotes[df.comments$token == p & df.comments$commentid == c] = commentupvotes
    df.comments$downvotes[df.comments$token == p & df.comments$commentid == c] = commentdownvotes
    df.comments$selfvotes[df.comments$token == p & df.comments$commentid == c] = commentselfvotes
  }
}

df.comments$selfvotes[df.comments$selfvotes == 2] = 0
df.comments$selfvotes[df.comments$selfvotes > 2] = 1

#users data

username = unique(df$username)
comments= seq(1:length(username))
upvotes= seq(1:length(username))
downvotes= seq(1:length(username))
commentscore= seq(1:length(username))

users = data.frame(username, comments, upvotes, downvotes, commentscore)

for(u in users$username)
{
  users$comments[users$username == u] = nrow(df.comments[df.comments$username == u,])
  users$upvotes[users$username == u] = nrow(df.comment.votes[df.comment.votes$username == u & df.comment.votes$vote == 1,])
  users$downvotes[users$username == u] = nrow(df.comment.votes[df.comment.votes$username == u & df.comment.votes$vote == -1,])
  users$commentscore[users$username == u] = sum(df.comments$score[df.comments$username == u])
  
}
users$score.per.comment = users$commentscore/users$comments

users$votes = users$upvotes+users$downvotes


proposals$username = ""
users$proposals = 0
for(p in unique(proposals$submitted_by))
{
  username = process.pubkey(p)
  proposals$username[proposals$submitted_by == p] = username
  users$proposals[users$username == username] = nrow(proposals[proposals$submitted_by == p,])
}

users = users[order(users$commentscore, decreasing = TRUE),]
users$score.per.comment = round(users$score.per.comment,2)

write.csv(users, file = "pi-users.csv", row.names = FALSE)




write.csv(df.comments, file = paste("pi-comments.csv", sep=""), row.names = FALSE)
write.csv(df.comment.votes, file = paste("pi-comment-votes.csv", sep=""), row.names = FALSE)

df.comment.votes$vote = as.numeric(df.comment.votes$vote)


#set last comment date
x = apply(proposals, 1, function(y) lastcomment(y['prop.id'], y['version']))


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
x = apply(proposals, 1, function(y) update.voting.status(y['prop.id']))




x = sapply(proposals$prop.id, last.activity)
x = sapply(proposals$prop.id, last.activity.notcomment)



voted.props = proposals[!is.na(proposals$voting_endtime),]


#make export version for crypto-governance-research
voted.props$url = paste("https://proposals.decred.org/proposals/", voted.props$prop.id, sep="")
decred.proposals = subset(voted.props, select = c(name,url,yes_votes,no_votes,total_votes,ticket_representation,voting_startdate, voting_enddate, eligible_tickets ))
decred.proposals$project = "Decred"


names(decred.proposals)[names(decred.proposals) == 'name'] <- 'title'
names(decred.proposals)[names(decred.proposals) == 'ticket_representation'] <- 'voter_participation'

names(decred.proposals)[names(decred.proposals) == 'eligible_tickets'] <- 'eligible_voters'

write.csv(decred.proposals, "Decred-proposals.csv", row.names = FALSE)



voted.props$shortname[voted.props$prop.id == "27f87171d98b7923a1bd2bee6affed929fa2d2a6e178b5c80a9971a92a5c7f50"] = "Ditto 1"
voted.props$shortname[voted.props$prop.id == "2ababdea7da2b3d8312a773d477272135a883ed772ba99cdf31eddb5f261d571"] = "Trust Wallet"
voted.props$shortname[voted.props$prop.id == "34707d34b09c3ebcf0d4aa604e8a08244e8f0f082c0af3f33d85778c93c81434"] = "Easyrabbit"
voted.props$shortname[voted.props$prop.id == "522652954ea7998f3fca95b9c4ca8907820eb785877dcf7fba92307131818c75"] = "Stakepool>VSP"
voted.props$shortname[voted.props$prop.id == "5431da8ff4eda8cdbf8f4f2e08566ffa573464b97ef6d6bae78e749f27800d3a"] = "DEX RFP"
voted.props$shortname[voted.props$prop.id == "60adb9c0946482492889e85e9bce05c309665b3438dd85cb1a837df31fbf57fb"] = "IDAX Exchange"
voted.props$shortname[voted.props$prop.id == "7fe5d07a4ffff7dc6a83383018823d880b1c1db0a29305e74934817cf2b4e2ce"] = "Free Talk Live"
voted.props$shortname[voted.props$prop.id == "950e8149e594b01c010c1199233ab11e82c9da39174ba375d286dc72bb0a54d7"] = "EXMO exchange"
voted.props$shortname[voted.props$prop.id == "a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f"] = "Tutorial videos"
voted.props$shortname[voted.props$prop.id == "aea224a561cfed183f514a9ac700d68ba8a6c71dfbee71208fb9bff5fffab51d"] = "ATM RFP"
voted.props$shortname[voted.props$prop.id == "b9f342a0f917abb7a2ab25d5ed0aca63c06fe6dcc9d09565a9cde3b6fe7e6737"] = "Jeremy's Journey"
voted.props$shortname[voted.props$prop.id == "bc8776180b5ea8f5d19e7d08e9fcc35f0d1e3d16974963e3e5ded65139e7b092"] = "Wachsman"
voted.props$shortname[voted.props$prop.id == "bb7e19283d5c65fed598d5a2f4afcc2b5d2eab187b9cb84fc4304430f80b5ad1"] = "Bcash ATMs"
voted.props$shortname[voted.props$prop.id == "c68bb790ba0843980bb9695de4628995e75e0d1f36c992951db49eca7b3b4bcd"] = "Research 1"
voted.props$shortname[voted.props$prop.id == "c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e"] = "2019 Marketing"
voted.props$shortname[voted.props$prop.id == "c96290a2478d0a1916284438ea2c59a1215fe768a87648d04d45f6b7ecb82c3f"] = "Treasury"
voted.props$shortname[voted.props$prop.id == "d33a2667469b56942adf42453def6cc2292325251e4cf791e806939ea9efc9e1"] = "Bug Bounty 1"
voted.props$shortname[voted.props$prop.id == "d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509"] = "2019 Events"
voted.props$shortname[voted.props$prop.id == "dac06f18bfeb5f7667e56554774de3bb99151018ce16a64f5353bab45819763b"] = "Ghana merchants"
voted.props$shortname[voted.props$prop.id == "e78bc28631d0e682912e3ece25944481bf978b906ea44b1ed36470c0f48b27fc"] = "Decredex"
voted.props$shortname[voted.props$prop.id == "f545b359fcf1b40b356e9cb556cb422cc7ff01b628b577f804cdc45ce414f5dd"] = "Baeond"
voted.props$shortname[voted.props$prop.id == "fa38a3593d9a3f6cb2478a24c25114f5097c572f6dadf24c78bb521ed10992a4"] = "DCC"
voted.props$shortname[voted.props$prop.id == "fb8e6ca361c807168ea0bd6ddbfb7e05896b78f2576daf92f07315e6f8b5cd83"] = "Decredcommunity.org"
voted.props$shortname[voted.props$prop.id == "fd56bb79e0383f40fc2d92f4473634c59f1aa0abda7aabe29079216202c83114"] = "Amendment 1"
voted.props$shortname[voted.props$prop.id == "a4f2a91c8589b2e5a955798d6c0f4f77f2eec13b62063c5f4102c21913dcaf32"] = "DEX Spec"
voted.props$shortname[voted.props$prop.id == "0a1ff846ec271184ea4e3a921a3ccd8d478f69948b984445ee1852f272d54c58"] = "Header commitments"
voted.props$shortname[voted.props$prop.id == "52ea110ea061c72d3b31ed2f5635720b212ce5e3eaddf868d60f53a3d18b8c04"] = "Ditto 2"
voted.props$shortname[voted.props$prop.id == "67de0e901143400ae2f247391c4d5028719ffea8308fbc5854745ad859fb993f"] = "Research 2"




decred.proposals.pi = subset(voted.props, select = c(name,url,yes_votes,no_votes,total_votes,ticket_representation,voting_startdate, voting_enddate, eligible_tickets,comments,shortname ))

write.csv(decred.proposals.pi, "Decred-proposals-pi.csv", row.names = FALSE)

#prepare info for texts
x = sapply(proposals$prop.id, last.activity)
x = sapply(proposals$prop.id, last.activity.notcomment)

#select the props to be processed and written up - from date of last snapshot for Pi digest or Journal
recentprops = proposals[proposals$last_activity > 1561851000,]


#print results for Pi digest
x = sapply(recentprops$prop.id, print.results)

#print twitter results

props = recentprops$prop.id
x = sapply(props, print.twitter.result)

#print recent stats for pi digest and journal - can use sys.time if used at snapshot time
print.pi.recent(1561851000, Sys.time())




