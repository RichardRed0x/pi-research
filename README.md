# pi-research

This repository is for organizing data, analyses and visualizations related to Politeia (Pi), Decred's proposal site. 

## Purpose

Understand and track activity on Pi. A better understanding of how the proposals site and voting are being used will inform decisions around how Pi is developed.

## Products

- Processed data from Pi, available to all in accessible forms 
- Reproducible analyses, statistics and charts
- Write-ups that offer interpretation of Pi data

## Plan

The first step is to develop methods of transforming the `.journal` and `.md` files Pi uses to store raw data into more workable formats - .csv files as a starting point. 

@s_ben is [working on](https://github.com/s-ben/piparser) python scripts which will generate .csv tables from the raw data. The intention is to make the scripts themselves available on GitHub along with ready to download .csv files. 

The journal files have a mostly flat structure, and this should lend itself to accessible, clean csv files for different objects (proposals, proposal votes, comments, comment votes).

#### Analyses

- Charts of the type @snr01 has been making for some proposals, showing the timing of incoming Yes/No votes - there should be a script which can generate this for any proposal
- Auto-generated proposal vote outcome figures for use in Politeia Digest 
- Analysis of user activity on the proposals site - comments and up/down votes. It would be possible to generate tables showing activity per user. Whether this is desirable should be discussed, as they could be interpreted as "leaderboards" and gamed as such.
- Analysis of temporal dynamics on Pi - when are proposals being actively discussed, etc. 
