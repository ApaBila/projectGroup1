#!/bin/bash

# TLDR: This is our master shellscript. Ideally, it creates all the plots/output
# we have/need in our presentation, automatically

# Notes:
# - For all files, give permission to everyone if needed (chmod a+rwx)
# although this is bad practice in other cases
# - Order: Chenyu, Bila, Meiyi, Siyu (as in presentation)

## DATA PREPROCESSING

# Not marked as a todo for now, let's consider the files on CHTC already to save space
# Maybe: Amy/Bila - split_data_by_region.R sub file? How much memory/disk? Need merged_data.csv on CHTC
# post script: mkdir by_region; mv *.csv by_region

# TODO: Meiyi - 300k only .sh file 


## 5 TASKS: .dag .dag .dag .sub .sub

# note: meanaf.R (job 1) is now AF_across_region.R
# plots.R (job 2) is now AF_across_region_agg.R 
# old region.R -> archive
condor_submit_dag -f submit_AF_across_region.dag # Warning! Erases logs and outputs

condor_submit_dag -f submit_ranking_songs.dag # Warning! Erases logs and outputs

# TODO: Amy/Chenyu add rm TASK.tar to a script, for script post 2 to the above dags(finished by Chenyu)


# TODO: Amy, submit_ranking_artists.sub submit_ranking_artists_agg.sub submit_ranking_artists.dag


condor_submit submit_AF_across_time.sub # Only Australia & US. See queue


# TODO: Siyu/Chenyu/Meiyi condor_submit submit_5_songs_seasonal.sub (runs top_5_songs)


# Maybe: Bila - add appendix graph
