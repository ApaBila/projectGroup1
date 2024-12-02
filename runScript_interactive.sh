#!/bin/bash

## shell script to run any given R script in a submitted condor job
## takes script name, file name as inputs

Rscript $1 $2 1>&2 
