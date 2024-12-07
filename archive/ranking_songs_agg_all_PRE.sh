#!/bin/bash

tar -xvf ranking_songs.tar
ls
for i in $(echo {1..200}); do echo ${i}; done > ranks
