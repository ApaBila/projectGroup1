#!/bin/bash

ls
mkdir -p ranking_songs
mv *.rds ranking_songs/
tar -cvf ranking_songs.tar ranking_songs
