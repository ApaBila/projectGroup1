#!/bin/bash

echo "You have reached the post file"
mkdir -p AF_across_region
mv *_af.rds AF_across_region
tar -cvf AF_across_region.tar AF_across_region
rm -r AF_across_region
