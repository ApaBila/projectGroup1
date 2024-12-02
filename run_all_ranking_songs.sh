#!/bin/bash
for i in $(ls by_region/); do
   echo ${i} | sed -e "s/.csv//g"
done > csvs
for i in $(cat csvs); do
    Rscript ranking_songs.R ${i}
done