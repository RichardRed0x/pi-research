## First look at Politeia comments and up/down votes

This writeup is based on data from the comments.journal files downloaded late Nov 18th, for all 9 proposals submitted thus far. Data is available [here](/data/), the script for data collection [here](/data collection/process-comments.journal.R), R code for analysis [here](/analysis/comments-analysis-2018-11-19.R).

There are at this point 264 comments and 1,027 up/down votes on comments, from 80 different Pi public keys. 

Data from the Pi repo refers to public keys, and these can (soon) be looked up through the Pi API, but for now all of the analyses relate to public keys, not Pi usernames.

There are 10 commenters who have not voted, and 18 voters who have not commented.

10% of the votes cast have been down-votes.

Reddit automatically applies an upvote to every comment on behalf of its owner, but Politeia does not currently do this. Instead, Pi commenters can upvote their own comments. There are 78 votes on comments from the comment owner, so around 30% of comments have been upvoted by their owner.

The figure below shows users plotted according to their total number of comments and up/down votes. There is a correlation of 0.3 between number of comments and votes. 

![Comments and votes per user (public key)](/img/comments-votes-per-pubkey.png)



Shoutout to @bee, who is the outlier with 149 comment votes and 19 comments. 

There are 18 pubkeys who have voted but not commented, together these silent users account for 186 up-down votes, 18% of the total votes.

The user whose comments have received the most up-votes so far is @jy-p, with 20 comments that have racked up a score of 101.

The API will I understand soon be updated to allow look-up of usernames from public keys, from which point it will be possible to produce tables representing user activity, linked to user names (presently this would be linked to Pi public keys, which are not immediately recognizable).

There are some issues associated with publishing such tables, as they can turn into leaderboards and be gamed as such. I am interested in hearing whether people want these tables/leaderboards to be produced.

#### Timing of comments and votes

I considered the timing of comments relative to the opening or approval for display of the proposal. For now, these gaps are actually based on the time of the first comment, e.g. a proposal with Day = 0.5 was submitted 12 hours after the first comment on that proposal.

![Histogram showing comments by time since proposal open for comments](/img/comments-by-day.png)

Histogram showing comments by time since proposal open for comments.

![Histogram showing votes by time since proposal open for comments](C:/Users/richa/Documents/GitHub/pi-research/analysis/img/votes-by-day.png)

Histogram showing comment votes by time since proposal open for comments.

Unsurprisingly, most comments are made soon after the proposal opens, with 32% of all comments being made within 1 day of the proposal opening, 52% within 2 days, and 66% within 3 days. For voting the figures are 22%, 41% and 52%.

Below there are graphs showing the timing of comments and votes per proposal. After discussion has died down, subsequent comments are often related to an event like the proposal owner editing it or responding in comments. By the time voting starts, discussion has usually ended, and there are very few comments made on proposals which are currently open for voting. These graphs are truncated at 20 days, excluding a few late comments on the DCC proposal.

![Histogram showing comments by time since proposal opened, per proposal](C:/Users/richa/Documents/GitHub/pi-research/analysis/img/comments-by-day-by-proposal.png)

Figures showing timing of comments (above) and comment votes (below) per proposal

![Histogram showing votes by time since proposal opened, per proposal](C:/Users/richa/Documents/GitHub/pi-research/analysis/img/votes-by-day-by-proposal.png)





