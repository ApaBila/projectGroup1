#!/bin/bash

## shell script to run any given R script in submitted condor job, without any input to Rscript

Rscript $1 1>&2
