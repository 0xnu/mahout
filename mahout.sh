#!/bin/bash

K=4
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

# echo ==================================
# echo == CREATING TWO K-MEANS CLUSTER ==
# echo ==================================
mahout kmeans \
    -i $hdfsrepo/data_vectors/tfidf_vectors/  \
    -c $hdfsrepo/data_kmeansSeed  \
    -o $hdfsrepo/data_clusters   \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure  \
    - -clustering  -cl  -cd  0.1  -x  10  -k  2  -ow

# echo =====================
# echo == PRINTING OUTPUT ==
# echo =====================
# mahout clusterdump \
#     -i  $hdfsrepo/data_clusters/clusters-0 \
#     -o  $finalresult \
#     -d  $hdfsrepo/data_vectors/dictionary.file-0 \
#     -b  100 \
#     -p  $hdfsrepo/data_clusters/clusteredPoints \
#     -dt  sequencefile   -n  20

# cat $finalresult

# echo ===============================================
# echo == PRINTING, WRITING AND INTERPRETING RESULT ==
# echo ===============================================
mahout clusterdump \
    -i $hdfsrepo/data_vectors/clusters-4-final \
    -o $finalresult \
    -p $hdfsrepo/data_vectors/clusteredPoints \
    -d $hdfsrepo/data_vectors/dictionary.file-0 \
    -dt sequencefile -n 20 -b 100

cat $finalresult

exit 0