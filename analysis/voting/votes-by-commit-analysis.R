library(ggplot2)
library(reshape2)
library(gridExtra)
library(ggpubr)


#create a function to prepare the data for a single prop to be plotted, then loop through the function rbinding 
#this should run in the folder where s-ben's piparser data is stored

#function returns a proposal's voting broken down by commits 
prepare.votes.commits = function(proposal){
  propvotes = read.csv(paste(proposal, "_votes.csv", sep=""), stringsAsFactors = FALSE)
  propvotes$time_since_start = propvotes$timestamp - min(propvotes$timestamp)
  propvotes$prop = proposal
  propcommits = dcast(propvotes, commit_num + prop  +  timestamp + time_since_start ~ .)
  propcommits$cumulative.votes = cumsum(propcommits$.)
  return(propcommits)
}

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


#manual proposal list
proposal = c("60adb9c0946482492889e85e9bce05c309665b3438dd85cb1a837df31fbf57fb", "fb8e6ca361c807168ea0bd6ddbfb7e05896b78f2576daf92f07315e6f8b5cd83", "a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f", "c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e", "d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509")
title = c("IDAX", "Community site", "Tutorials", "Marketing", "Events")
props.df = data.frame(proposal, title)

props.df$proposal = as.character(props.df$proposal)



prop.votes.commit = prepare.votes.commits(props.df$proposal[1])




for(p in props.df$proposal[2:length(props.df$proposal)])
{
  t = prepare.votes.commits(p)
  prop.votes.commit = rbind(prop.votes.commit, t)
}

prop.votes.yesno = prepare.votes.yesno(props.df$proposal[1])
for(p in props.df$proposal[2:length(props.df$proposal)])
{
  t = prepare.votes.yesno(p)
  prop.votes.yesno = rbind(prop.votes.yesno, t)
}



#give each proposal a short title for graphs
prop.votes.commit$proptitle = ""
prop.votes.commit$proptitle[prop.votes.commit$prop == "522652954ea7998f3fca95b9c4ca8907820eb785877dcf7fba92307131818c75"] = "Language"
prop.votes.commit$proptitle[prop.votes.commit$prop == "c68bb790ba0843980bb9695de4628995e75e0d1f36c992951db49eca7b3b4bcd"] = "Research"
prop.votes.commit$proptitle[prop.votes.commit$prop == "27f87171d98b7923a1bd2bee6affed929fa2d2a6e178b5c80a9971a92a5c7f50"] = "Ditto"
prop.votes.commit$proptitle[prop.votes.commit$prop == "bc8776180b5ea8f5d19e7d08e9fcc35f0d1e3d16974963e3e5ded65139e7b092"] = "Wachsman"
prop.votes.commit$proptitle[prop.votes.commit$prop == "34707d34b09c3ebcf0d4aa604e8a08244e8f0f082c0af3f33d85778c93c81434"] = "Easyrabbit"
prop.votes.commit$proptitle[prop.votes.commit$prop == "fa38a3593d9a3f6cb2478a24c25114f5097c572f6dadf24c78bb521ed10992a4"] = "DCC"
prop.votes.commit$proptitle[prop.votes.commit$prop == "bb7e19283d5c65fed598d5a2f4afcc2b5d2eab187b9cb84fc4304430f80b5ad1"] = "ATMs"
prop.votes.commit$proptitle[prop.votes.commit$prop == "e78bc28631d0e682912e3ece25944481bf978b906ea44b1ed36470c0f48b27fc"] = "Decredex"
prop.votes.commit$proptitle[prop.votes.commit$prop == "7fe5d07a4ffff7dc6a83383018823d880b1c1db0a29305e74934817cf2b4e2ce"] = "Radio"
prop.votes.commit$proptitle[prop.votes.commit$prop == "d33a2667469b56942adf42453def6cc2292325251e4cf791e806939ea9efc9e1"] = "Bounty"


prop.votes.commit$days_since_start = prop.votes.commit$time_since_start/(60*60*24)

#plot the timing of votes for every proposal
p.vote.timing = ggplot(prop.votes.commit, aes(x = days_since_start, y = cumulative.votes, color = proptitle))+
  geom_line(size = 1.5)+
  labs(x = "Days since voting opened", y = "Cumulative number of votes cast", caption = "Dashed red line indicates quorum requirement")+
  scale_colour_brewer(palette = "Set1", name = "Proposal")+
  geom_hline(yintercept=8192, linetype="dashed", color = "red")

ggsave("proposal-ticket-votes-over-time.png", height = 4, width = 8)


#plot a single proposal votes over time, the plot is saved and the data frame it uses is returned
plot.votes.yesno = function(proposal, name){
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

p.Decredex = plot.votes.yesno("e78bc28631d0e682912e3ece25944481bf978b906ea44b1ed36470c0f48b27fc", "Decredex")
p.Ditto = plot.votes.yesno("27f87171d98b7923a1bd2bee6affed929fa2d2a6e178b5c80a9971a92a5c7f50", "Ditto")
p.bounty = plot.votes.yesno("d33a2667469b56942adf42453def6cc2292325251e4cf791e806939ea9efc9e1", "Bounty")


p.marketing = plot.votes.yesno("c84a76685e4437a15760033725044a15ad832f68f9d123eb837337060a09f86e", "Marketing 2019")
p.events = plot.votes.yesno("d3e7f159b9680c059a3d4b398de2c8f6627108f28b7d61a3f10397acb4b5e509", "Events-2019")
p.tutorials = plot.votes.yesno("a3def199af812b796887f4eae22e11e45f112b50c2e17252c60ed190933ec14f", "Tutorial-videos")
p.community = plot.votes.yesno("fb8e6ca361c807168ea0bd6ddbfb7e05896b78f2576daf92f07315e6f8b5cd83", "Community-site")



