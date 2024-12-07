#!/bin/bash

## shell script to run any given R script in submitted condor job, without any input to Rscript
tar -xvf $1
ls
Rscript $2 1>&2
