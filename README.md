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

- Charts of the type @snr01 has been making for some proposals, showing the timing of incoming Yes/No votes - there should be a script which can generate this for any proposal
- Auto-generated proposal vote outcome figures for use in Politeia Digest 
- Analysis of user activity on the proposals site - comments and up/down votes. Would be possible to generate tables showing activity per user. Whether this is desirable should be discussed, they could be interpreted as "leaderboards" and gamed as such.
- Analysis of temporal dynamics on proposals site - when are proposals being actively discussed

This is an open list, if you have ideas let us know.

