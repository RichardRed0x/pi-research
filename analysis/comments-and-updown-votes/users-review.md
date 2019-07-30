The Politeia API has recently been extended to allow user IDs and names to be looked up from public keys (proposals, comments and up/down votes are associated with public keys in the Pi data).

[Here](https://github.com/RichardRed0x/pi-research/tree/master/data/comments-and-updown-votes/pi-users.csv) is a table which records all Pi users who have acted (commented or voted at least once), there are 154 users in the set.

* comments: no. of comments made
* upvotes: no. of upvotes cast
* downvotes: no. of downvotes cast
* commentscore: aggregated score of the user's comments, like reddit karma score
* score.per.comment: commentscore divided by no. of comments
* votes: total no. of votes cast
* proposals: no. of proposals submitted

There follows some high-level analysis of the data as it was on 30 July 2019 (this [commit](https://github.com/decred-proposals/mainnet/commit/6d54651a435106825f1ca13cce3ba325519bd787)).

![Histogram showing comments per user](img/pi-users-comments-histogram.png"Histogram showing comments per user")

![Histogram showing votes per user](img/pi-users-votes-histogram.png"Histogram showing votes per user")

The number of votes and comments per user is highly skewed and follows a power law type distribution whereby a small number of highly active users account for a large proportion of activity. This kind of distribution is common to more or less all online social platforms.

The graphs above exclude an outlier - @bee, who with 132 comments and 661 votes is the most active user by far, and accounts for 11% of all comments and 19% of all comment votes.

![Scatterplot showing votes and comments per user (each point is a user)](img/pi-users-votes-comments-scatterplot.png"Scatterplot showing votes and comments per user (each point is a user)")

In general there is a correlation between no. of comments and votes, but there are also users who are mostly active in just one of those ways. 32% of Pi users only commented (17%) or voted (15%). 

280 votes (7% of total) came from users who have never commented, and who are therefore invisible on the proposals site.

Thanks to @s_ben for implementing the API endpoint that allows user IDs and names to be retrieved, and to @lukebp for helping me figure out how to process a series of up/down votes and revocations by the same user to arrive at the same conclusion as the Pi server about how they ultimately voted. Every time a user clicks those up/down voting buttons this is recorded in the repository as an action, and the server figures out the current state by processing those actions in sequence.