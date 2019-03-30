
library(jsonlite)
library(RCurl)
library(ggplot2)
library(reshape2)
library(gridExtra)
library(ggpubr)





#function to fetch proposal IDs

fetch.proposals = function(){
  prop.id = list.dirs(path = ".", full.names = FALSE, recursive = FALSE)
  prop.id = prop.id[prop.id != ".git" & prop.id != "anchors"]
  return(prop.id)
}


#function to check what most recent version is
latest.version = function(p){
  versions = list.dirs(path = paste( p, "/.", sep = ""), full.names = FALSE, recursive = FALSE)
  latestversion = max(as.numeric(versions))
  return(latestversion)
}


#function to get name, submission timestamp, owner pubkey







#function to pull all comments and votes associated with a proposal
get.comments = function(p, version)
{
  #locate and pull in comments.journal
  filename = paste(p, "/", version, "/plugins/decred/comments.journal", sep="")
  prop.input = readChar(filename, file.info(filename)$size)
  
  
  #processing to make this a valid json object
  prop.input = gsub("}{", ",", prop.input, fixed = TRUE)
  prop.input = gsub("}", "},", prop.input, fixed = TRUE)
  prop.input = gsub("\n", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n1\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n2\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n3\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n4\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n5\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n6\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n7\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n8\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n9\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n10\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n11\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n12\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n13\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n14\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n15\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n16\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n17\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n18\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n19\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n20\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\n\\n21\\", "", prop.input, fixed = TRUE)
  prop.input = gsub("\r", "", prop.input, fixed = TRUE)
  prop.input = gsub("\t", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\.", "", prop.input, fixed = TRUE)
  
  prop.input = gsub("\"action\":\"-1\"", "\"vote\": \"-1\"", prop.input, fixed = TRUE)
  prop.input = gsub("\"action\":\"1\"", "\"vote\": \"1\"", prop.input, fixed = TRUE)
  prop.input = paste("{\"proposals\": [", prop.input, sep="")
  prop.input = paste(prop.input, "}", sep="")
  prop.input = gsub(",}", "]}", prop.input, fixed = TRUE)

  
  #read the json
  prop = fromJSON(prop.input, flatten = TRUE)
  prop = prop$proposals
  
  return(prop)
}


#set last comment date
lastcomment = function(p, version){
  proposals$last_comment[proposals$prop.id == p] = max(df.comments$timestamp[df.comments$token == p])
  assign('proposals', proposals, envir=.GlobalEnv)
}
  

#creation time
process00 = function(p, version){
  #locate and pull in comments.journal
  filename = paste(p, "/", version, "/00.metadata.txt", sep="")
  prop.input = readChar(filename, file.info(filename)$size)
  prop = fromJSON(prop.input, flatten = TRUE)
  proposals$updated_at_unix[proposals$prop.id == p] = prop$timestamp
  proposals$submitted_by[proposals$prop.id == p] = prop$publickey
  proposals$name[proposals$prop.id == p] = prop$name
  assign('proposals', proposals, envir=.GlobalEnv)
}



#publication time
process02 = function(p, version){

  #locate and pull in comments.journal
  filename = paste(p, "/", version, "/02.metadata.txt", sep="")
  prop.input = readChar(filename, file.info(filename)$size)
  prop.input = gsub("}{", ",", prop.input, fixed = TRUE)
  prop = fromJSON(prop.input, flatten = TRUE)
  proposals$published_at_unix[proposals$prop.id == p] = prop$timestamp
  assign('proposals', proposals, envir=.GlobalEnv)
}

#voting period, returns eligible tickets. also returns API errors, not really working properly yet
process15 = function(p, version){
  #locate and pull in comments.journal
  
  filename = paste(p, "/", version, "/15.metadata.txt", sep="")
  
  tryCatch({
    prop.input = readChar(filename, file.info(filename)$size)
    
    prop = fromJSON(prop.input, flatten = TRUE)
    
    propid = seq(1:length(prop$eligibletickets))
    pdf = data.frame(prop$eligibletickets, propid)
    pdf$propid = p
    
    proposals$voting_startblock[proposals$prop.id == p] = prop$startblockheight
    proposals$voting_endblock[proposals$prop.id == p] = prop$endheight
    assign('proposals', proposals, envir=.GlobalEnv)
    return(pdf)
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}
#process ballots to find out about vote state
process.ballot = function(p, version){
  filename = paste(p, "/", version, "/plugins/decred/ballot.journal", sep="")
  
  tryCatch({
  prop.input = readChar(filename, file.info(filename)$size)
  
  #processing to make this a valid json object
  prop.input = gsub("}{", ",", prop.input, fixed = TRUE)
  prop.input = gsub("}\r", "},", prop.input, fixed = TRUE)
  prop.input = paste("{\"votes\": [", prop.input, sep="")
  prop.input = paste(prop.input, "]}", sep="")
  prop.input = gsub("},\n]}", "}]}", prop.input, fixed = TRUE)
  prop = fromJSON(prop.input, flatten = TRUE)
  votes = prop$votes
  return(votes)
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})  
  
}
update.voting.status = function(p){
  relvotes = votes.df[votes.df$castvote.token == p,]
  total_votes = nrow(relvotes)
  yes_votes = nrow(relvotes[relvotes$castvote.votebit == 2,])
  no_votes = nrow(relvotes[relvotes$castvote.votebit == 1,])
  
  proposals$total_votes[proposals$prop.id == p] = total_votes
  proposals$yes_votes[proposals$prop.id == p] = yes_votes
  proposals$no_votes[proposals$prop.id == p] = no_votes
  proposals$ticket_representation[proposals$prop.id == p] = (total_votes/40960)*100
  proposals$support_from[proposals$prop.id == p] = (yes_votes/40960)*100
  proposals$yesper[proposals$prop.id == p] = (yes_votes/total_votes)*100
  proposals$noper[proposals$prop.id == p] = (no_votes/total_votes)*100
  proposals$comments[proposals$prop.id == p] = nrow(df.comments[df.comments$token == p,])
  
  assign('proposals', proposals, envir=.GlobalEnv)
}

last.activity = function(p){
  proposals$last_activity[proposals$prop.id == p] = max(proposals$updated_at_unix[proposals$prop.id == p], proposals$published_at_unix[proposals$prop.id == p], 
                                                        proposals$voting_starttime[proposals$prop.id == p], proposals$voting_endtime[proposals$prop.id == p],
                                                        proposals$last_comment[proposals$prop.id == p], na.rm = TRUE)
  assign('proposals', proposals, envir=.GlobalEnv)
}
last.activity.notcomment = function(p){
  proposals$last_activity_notcomment[proposals$prop.id == p] = max(proposals$updated_at_unix[proposals$prop.id == p], proposals$published_at_unix[proposals$prop.id == p], 
                                                        proposals$voting_starttime[proposals$prop.id == p], proposals$voting_endtime[proposals$prop.id == p], na.rm = TRUE)
  assign('proposals', proposals, envir=.GlobalEnv)
}


#take a list of proposal IDs for proposals that are new or in discussion

#take a list of proposal IDs, generate the text for their headings/results for pi digest
  print.results = function(p){
    if(!is.na(proposals$voting_enddate[proposals$prop.id == p])){
    pastetext = paste("**[", proposals$name[proposals$prop.id == p], "](", "https://proposals.decred.org/proposals/",
                      p, ") - voting finished ", strftime(proposals$voting_enddate[proposals$prop.id == p], "%b %e"),
                      " - ", proposals$comments[proposals$prop.id == p], " comments ()**", sep="")
  cat(pastetext, file = "pi-digest-output.md", append = T, sep = '\n')
  pastetext2 =   paste(prettyNum(proposals$yes_votes[proposals$prop.id == p], big.mark = ","),
                       " Yes votes, ", prettyNum(proposals$no_votes[proposals$prop.id == p], big.mark = ","),
                       " No votes (", round(proposals$yesper[proposals$prop.id == p], 1), "% Yes) - voter participation of ",
                       round(proposals$ticket_representation[proposals$prop.id == p], 1), "%, support from ",
                       round(proposals$support_from[proposals$prop.id == p], 0), "% of tickets.", sep="" )
  cat(pastetext2,  file = "pi-digest-output.md", append = T, sep = '\n')
  } else if (!is.na(proposals$voting_starttime[proposals$prop.id == p])) {
      pastetext = paste("**[", proposals$name[proposals$prop.id == p], "](", "https://proposals.decred.org/proposals/",
                        p, ") - voting started on ", strftime(proposals$voting_startdate[proposals$prop.id == p], "%b %e"),
                        " - ", proposals$comments[proposals$prop.id == p], " comments ()**", sep="")
      cat(pastetext, file = "pi-digest-output.md", append = T, sep = '\n')
      pastetext2 =   paste("Latest voting figures: ", prettyNum(proposals$yes_votes[proposals$prop.id == p], big.mark = ","),
                           " Yes votes, ", prettyNum(proposals$no_votes[proposals$prop.id == p], big.mark = ","),
                           " No votes (", round(proposals$yesper[proposals$prop.id == p], 1), "% Yes) - voter participation of ",
                           round(proposals$ticket_representation[proposals$prop.id == p], 1), "%, support from ",
                           round(proposals$support_from[proposals$prop.id == p], 0), "% of tickets.", sep="" )
      cat(pastetext2,  file = "pi-digest-output.md", append = T, sep = '\n')      
  }
      pastetext = paste("**[", proposals$name[proposals$prop.id == p], "](", "https://proposals.decred.org/proposals/",
                        p, ") - published ", strftime(proposals$published_at[proposals$prop.id == p], "%b %e"),
                        " by XXXXXX, last updated ", strftime(proposals$updated_at[proposals$prop.id == p], "%b %e"),
                        " - ",  proposals$comments[proposals$prop.id == p], " comments ()**", sep="")  
      cat(pastetext, file = "pi-digest-output.md", append = T, sep = '\n')  
    }

  
  print.twitter.result = function(p){
    cat(paste("Proposal voting finished - ", proposals$name[proposals$prop.id == p], sep=""), file = "twitter-result-output.md", append = T, sep = '\n')
    cat(paste(prettyNum(proposals$yes_votes[proposals$prop.id == p], big.mark = ","),
              " Yes votes, ", prettyNum(proposals$no_votes[proposals$prop.id == p], big.mark = ","),
              " No votes (", round(proposals$yesper[proposals$prop.id == p], 1), "% Yes) - voter participation of ",
              round(proposals$ticket_representation[proposals$prop.id == p], 1), "%", sep="" ), file = "twitter-result-output.md", append = T, sep = '\n')
    cat(paste("https://proposals.decred.org/proposals/",p , sep=""),   file = "twitter-result-output.md", append = T, sep = '\n') 
    }

print.pi.until = function(timetill){
  voted.proposals.until = proposals[!is.na(proposals$voting_endtime) & proposals$voting_endtime < timetill,]
  votes.df.until = votes.df[votes.df$castvote.token %in% voted.proposals.until$prop.id,]
  df.comments.until = df.comments[df.comments$timestamp < timetill,]
  df.comment.votes.until = df.comment.votes[df.comment.votes$timestamp < timetill,]  
  non.commenting.voters = df.comment.votes.until[!df.comment.votes.until$publickey %in% unique(df.comments.until$publickey),]
  
  cat(paste("As of ", strftime(as.POSIXct(timetill, origin = "1970-01-01"), "%b %e"), " on Politeia:", sep=""), file = 'journal-pi.md', sep = '\n')
  cat(paste("* ", prettyNum(nrow(proposals), big.mark = ","), " Politeia proposals have been submitted, and ", nrow(voted.proposals.until) ,
            " proposals have finished voting.", sep=""), file = 'journal-pi.md', sep = '\n', append = T)
  cat(paste("* Proposals that have finished voting have an average (mean) turnout of ", round(mean(voted.proposals.until$ticket_representation), 1) , "%, with a total of ", prettyNum(nrow(votes.df.until), big.mark = ",") ,
            " ticket votes being cast.", sep=""), file = 'journal-pi.md', sep = '\n', append = T)
  cat(paste("* There have been ", prettyNum(nrow(df.comments.until), big.mark = ","), " comments on Politeia proposals from ", length(unique(df.comments.until$publickey)),
            " different users (public keys).", sep=""), file = 'journal-pi.md', sep = '\n', append = T)
  cat(paste("* There have been ", prettyNum(nrow(df.comment.votes.until), big.mark = ","), " up/down votes on comments from ", 
            length(unique(df.comment.votes.until$publickey)), " different voting users (public keys).", sep=""),
      file = 'journal-pi.md', append = T, sep = '\n')
  cat(paste("* ", prettyNum(nrow(df.comment.votes.until[df.comment.votes.until$vote == 1,]), big.mark = ","), 
            " upvotes (", round((nrow(df.comment.votes.until[df.comment.votes.until$vote == 1,])/nrow(df.comment.votes.until)),1)*100, "%) and ",
            nrow(df.comment.votes.until[df.comment.votes.until$vote == -1,]), " downvotes (",
            round((nrow(df.comment.votes.until[df.comment.votes.until$vote == -1,])/nrow(df.comment.votes.until)),1)*100, "%).", sep=""),
      file = 'journal-pi.md', append = T, sep = '\n')
  cat(paste("* There are ", length(unique(non.commenting.voters$publickey)),
            " users who have voted but never commented, and together they have cast ", nrow(non.commenting.voters), 
            " votes (", round((nrow(non.commenting.voters)/nrow(df.comment.votes.until))*100, digits = 1), "% of total).", sep=""),
      file = 'journal-pi.md', append = T, sep = '\n')
  cat(paste("* Around ", sum(df.comments.until$selfvotes), " comments (", round((sum(df.comments.until$selfvotes)/nrow(df.comments.until))*100, 0) ,
            "%) have been upvoted by their author.", sep=""),
      file = 'journal-pi.md', append = T, sep = '\n')
  }
  
print.pi.recent = function(timesince, timetill){
df.comments.recent = df.comments[df.comments$timestamp > timesince & df.comments$timestamp < timetill,]
df.comment.votes.recent = df.comment.votes[df.comment.votes$timestamp > timesince & df.comment.votes$timestamp < timetill,]
new.props = nrow(proposals[proposals$published_at_unix > timesince & proposals$published_at_unix < timetill,])
voted.proposals.recent = proposals[!is.na(proposals$voting_endtime) & proposals$voting_endtime < timetill & proposals$voting_endtime > timesince,]
voting.props = nrow(proposals[proposals$voting_starttime > timesince & proposals$voting_starttime < timetill & !is.na(proposals$voting_starttime),])
votes.df.recent = votes.df[votes.df$castvote.token %in% voted.proposals.recent$prop.id,]


  cat(paste("From ", strftime(as.POSIXct(timesince, origin = "1970-01-01"), "%b %e"), " until ", strftime(as.POSIXct(timetill, origin = "1970-01-01"), "%b %e"), " there were:", sep=""),
      file = 'journal-pi-recent.md', sep = '\n')
  cat(paste("* ", prettyNum(new.props, big.mark = ","), " new proposals submitted, ", voting.props,
            " proposals started voting, ", nrow(voted.proposals.recent), " proposals finished voting.", sep=""), file = 'journal-pi-recent.md', sep = '\n', append = T)
  cat(paste("* Proposals that have finished voting have an average (mean) turnout of ", round(mean(voted.proposals.recent$ticket_representation), 1) , "%, with a total of ", prettyNum(nrow(votes.df.recent), big.mark = ",") ,
            " ticket votes being cast.", sep=""), file = 'journal-pi-recent.md', sep = '\n', append = T)  
  cat(paste("* ", prettyNum(nrow(df.comments.recent), big.mark = ","), " comments on Politeia proposals from ", length(unique(df.comments.recent$publickey)),
            " different users (public keys).", sep=""), file = 'journal-pi-recent.md', sep = '\n', append = T)
  cat(paste("* ", prettyNum(nrow(df.comment.votes.recent), big.mark = ","), " up/down votes on comments from ", 
            length(unique(df.comment.votes.recent$publickey)), " different voting users (public keys)."),
      file = 'journal-pi-recent.md', append = T, sep = '\n')
  cat(paste("* ", prettyNum(nrow(df.comment.votes.recent[df.comment.votes.recent$vote == 1,]), big.mark = ","), 
            " upvotes (", round((nrow(df.comment.votes.recent[df.comment.votes.recent$vote == 1,])/nrow(df.comment.votes.recent)),1)*100, "%) and ",
            nrow(df.comment.votes.recent[df.comment.votes.recent$vote == -1,]), " downvotes (",
            round((nrow(df.comment.votes.recent[df.comment.votes.recent$vote == -1,])/nrow(df.comment.votes.recent)),1)*100, "%).", sep=""),
      file = 'journal-pi-recent.md', append = T, sep = '\n')

}

fix.latevotes = function()
{
  prop = c("5431da8ff4eda8cdbf8f4f2e08566ffa573464b97ef6d6bae78e749f27800d3a", "60adb9c0946482492889e85e9bce05c309665b3438dd85cb1a837df31fbf57fb", "a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f", "c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e", "d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509")
  title = c("", "", "", "", "")
  props.df = data.frame(prop, title)
  for(p in props.df$prop)
  {
    commits.df$endtime[commits.df$prop == p] = proposals$voting_endtime[proposals$prop.id == p]
  }
  commits.df$latevote = 0
  commits.df$latevote[commits.df$timestamp > (commits.df$endtime + 3600)] = 1
  latevotes = commits.df[commits.df$latevote == 1,]
  for(p in props.df$prop)
  {
    total_votes = 
      yes_votes = nrow(relvotes[relvotes$castvote.votebit == 2,])
    no_votes = nrow(relvotes[relvotes$castvote.votebit == 1,])
    
    proposals$total_votes[proposals$prop.id == p] = sum(commits.df$Yes[commits.df$prop == p & commits.df$latevote == 0]) +sum(commits.df$No[commits.df$prop == p & commits.df$latevote == 0])
    proposals$yes_votes[proposals$prop.id == p] = sum(commits.df$Yes[commits.df$prop == p & commits.df$latevote == 0]) 
    proposals$no_votes[proposals$prop.id == p] = sum(commits.df$No[commits.df$prop == p & commits.df$latevote == 0])
    proposals$ticket_representation[proposals$prop.id == p] = (proposals$total_votes[proposals$prop.id == p] /40960)*100
    proposals$support_from[proposals$prop.id == p] = (proposals$yes_votes[proposals$prop.id == p]/40960)*100
    proposals$yesper[proposals$prop.id == p] = (proposals$yes_votes[proposals$prop.id == p]/proposals$total_votes[proposals$prop.id == p] )*100
    proposals$noper[proposals$prop.id == p] = (proposals$no_votes[proposals$prop.id == p]/proposals$total_votes[proposals$prop.id == p] )*100
  }
  assign('proposals', proposals, envir=.GlobalEnv)
  
  
  
  
}
  
    
#print a general statement about politeia activity since timestamp X
  #new proposals
  #proposals voting
  #proposals finished voting
  #new comments
  #new comment votes
  #new comments and votes as daily rate
  
  #new proposal votes
  #number of total ticket votes and number of unique tickets that voted
  


#last edited date

#comments

#comment_votes




#new comments

#lookup timestamp for a blockheight

get.time = function(blockheight){
  url = paste("https://explorer.dcrdata.org/api/block/", blockheight, sep="")
  
  block.input = getURL(url)
  block = fromJSON(block.input, flatten = TRUE)
  time = block$time
  date = as.POSIXct(time, origin="1970-01-01")
  return(date)
}






#functions to prepare a data-set for plotting several proposals over time

prep.batch = function(props){
  for(p in props)
  {
    cat(paste("python vote_analysis.py ", p, sep=""),
        file = 'piparser.bat', append = T, sep = '\n')
  }
}


prepare.votes.commits = function(proposal, name){
  print(proposal)
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
  propcommits$name = name
  return(propcommits)
}



plot.proposals = function(commits.df, chartname){
  
  #make a plot showing votes over time
  m.commits.cumvotes = melt(commits.df, id.vars = c("datetime", "name"), measure.vars = c("cumulative.votes"))
  
  p.cumulative.votes = ggplot(m.commits.cumvotes, aes(x = datetime, y = value, colour = name))+
    geom_line()+
    geom_hline(aes(yintercept=8192))+
    labs(x = "", y = "Cumulative votes")+
    theme(axis.text=element_text(size=14), axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title = element_text(size = 20), legend.text = element_text(size = 16))
  
  
  #show approval % over time
  p.approval = ggplot(commits.df, aes(x = datetime, y = yesper, colour = name))+
    geom_line(size = 1.1)+
    ylim(0,100)+
    geom_hline(yintercept = 60)+
    labs(x = "", y = "Percentage Yes votes")+
    theme(axis.text=element_text(size=14), axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title = element_text(size = 20), legend.text = element_text(size = 16))
  
  #show votes per commit
  m.commits.yesno = melt(commits.df, id.vars = c("datetime", "name"), measure.vars = c("No", "Yes"))
  m.commits.yesno$vote = 1
  m.commits.yesno$vote[m.commits.yesno$variable == "No"] = -1
  m.commits.yesno$value=  m.commits.yesno$value * m.commits.yesno$vote
  
  p.votes.yesno = ggplot(m.commits.yesno, aes(x = datetime, y = value, fill = name))+
    geom_bar(stat = "identity", position = "dodge")+
    labs(fill = "Vote", x = "Datetime of vote commits", y = "Votes per hourly commit" )+
    theme(axis.text=element_text(size=15), axis.title = element_text(size = 20), legend.text = element_text(size = 16))+
    scale_x_datetime(date_breaks = "1 day")+
    geom_hline(yintercept = 0, colour = "red", size = 0.01)
  
  ggarrange(p.cumulative.votes,   p.approval, p.votes.yesno,  ncol = 1, nrow = 3)
  
  ggsave(paste(chartname, "-proposal-voting-over-time.png", sep=""),  height = 12, width = 20)
}


plot.proposal = function(prop.id, title){
  prop = prop.id
  print(prop)
  prop.df = data.frame(prop, title)
  
  #generate batch file for piparser
  #prep.batch(props.df$prop)
  
  #prepare commits and chart
  proposal.commits = apply(prop.df, 1, function(y) prepare.votes.commits(y['prop'], y['title']))
  commits.df <- do.call("rbind", proposal.commits)
  
  commits.df$datetime = as.POSIXct(commits.df$timestamp,  origin="1970-01-01")
  
  
  #make a plot showing votes over time
  m.commits.cumvotes = melt(commits.df, id.vars = c("datetime"), measure.vars = c("cumulative.votes"))
  
  p.cumulative.votes = ggplot(m.commits.cumvotes, aes(x = datetime, y = value, colour = "blue"))+
    geom_line(colour= "blue", size = 1.1)+
    geom_hline(aes(yintercept=8192))+
    labs(x = "", y = "Cumulative votes", title = paste("Proposal: ", title, sep=""))+
    theme(axis.text=element_text(size=14), axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title = element_text(size = 20), legend.text = element_text(size = 16), plot.title = element_text(size = 20))
    
  
  #show approval % over time
  p.approval = ggplot(commits.df, aes(x = datetime, y = yesper))+
    geom_line(size = 1.1, colour = "blue")+
    ylim(0,100)+
    geom_hline(yintercept = 60)+
    labs(x = "", y = "Percentage Yes votes")+
    theme(axis.text=element_text(size=14), axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title = element_text(size = 20), legend.text = element_text(size = 16))
  
  #show votes per commit
  m.commits.yesno = melt(commits.df, id.vars = c("datetime"), measure.vars = c("No", "Yes"))
  m.commits.yesno$vote = 1
  m.commits.yesno$vote[m.commits.yesno$variable == "No"] = -1
  m.commits.yesno$value=  m.commits.yesno$value * m.commits.yesno$vote
  
  m.commits.yesno$variable = factor(m.commits.yesno$variable, levels = c("Yes", "No"))
  
  p.votes.yesno = ggplot(m.commits.yesno, aes(x = datetime, y = value, fill = variable))+
    geom_bar(stat = "identity", position = "dodge")+
    labs(fill = "Vote", x = "Datetime of vote commits", y = "Votes per hourly commit" )+
    theme(axis.text=element_text(size=15), axis.title = element_text(size = 20), legend.text = element_text(size = 16), legend.position = c(0.98, 0.93))+
    scale_x_datetime(date_breaks = "1 day")+
    geom_hline(yintercept = 0, colour = "red", size = 0.01)+
    scale_fill_manual(values = c("Green", "Red"))
  
  ggarrange(p.cumulative.votes,   p.approval, p.votes.yesno,  ncol = 1, nrow = 3)
  
  ggsave(paste(title, "-proposal-voting-over-time.png", sep=""),  height = 12, width = 20)
}



#old bar chart
#  p.cumulative.votes = ggplot(m.commits.cumvotes, aes(x = datetime, y = value, fill = name))+
#geom_bar(stat = "identity", position = "dodge")+
#  geom_hline(aes(yintercept=8192))+
#  labs(x = "", y = "Cumulative votes")









#function returns a data frame that can be used to draw graphs
prepare.votes.yesno = function(proposal){
  propvotes = read.csv(paste(proposal, "_votes.csv", sep=""), stringsAsFactors = FALSE)
  propvotes$time_since_start = propvotes$timestamp - min(propvotes$timestamp)
  propvotes$prop = proposal
  propcommits = dcast(propvotes, commit_num + prop  +  timestamp + time_since_start ~ vote)
  propcommits$cumulative.yes = cumsum(propcommits$Yes)
  propcommits$cumulative.no = cumsum(propcommits$No)
  return(propcommits)
}


#plot a single proposal votes over time, the plot is saved and the data frame it uses is returned
plot.votes.proposal = function(proposal, name){
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
  m.commits.yesno = melt(propcommits, id.vars = c("datetime", "name"), measure.vars = c("No", "Yes"))
  m.commits.yesno$vote = 1
  m.commits.yesno$vote[m.commits.yesno$variable == "No"] = -1
  m.commits.yesno$value=  m.commits.yesno$value * m.commits.yesno$vote
  
  p.votes.yesno = ggplot(m.commits.yesno, aes(x = datetime, y = value, fill = name))+
    geom_bar(stat = "identity", position = "dodge")+
    labs(fill = "Vote", x = "Datetime of vote commits", y = "Votes per hourly commit" )+
    theme(axis.text=element_text(size=15), axis.title = element_text(size = 20), legend.text = element_text(size = 16))+
    scale_x_datetime(date_breaks = "1 day")+
    geom_hline(yintercept = 0, colour = "red", size = 0.7)
  
  ggarrange(p.cumulative.votes,   p.approval, p.votes.yesno, ncol = 1, nrow = 3)
  
  ggsave(paste(name, "-proposal-voting-over-time.png", sep=""),  height = 12, width = 8)
  return(propcommits)
}
