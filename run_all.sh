#!/bin/bash
START=$(date +%s)
echo $START

for i in $(ls by_region/); do
    echo ${i} | sed -e "s/.csv//g"
done > csvs
for i in $(cat csvs); do
    Rscript AF_across_region.R ${i}
done
Rscript AF_across_region_agg.R

echo "United_States                                                                                                            
Australia" > 2_csvs
for i in $(cat 2_csvs); do
    Rscript AF_across_time.R ${i}
done

for i in $(cat csvs); do
    Rscript ranking_songs.R ${i}
done
Rscript ranking_songs_agg.R
for i in $(cat csvs); do
    Rscript ranking_artists.R ${i}
done
Rscript ranking_artists_agg.R

echo "United_States                                                                                                            
Global" > 2_csvs
for i in $(cat 2_csvs); do
    Rscript ranking_seasonal.R ${i}
done

END=$(date +%s)
DIFF=$(( END - START ))
echo "Execution time: $DIFF seconds"
