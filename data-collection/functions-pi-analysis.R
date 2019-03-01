
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
  print(p)
  print(version)
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
  print(p)
  print(version)
  filename = paste(p, "/", version, "/15.metadata.txt", sep="")
  
  tryCatch({
  prop.input = readChar(filename, file.info(filename)$size)
  
  prop = fromJSON(prop.input, flatten = TRUE)
  
  proposals$voting_startblock[proposals$prop.id == p] = prop$startblockheight
  proposals$voting_endblock[proposals$prop.id == p] = prop$endheight
  assign('proposals', proposals, envir=.GlobalEnv)
    return(prop$eligibletickets)
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

#take a list of proposal IDs for proposals that are new or in discussion

#take a list of proposal IDs, generate the text for their headings/results
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

#function to write a table file with all the statements as I need them for Pi digest



#function to prepare a data-set for plotting several proposals over time


prepare.votes.commits = function(proposal, name){
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
    labs(x = "", y = "Cumulative votes")

  
  #show approval % over time
  p.approval = ggplot(commits.df, aes(x = datetime, y = yesper, colour = name))+
    geom_line(size = 1.1)+
    ylim(0,100)+
    geom_hline(yintercept = 60)+
    labs(x = "", y = "Percentage Yes votes")
  
  #show votes per commit
  m.commits.yesno = melt(commits.df, id.vars = c("datetime", "name"), measure.vars = c("No", "Yes"))
  m.commits.yesno$vote = 1
  m.commits.yesno$vote[m.commits.yesno$variable == "No"] = -1
  m.commits.yesno$value=  m.commits.yesno$value * m.commits.yesno$vote
  
  p.votes.yesno = ggplot(m.commits.yesno, aes(x = datetime, y = value, fill = name))+
    geom_bar(stat = "identity", position = "dodge")+
    labs(fill = "Vote", x = "Datetime of vote commits", y = "Number of votes cast in hourly commit" )
  
  ggarrange(p.cumulative.votes,   p.approval, p.votes.yesno,  ncol = 1, nrow = 3)
  
  ggsave(paste(chartname, "-proposal-voting-over-time.png", sep=""),  height = 12, width = 20)
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
  m.commits.yesno = melt(propcommits, id.vars = "days_since_start", measure.vars = c("No", "Yes"))
  p.votes.yesno = ggplot(m.commits.yesno, aes(x = days_since_start, y = value, fill = variable))+
    geom_bar(stat = "identity")+
    labs(fill = "Vote", x = "Days since voting opened", y = "Number of votes cast in hourly commit" )+
    theme(legend.position = c(0.05, 0.93))
  
  ggarrange(p.cumulative.votes,   p.approval, p.votes.yesno, ncol = 1, nrow = 3)
  
  ggsave(paste(name, "-proposal-voting-over-time.png", sep=""),  height = 12, width = 8)
  return(propcommits)
}
