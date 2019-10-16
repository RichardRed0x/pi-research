---
title: One year of Decred's Politeia in numbers and graphs
authors:
- richard
date: "2019-10-16T00:00:00Z"
doi: ""

# Schedule page publish date (NOT publication's date).
publishDate: "2017-01-01T00:00:00Z"

#publication_types: ["3"]

# Publication name and optional abbreviated publication name.
# publication: In Pi Research
publication_short: Pi Research

# Summary. An optional shortened abstract.
summary: A look at Politeia data for the first year

tags:
- Politeia
- Comments
- Community
- Decred
- Governance
featured: true

links:
url_dataset: 'https://github.com/RichardRed0x/pi-research/tree/master/analysis/pi-at-1'
url_code: 'https://github.com/RichardRed0x/pi-research/blob/master/scripts/pi-1-year.R'


# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder. 
image:
  caption: ''
  focal_point: ""
  preview_only: false

projects:
- pi-research

---

This report presents an overview of Politeia activity data for the first year (Oct 16 2018 to Oct 16 2019). 

- 53 proposals have been submitted.
- 38 proposals have been voted on.
- Of those, 25 have been approved and 13 rejected.
- Proposal votes have an average (mean) turnout of 31.2%, with a total of 486,205 ticket votes being cast.
- 12 proposals have been abandoned before voting started.
- There have been 1,604 comments on Politeia proposals from 154 different users.
- There have been 4,704  up/down votes on comments from  151  different voting users.

![Participation rates in proposal votes](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-proposals-participation.png)

There is yet to be a proposal with less than 20% voter turnout, probably related to the minimum quorum requirement of 20%. Above the average the distribution is more stretched, with a number of proposals having >40% turnout and the first Ditto proposal breaking 50%. 

![Approval rates for Politeia Proposals](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-proposals-approval.png)

Most of the approved proposals had high approval levels. The approval threshold is 60%, but 18 of 25 approved proposals had > 80%, 13 had >90% approval.



![Number of proposals relating to each domain](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-proposals-domain.png)

This is based on my own quick categorization of the proposals. Aside from a lot of marketing proposals there is a roughly even mix of other types.

![Outcomes for proposals in each domain](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-proposals-domain-state.png)

Marketing proposals are less likely to be approved than other types like Software Development, Research and Policy proposals. Underlying these figures are a number of highly speculative marketing proposals, most of the proposals I classified as Misc are also speculative bordering on shower thoughts.

The next chart presents the same information but broken down by whether the proposal author was a contractor at the time of the proposal's submission.

![Proposals by contractors and people who were not contractors](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-proposals-contractor-domain.png)

It is interesting to note that there are quite a few proposals from people who were already a contractor when they submitted the proposal, around 35% of proposals are from contractors. Proposals from contractors are also more likely to be approved. This is I think quite illustrative of one side of Politeia, where it serves as a way for the stakeholders to give their continued backing to the contractors who are active in important areas of the project. When contractors reach a point where they need to make a proposal about something, stakeholders are usually supportive of those proposals (e.g. DEX, Marketing and Events budgets). 

This scatterplot shows all the proposals, positioned according to their turnout and approval, size determined by max cost and colored by domain. It does not include Abandoned or Live proposals.

![Scatterplot showing approval, turnout, cost and domain for proposals that have been voted on](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-proposals-scatterplot.png)

The cost data is quite weak because there are often contingencies within proposals where the amount that is eventually billed for depends on some unknown factors (usually how long it takes to finish something). I have assigned maximum dollar costs to proposals based on reading the proposal and calculating (roughly) the most expensive scenario. 

![Scatterplot showing proposed budget and duration](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-proposals-cost-duration.png)

More expensive proposals tend to relate to projects that specify a longer timeline for delivery, unsurprisingly. The graph above excludes 2 proposals from REUM that requested budgets in excess of $1 million, one for a duration of several years - the first of these was rejected with 4% approval, the second was abandoned.

The mean number of comments per proposal is 30, and discussion tends to be most active shortly after a proposal is published. 35% of the comments are made within the first 2 days after a proposal is published, 61% within the first 5 days, and 82% within the first 10. Some proposals have lengthy discussion periods though, with the longest so far running for 85 days. In the following graphs I have cut it off at 40 days.

![Timing of Politeia Comments](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-comment-timing.png)

The votes on comments tend to come in a little more slowly, with 20% within the first 2 days after a proposal is published, 42% within 5 days and 72% within 10 days.

![Timing of comment votes](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/Politeia-comment-vote-timing.png)

To finish up the report there is a copy of the proposal outcomes ordered by time graph and the top Politeia contributors table. 

![Proposal participation and approval rates, ordered by time of vote](C:/Users/richa/Documents/GitHub/bc/content/publication/politeia-at-1/proposal-participation-and-approval-in-order.png)

Politeia makes user commenting and up/down voting data publicly [available](https://github.com/decred-proposals/mainnet/). Below are the top 30 users ordered by comments score (they had the most upvoted comments) in Politeia's first year. Full table [here](https://github.com/RichardRed0x/pi-research/blob/master/analysis/pi-at-1/pi-users-year1.csv).

| username     | comments | upvotes | downvotes | comments score | score per comment | proposals |
| ------------ | -------- | ------- | --------- | -------------- | ----------------- | --------- |
| bee          | 191      | 995     | 42        | 377            | 1.97              | 0         |
| jy-p         | 58       | 145     | 42        | 234            | 4.03              | 3         |
| richard-red  | 74       | 205     | 9         | 228            | 3.08              | 5         |
| ryanzim      | 64       | 144     | 62        | 194            | 3.03              | 0         |
| jz_bz        | 39       | 170     | 2         | 168            | 4.31              | 1         |
| s_ben        | 46       | 136     | 0         | 126            | 2.74              | 0         |
| nnnko56      | 22       | 14      | 12        | 113            | 5.14              | 0         |
| degeri       | 41       | 84      | 12        | 106            | 2.59              | 2         |
| oregonisaac  | 30       | 40      | 3         | 99             | 3.3               | 2         |
| dz_          | 27       | 92      | 18        | 90             | 3.33              | 0         |
| _checkmate_  | 28       | 11      | 0         | 86             | 3.07              | 1         |
| betterfuture | 41       | 58      | 8         | 83             | 2.02              | 2         |
| davecgh      | 14       | 5       | 0         | 79             | 5.64              | 1         |
| nottrunner   | 20       | 39      | 6         | 72             | 3.6               | 0         |
| praxis       | 13       | 68      | 11        | 72             | 5.54              | 0         |
| sambiohazard | 29       | 53      | 5         | 61             | 2.1               | 0         |
| fiach.dubh   | 15       | 47      | 0         | 54             | 3.6               | 0         |
| i2trading    | 17       | 0       | 0         | 53             | 3.12              | 1         |
| dustorf      | 16       | 21      | 5         | 46             | 2.88              | 2         |
| blainr       | 19       | 0       | 0         | 42             | 2.21              | 1         |
| lizbagot     | 13       | 0       | 0         | 42             | 3.23              | 1         |
| karamble     | 15       | 13      | 1         | 40             | 2.67              | 1         |
| chappjc      | 11       | 40      | 0         | 37             | 3.36              | 1         |
| guang        | 8        | 2       | 0         | 37             | 4.62              | 0         |
| david        | 7        | 65      | 3         | 36             | 5.14              | 0         |
| matheusd     | 7        | 12      | 1         | 34             | 4.86              | 0         |
| linnutee     | 10       | 14      | 3         | 34             | 3.4               | 0         |
| gravityz3r0  | 8        | 5       | 3         | 32             | 4                 | 0         |
| politicon    | 39       | 74      | 10        | 30             | 0.77              | 0         |
| rickshaw     | 32       | 44      | 0         | 29             | 0.91              | 0         |