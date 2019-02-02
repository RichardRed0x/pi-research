setwd("C:\\Users\\richa\\Documents\\GitHub\\pi-research\\data")
library(jsonlite)
library(RCurl)

props =read.csv("prop-urls.csv", stringsAsFactors = FALSE )

x = get.comments(props$url[1])
ptitle = props$title[props$url == url]
x$prop.title = ptitle
df = x[x$dummy == 2]

for(url in props$url)
{
  x =  get.comments(url)
  ptitle = props$title[props$url == url]
  x$prop.title = ptitle
  df = rbind(df, x)  
}


  
get.comments = function(url)
  {
  url = paste(url, "/plugins/decred/comments.journal", sep="")
  
  #fetch the prop's comments.journal  
  prop.input = getURL(url)
  
  #processing to make this a valid json object
  prop.input = gsub("}{", ",", prop.input, fixed = TRUE)
  prop.input = gsub("}", "},", prop.input, fixed = TRUE)
  prop.input = gsub("\n", "", prop.input, fixed = TRUE)
  prop.input = gsub("\t", "", prop.input, fixed = TRUE)
  prop.input = gsub("\\.", "", prop.input, fixed = TRUE)
  
  prop.input = gsub("\"action\":\"-1\"", "\"vote\": \"-1\"", prop.input, fixed = TRUE)
  prop.input = gsub("\"action\":\"1\"", "\"vote\": \"1\"", prop.input, fixed = TRUE)
  prop.input = paste("{\"proposals\": [", prop.input, sep="")
  prop.input = paste(prop.input, "}", sep="")
  prop.input = gsub(",}", "]}", prop.input, fixed = TRUE)
  
  #read the json
  prop = fromJSON(prop.input, flatten = TRUE)
  prop1 = prop[[1]]
  prop = as.data.frame(prop1)
  
  #split comments and votes into different data frames
  prop.comments = prop[prop$action == "add",]
  prop.comment.votes = prop[prop$action == "addlike",]
  
  proposal = prop$token[1]
  
  
  #write.csv(prop.comments, file = paste(proposal, "-comments.csv", sep=""), row.names = FALSE)
  #write.csv(prop.comment.votes, file = paste(proposal, "-votes.csv", sep=""), row.names = FALSE)
  return(prop)

  }

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



