# pi-research

This repository is for organizing data, analyses and visualizations related to Decred's Politeia. 

## Purpose

Understand and track the activity on Politeia. A better understanding of how the proposals site and voting are being used will inform decisions about how Pi is developed.

## Products

- Processed data from Politeia available to all in accessible forms
- Reproducible analyses, statistics and charts
- Write-ups that offer interpretation of the data

## Plan

The first step is to develop methods of transforming the data from the .journal and .md files in which it is stored into more workable formats - csv as a starting point. 

@s_ben is [working on](https://github.com/s-ben/piparser) python scripts which will generate csv tables from the raw data on GitHub. The intention is to make the scripts themselves available on GitHub along with ready to download csv files. 

@snr01 has been [preparing](https://github.com/snr01/DecredAnalytics) data-sets and charts while proposals have been actively voting.

@richardred has prepared [data](data/) about comments and comment votes, along with some initial [analyses](analysis/comments-analysis-writeup-2018-11-19.md).

#### Analyses

- Charts of the type @snr01 has been making for some proposals, showing the timing of incoming Yes/No votes - there should be a script which can generate this for any proposal - see plot.proposal and plot.proposals functions in [functions file](data-collection/functions-pi-analysis.R), example charts in this [folder](analysis/voting/img/).
- Auto-generated proposal vote outcome figures for use in Politeia Digest - see journal-pi.md, pi-digest-output.md and twitter-result-output.md in [analysis folder](analysis/), the production of these statements is now almost entirely automated using functions and some processing steps. Remains to be tidied up.
- Analysis of user activity on the proposals site - comments and up/down votes. Would be possible to generate tables showing activity per user. Whether this is desirable should be discussed, they could be interpreted as "leaderboards" and gamed as such. See [file](data/comments-and-updown-votes/pi-users-comments-votes.csv) for latest dump of this information.
- Analysis of temporal dynamics on proposals site - when are proposals being actively discussed? 
- Analysis of temporal dynamics in ticket voting - do big blocks of early votes influence subsequent voter behavior?
- Link ticket age/purchased in same block to Pi votes - any sign that big ticket purchases happen ahead of big votes for the purpose of voting? See this [conversation](https://matrix.to/#/!vGasNHFXqjoEWUBTIi:decred.org/$155188192918282xOeYd:decred.org?via=decred.org&via=matrix.org&via=zettaport.com) for impetus. Work not yet started.

This is an open list, if you have ideas let us know.

