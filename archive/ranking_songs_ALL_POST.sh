#!/bin/bash

ls
mkdir -p ranking_songs
mv *_ranking_songs.rds ranking_songs/
tar -cvf ranking_songs.tar ranking_songs