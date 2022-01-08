#!/bin/bash

set -ex

# Raw Data Directory
rawdatarepo="/tmp/dataset/data"

# Working Directory
datarepo="/tmp/dataset/data_ml"

# Hadoop Directory
hdfsrepo="data/data_ml"

# Final Result
finalresult="/tmp/dataset/data_ml/final_result.txt"

# echo =======================
# echo == PREPARING DATASET ==
# echo =======================
rm -rf $datarepo
mkdir $datarepo
cp -rf $rawdatarepo/* $datarepo
chmod a+rw -R $datarepo

# echo ====================================
# echo == COPYING DATA TO HDFS DIRECTORY ==
# echo ====================================
hadoop dfs -rmr data
hadoop dfs -put $datarepo/ $hdfsrepo/

# echo =============================================
# echo == CONVERTING TO SEQUENCE FORMAT FROM DATA ==
# echo =============================================
mahout seqdirectory \
    -i $hdfsrepo/ \
    -o $hdfsrepo/data_seq \
    -c UTF-8 \
    -chunk 6

# echo ========================================================
# echo == CONVERTING SEQUENCE FORMAT TO SPARSE VECTOR FORMAT ==
# echo ========================================================
mahout seq2sparse \
    -i $hdfsrepo/data_seq \
    -o $hdfsrepo/data_vectors \
    -lnorm -nv -wt tfidf

### Tips for constructing the K-Means Model
#	-i  input files directory
#	-c  centroids directory
#	-o  output directory
#	-k  number of clusters
#	-ow overwrite 
#	-x  number of iterations
#	-dm distance measurement
#	-cl clustering

# echo ==================================
# echo == CREATING TWO K-MEANS CLUSTER ==
# echo ==================================
mahout kmeans \
    -i $hdfsrepo/data_vectors/tfidf_vectors/  \
    -c $hdfsrepo/data_kmeansSeed  \
    -o $hdfsrepo/data_clusters   \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure  \
    - -clustering  -cl  -cd  0.1  -x  10  -k  2  -ow

# echo ===============================================
# echo == PRINTING, WRITING AND INTERPRETING RESULT ==
# echo ===============================================
mahout clusterdump \
    -i $hdfsrepo/data_clusters/clusters-4-final \
    -o $finalresult \
    -p $hdfsrepo/data_clusters/clusteredPoints \
    -d $hdfsrepo/data_vectors/dictionary.file-* \
    -dt sequencefile -n 20 -b 100

# echo ============================
# echo == VISUALIZE THE CLUSTERS ==
# echo ============================
cat $finalresult

# echo ==============================
# echo == FUZZY K-MEANS CLUSTERING ==
# echo ==============================

# kmeanseed=$hdfsrepo/data_kmeansSeed
# clusters=$hdfsrepo/data_clusters
# finalcluster=$clusters/clusters-*-final
# distmetric=org.apache.mahout.common.distance.SquaredEuclideanDistanceMeasure
# tfidfvectors=$hdfsrepo/data_vectors/tfidf_vectors
# dict=$hdfsrepo/data_vectors/dictionary.file-*
# fkmeans=$hdfsrepo/data-fkmeans-dump

# mahout fkmeans \
#     -cd 1.0 -k 21 -m 2 -ow -x 10 \
#     -dm $distmetric \
#     -i $tfidfvectors \
#     -c $kmeanseed \
#     -o $clusters

# mahout clusterdump \
#     -b 10 -n 10 \
#     -dt sequencefile \
#     -d $dict \
#     -i $finalcluster \
#     -o $fkmeans

exit 0