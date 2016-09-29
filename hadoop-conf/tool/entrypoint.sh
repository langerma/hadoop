#! /bin/bash

if [ "$HADOOP_ROLE" == "NAMENODE1" ] ; then
  if [ ! -f /data/hdfs/runonce.lock ]; then
    if [ ! -d /data/hdfs/namenode ]; then
      echo "NO DATA IN /data/hdfs/namenode"
      echo "FORMATTING NAMENODE"
      hdfs namenode -format || { echo 'FORMATTING FAILED' ; exit 1; }
    fi
    touch /data/hdfs/runonce.lock
  fi
  export HADOOP_ROLE="NAMENODE1"
  hadoop-daemon.sh start zkfc
  hdfs namenode
elif [ "$HADOOP_ROLE" == "NAMENODE2" ] ; then
  if [ ! -f /data/hdfs/runonce.lock ]; then
    if [ ! -d /data/hdfs/namenode ]; then
      echo "NO DATA IN /data/hdfs/namenode"
      echo "SYNCING DATA FROM NAMENODE1"
      hdfs namenode -bootstrapStandby
    fi
    touch /data/hdfs/runonce.lock
  fi
  export HADOOP_ROLE="NAMENODE"
  hadoop-daemon.sh start zkfc
  hdfs namenode
elif [ "$HADOOP_ROLE" == "HMASTER" ]; then
  if [ ! -f /usr/local/hbase/runonce.lock ]; then
    cp /etc/hosts /etc/hosts.old
    sed -e \"s/.*`hostname`/`curl -s http://rancher-metadata/latest/self/container/ips/0` `hostname`/g\" /etc/hosts.old > /etc/hosts
  fi
  touch /usr/local/hbase/runonce.lock
  hbase hmaster start
elif [ "$HADOOP_ROLE" == "HREGIONSERVER" ]; then
  if [ ! -f /usr/local/hbase/runonce.lock ]; then
    cp /etc/hosts /etc/hosts.old
    sed -e \"s/.*`hostname`/`curl -s http://rancher-metadata/latest/self/container/ips/0` `hostname`/g\" /etc/hosts.old > /etc/hosts
  fi
  touch /usr/local/hbase/runonce.lock
  hbase regionserver start
fi