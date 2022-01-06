#!/bin/bash
# [Apache Mahout Machine Learning Installer]

[ `whoami` = root ] || exec su -c $0 root
ls /root

# Define echo functions
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 9)
green=$(tput setaf 10)
yellow=$(tput setaf 11)
blue=$(tput setaf 12)
purple=$(tput setaf 13)
lblue=$(tput setaf 14)
white=$(tput setaf 15)


cat <<!
${bold}Apache Mahout Machine Learning Installation${normal}
Supports ONLY Ubuntu 16.04+
Author: Finbarrs Oketunji <f@finbarrs.eu>
Installs Java, Scala, Python, Apache Hadoop, Apache Mahout, and Apache Spark
!


# echo ======================
# echo == PREPARING UBUNTU ==
# echo ======================
echo -ne "${blue} Executing apt update, please wait..."
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends lubuntu-desktop
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
echo "${white} done"
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt-get update
sudo apt-get install -y ros-kinetic-desktop-full
sudo rosdep init
rosdep update
echo "${green} Done ;)"


echo =========================================
echo ==  INSTALLING Java, Python and Scala  ==
echo =========================================
echo -ne "${blue} Installing Java, please wait..."
sudo apt install default-jdk default-jre expect python3-pip scala -y
echo "${green} Done ;)"


echo ================================
echo ==  INSTALLING Apache Hadoop  ==
echo ================================
echo -ne "${blue} Installing Apache Hadoop, please wait..."
sudo wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz &>> /dev/null
tar -xvzf hadoop-3.3.1.tar.gz &>> /dev/null
rm -rf hadoop-3.3.1.tar.gz &>> /dev/null
sudo mv hadoop-3.3.1 /usr/local/hadoop
sudo mkdir /usr/local/hadoop/logs
echo "export HADOOP_HOME=/usr/local/hadoop" >> ~/.bashrc
echo "export HADOOP_INSTALL=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export YARN_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native" >> ~/.bashrc
echo "export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin" >> ~/.bashrc
echo "export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"" >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bashrc
echo "export HADOOP_CLASSPATH+="$HADOOP_HOME/lib/*.jar"" >> ~/.bashrc
source ~/.bashrc
echo "${green} Done ;)"


echo -ne "${blue} Configuring Java Environment Variables, please wait..."
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bashrc
echo "export HADOOP_CLASSPATH+=$HADOOP_HOME/lib/*.jar" >> ~/.bashrc
echo "${green} Done ;)"

echo -ne "${blue} Downloading the Javax activation file, please wait..."
cd /usr/local/hadoop/lib
sudo wget https://jcenter.bintray.com/javax/activation/javax.activation-api/1.2.0/javax.activation-api-1.2.0.jar &>> /dev/null
cd ~
echo "${green} Done ;)"


echo -ne "${blue} Editing the core-site.xml configuration file, please wait..."
sudo rm -rf /usr/local/hadoop/etc/hadoop/core-site.xml
sudo touch /usr/local/hadoop/etc/hadoop/core-site.xml
cat >> /usr/local/hadoop/etc/hadoop/core-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
   <property>
      <name>fs.default.name</name>
      <value>hdfs://0.0.0.0:9000</value>
      <description>The default file system URI</description>
   </property>
</configuration>
EOF
echo "${green} Done ;)"


echo -ne "${blue} Creating a directory for storing node metadata and changing the ownership to root, please wait..."
sudo mkdir -p /home/hadoop/hdfs/{namenode,datanode}
sudo chown -R root:root /home/hadoop/hdfs
echo "${green} Done ;)"


echo -ne "${blue} Editing hdfs-site.xml configuration file to define the location for storing node metadata, fs-image file, please wait..."
sudo rm -rf /usr/local/hadoop/etc/hadoop/hdfs-site.xml
sudo touch /usr/local/hadoop/etc/hadoop/hdfs-site.xml
cat >> /usr/local/hadoop/etc/hadoop/hdfs-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
   <property>
      <name>dfs.replication</name>
      <value>1</value>
   </property>

   <property>
      <name>dfs.name.dir</name>
      <value>file:///home/hadoop/hdfs/namenode</value>
   </property>

   <property>
      <name>dfs.data.dir</name>
      <value>file:///home/hadoop/hdfs/datanode</value>
   </property>
</configuration>
EOF
echo "${green} Done ;)"


echo -ne "${blue} Editing mapred-site.xml configuration file to define MapReduce values, please wait..."
sudo rm -rf /usr/local/hadoop/etc/hadoop/mapred-site.xml
sudo touch /usr/local/hadoop/etc/hadoop/mapred-site.xml
cat >> /usr/local/hadoop/etc/hadoop/mapred-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
   <property>
      <name>mapreduce.framework.name</name>
      <value>yarn</value>
   </property>
</configuration>
EOF
echo "${green} Done ;)"


echo -ne "${blue} Editing the yarn-site.xml configuration file and define YARN-related settings, please wait..."
sudo rm -rf /usr/local/hadoop/etc/hadoop/yarn-site.xml
sudo touch /usr/local/hadoop/etc/hadoop/yarn-site.xml
cat >> /usr/local/hadoop/etc/hadoop/yarn-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
   <property>
      <name>yarn.nodemanager.aux-services</name>
      <value>mapreduce_shuffle</value>
   </property>
</configuration>
EOF
echo "${green} Done ;)"


echo -ne "${blue} Validating the Hadoop configuration and format the HDFS NameNode, please wait..."
hdfs namenode -format
echo "${green} Done ;)"


echo -ne "${blue} Run Hadoop as root, please wait..."
echo "export HDFS_NAMENODE_USER="root"" >> ~/.bashrc
echo "export HDFS_DATANODE_USER="root"" >> ~/.bashrc
echo "export HDFS_SECONDARYNAMENODE_USER="root"" >> ~/.bashrc
echo "export YARN_RESOURCEMANAGER_USER="root"" >> ~/.bashrc
echo "export YARN_NODEMANAGER_USER="root"" >> ~/.bashrc
echo "${green} Done ;)"


echo ================================
echo ==  INSTALLING Apache Mahout  ==
echo ================================
echo -ne "${blue} Downloading Apache Mahout, please wait..."
sudo wget https://downloads.apache.org/mahout/0.13.0/apache-mahout-distribution-0.13.0.tar.gz &>> /dev/null
echo "${white} Done ;)"
echo "${red} Extracting and Installing Apache Mahout, please wait..."
tar xvzf apache-mahout-distribution-0.13.0.tar.gz &>> /dev/null
rm -rf apache-mahout-distribution-0.13.0.tar.gz &>> /dev/null
sudo mv apache-mahout-distribution-0.13.0 mahout
sudo mv mahout /usr/local/
export MAHOUT_HOME=/usr/local/mahout
export PATH=$PATH:$MAHOUT_HOME/bin
echo "${green} Done ;)"


echo ===============================
echo ==  INSTALLING Apache Spark  ==
echo ===============================
echo -ne "${blue} Downloading Apache Spark, please wait..."
sudo wget https://downloads.apache.org/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz &>> /dev/null
echo "${white} Done ;)"
echo "${red} Extracting and Installing Apache Spark, please wait..."
sudo mkdir /opt/spark
sudo tar -xf spark*.tgz -C /opt/spark --strip-component 1 &>> /dev/null
sudo chmod -R 777 /opt/spark
echo "export SPARK_HOME=/opt/spark" >> ~/.bashrc
echo "export PATH=$PATH:/opt/spark/bin:/opt/spark/sbin" >> ~/.bashrc
echo "export PYSPARK_PYTHON=/usr/bin/python3" >> ~/.bashrc
source ~/.bashrc


echo -ne "${blue} Starting the Apache Hadoop Cluster, please wait..."
echo "${red} Starting the NameNode and DataNode."
start-dfs.sh
echo "${white} Done ;)"
echo "${red} Starting the YARN resource and node managers."
start-yarn.sh
echo "${green} Done ;)"


## Start all at once
start-all.sh


echo "${green} Done ;)"


# DONE
echo "${bold}Installation and Configuration Done ;)"
exit 0