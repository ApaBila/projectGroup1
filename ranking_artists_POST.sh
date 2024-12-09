#!/bin/bash

mkdir -p ranking_artists
mv *_ranking_artists.rds ranking_artists/
tar -cvf ranking_artists.tar ranking_artists
rm -r ranking_artists
