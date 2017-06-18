#!/bin/bash
# Install Hadoop 2 using pdsh/pdcp where possible.
# 
# Command can be interactive or file-based.  This script sets up
# a Hadoop 2 cluster with basic configuration.  Modify data, log, and pid
# directories as desired.  Further configure your cluster with ./conf-hadoop2.sh
# after running this installation script.
#

# Basic environment variables.  Edit as necessary
# zookeeper-3.4.8.tar.gz
#http://apache.mirror.cdnetworks.com/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz

JDK_VERSION=1.8.0_131
JDK_RPM_NAME=jdk-8u131-linux-x64.rpm
JDK_DOWNLOAD_URI="http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/${JDK_RPM_NAME}"
## wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"


#ZOOKEEPER_VERSION=3.4.9
ZOOKEEPER_VERSION=3.4.6 
ZOOKEEPER_DOWNLOAD_URI="http://mirror.navercorp.com/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz"
ZOOKEEPER_HOME="/opt/zookeeper-${ZOOKEEPER_VERSION}"
ZOOKEEPER_LOG_DIR="/var/log/zookeeper"
ZOOKEEPER_PREFIX="${ZOOKEEPER_HOME}"

ZOOKEEPER_CONF_DIR="${ZOOKEEPER_HOME}/conf"
ZOOKEEPER_DATA_DIR="/var/data/zookeeper"

DFS_NAMESERVICES=big-cluster
HA_ZOOKEEPER_QUORUM=big01:2181,big02:2181,big03:2181

## default /var/data/hadoop/jounal/data --- 이렇게 생성되는디....  그래서 설정을 바꾼다. 
## HBase는 클라이언트에게 ZK 접근을 허락하고, Hadop은 클라이언트에게 ZK접근을 허락하지 않는다. 
# 따라서 크러스터 밖에서 원격으로 Hadoop을 사용하려면, 관련 설정정보 (XML)이 클라이언트 쪽에 배포되어야 한다. 
# 이런 이슈는 보안의 이슈과 관련되며, ZK에 대한 접근권한 관리를 한든지, 클러스터 노드들에 대한 Proxy를 구성하는지 등에 대한 안이 있어야 한다. 
# 금융권에서는 이러한 이슈가 더욱 중요한다. 

## default /var/data/hadoop/jounal/data --- 이렇게 생성되는디....  그래서 설정을 바꾼다. 
JN_EDITS_DIR=/var/data/hadoop/jounal

# Journal node group for NameNodes will wite/red edits
NAMENODE_SHARED_EDITS_DIR="qjournal://big01:8485;big02:8485;big03:8485/${DFS_NAMESERVICES}-journal"


#   HADOOP_CONF_DIR  Alternate conf dir. Default is ${HADOOP_PREFIX}/conf.
#   HADOOP_LOG_DIR   Where log files are stored.  PWD by default.
#   --HADOOP_MASTER    host:path where hadoop code should be rsync'd from
#   HADOOP_PID_DIR   The pid files are stored. /tmp by default.
#   --HADOOP_IDENT_STRING   A string representing this instance of hadoop. $USER by default
#   --HADOOP_NICENESS The scheduling priority for daemons. Defaults to 0.

#   YARN_CONF_DIR  Alternate conf dir. Default is ${HADOOP_YARN_HOME}/conf.
#   YARN_LOG_DIR   Where log files are stored.  PWD by default.
#   --YARN_MASTER    host:path where hadoop code should be rsync'd from
#   YARN_PID_DIR   The pid files are stored. /tmp by default.
#   --YARN_IDENT_STRING   A string representing this instance of hadoop. $USER by default
#   --YARN_NICENESS The scheduling priority for daemons. Defaults to 0.

#   HADOOP_JHS_LOGGER  Hadoop JobSummary logger.
#   HADOOP_CONF_DIR  Alternate conf dir. Default is ${HADOOP_MAPRED_HOME}/conf.
#   HADOOP_MAPRED_PID_DIR   The pid files are stored. /tmp by default.
#   --HADOOP_MAPRED_NICENESS The scheduling priority for daemons. Defaults to 0.



#HADOOP_VERSION=2.7.2
HADOOP_VERSION=2.7.3
HADOOP_DOWNLOAD_URI="http://apache.tt.co.kr/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
HADOOP_HOME="/opt/hadoop-${HADOOP_VERSION}"
NN_DATA_DIR=/var/data/hadoop/hdfs/nn
DN_DATA_DIR=/var/data/hadoop/hdfs/dn
YARN_LOG_DIR=/var/log/hadoop/yarn
HADOOP_LOG_DIR=/var/log/hadoop/hdfs
HADOOP_MAPRED_LOG_DIR=/var/log/hadoop/mapred
YARN_PID_DIR=/var/run/hadoop/yarn
HADOOP_PID_DIR=/var/run/hadoop/hdfs
HADOOP_MAPRED_PID_DIR=/var/run/hadoop/mapred
HTTP_STATIC_USER=hdfs
YARN_PROXY_PORT=8081
HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop


## VM Memory management by warmpark add.
YARN_NODEMANAGER_HEAPSIZE=308



#### HBASE 
#HBASE_VERSION=1.2.6
HBASE_VERSION=1.1.10
HBASE_DOWNLOAD_URI="http://apache.tt.co.kr/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz"
##http://apache.mirror.cdnetworks.com/hbase/1.2.6/hbase-1.2.6-bin.tar.gz
HBASE_HOME="/opt/hbase-${HBASE_VERSION}"
HBASE_LOG_DIR="/var/log/hbase"
HBASE_PREFIX="${HBASE_HOME}"
HBASE_CONF_DIR="${HBASE_HOME}/conf"
HBASE_DATA_DIR="/var/data/hbase"
HBASE_MANAGES_ZK=false
HBASE_PID_DIR=/var/run/hbase


pdsh -w ^all_hosts "source /etc/profile.d/java.sh"
pdsh -w ^all_hosts "source /etc/profile.d/hadoop.sh"
pdsh -w ^zk_hosts  "source /etc/profile.d/zookeeper.sh"
pdsh -w ^all_hosts "source /etc/profile.d/hbase.sh"

pdsh -w ^all_hosts "source $HADOOP_CONF_DIR/hadoop-env.sh"	
pdsh -w ^all_hosts "source $HADOOP_CONF_DIR/yarn-env.sh"
pdsh -w ^all_hosts "source $HADOOP_CONF_DIR/mapred-env.sh"
pdsh -w ^all_hosts "source $HBASE_CONF_DIR/hbase-env.sh"



echo "PID DIR를 항상 만들어 주어야 하는가? Creating pid directories on all hosts..."
pdsh -w ^all_hosts "mkdir -p $YARN_PID_DIR && chown -R yarn:hadoop $YARN_PID_DIR"
pdsh -w ^all_hosts "mkdir -p $HADOOP_PID_DIR && chown -R hdfs:hadoop $HADOOP_PID_DIR"
pdsh -w ^all_hosts "mkdir -p $HADOOP_MAPRED_PID_DIR && chown -R mapred:hadoop $HADOOP_MAPRED_PID_DIR"
pdsh -w ^all_hosts "mkdir -p $HBASE_PID_DIR && chown -R hdfs:hadoop $HBASE_PID_DIR"


echo "#1. Start ZK Quarum Daemon(su - hdfs -c '$ZOOKEEPER_HOME/bin/zkServer.sh start') :모든 ZK에서:  3,5 ... 홀수개수로 "
pdsh -w ^zk_hosts "su - hdfs -c '$ZOOKEEPER_HOME/bin/zkServer.sh start'"

#echo "#2. ZK 내에 NameNode 이중화 관련 ZK 정보 초기화(su - hdfs -c '$HADOOP_HOME/bin/hdfs zkfc -formatZK'):Active NameNode 후보에서만: 반드시 ZK 가 실행 중이어야 함"
#pdsh -w ^nn_host "su - hdfs -c '$HADOOP_HOME/bin/hdfs zkfc -formatZK'"

echo "#3. Start JournalNode Daemon(su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start journalnode'):모든 JN에서: ZK Node와 동일하게 설치해야 하나? 그럴 필요 없어요 : 3,5 ... 홀수개"
pdsh -w ^jn_hosts "su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start journalnode'"

#echo "#4. Active Name Node  포멧(su - hdfs -c '$HADOOP_HOME/bin/hdfs namenode -format'):Active NameNode 후보에서만: 저널노드가 실행되고 있어야 함"
#pdsh -w ^nn_host "su - hdfs -c '$HADOOP_HOME/bin/hdfs namenode -format'"

echo "#5. Start DataNode Daemon(su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh  start datanode'):모든 DN에서:"
pdsh -w ^dn_hosts "su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh  start datanode'"

echo "#6. Start Active NameNode Daemon(su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode')"
pdsh -w ^nn_host "su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode'"


echo "#7. Start ZK Failover Controller Daemon(su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start zkfc'):각 Name Node 마다:Name Node와 ZKFC의 실행 순서는 중요하지 않음. "
pdsh -w ^nn_host "su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start zkfc'"
pdsh -w ^snn_host "su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start zkfc'"

#echo "#8. Active Name Node의 filesystem 데이터를 Stand-by Name Node로 복사(su - hdfs -c '$HADOOP_HOME/bin/hdfs namenode -bootstrapStandby') :Stand-by Name Node에서만:"
#pdsh -w ^snn_host "su - hdfs -c '$HADOOP_HOME/bin/hdfs namenode -bootstrapStandby'"


echo "#9. Start Stand-by NameNode Daemon(su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode') : Stand-by NN에서 : "
pdsh -w ^snn_host "su - hdfs -c '$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode'"


##. Name Node의 데이터를 Journal Node에 초기화 (Stand-by Name Node에서 실행) : hdfs namenode -initializeSharedEdits"
## 이부분은 나중에 수행 된 후 어떤 녀석이 Active인지 확인하고 해 주면 OK. ...  : 사용할 필요가 없을 듯..  초기 설치시.....에는 
#pdsh -w ^snn_host "su - hdfs -c '$HADOOP_HOME/bin/hdfs namenode -initializeSharedEdits'"

echo "## 이하   yarn "
echo "#10. Start resource manager(su - yarn -c '$HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager'):RM에서: "
pdsh -w ^rm_host "su - yarn -c '$HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager'"
echo "#11. Start NodeManagers(su - yarn -c '$HADOOP_HOME/sbin/yarn-daemon.sh  start nodemanager'): NM에서 : NM은 DN이 있으면 하나씩 "
pdsh -w ^nm_hosts "su - yarn -c '$HADOOP_HOME/sbin/yarn-daemon.sh  start nodemanager'"

echo "#12. Start proxy server(su - yarn -c '$HADOOP_HOME/sbin/yarn-daemon.sh start proxyserver') "
pdsh -w ^yarn_proxy_host "su - yarn -c '$HADOOP_HOME/sbin/yarn-daemon.sh start proxyserver'"

	   
#echo "#13.Creating MapReduce Job History directories... mr-jobhistory-daemon.sh  start historyserver 수행하기 위해 필수..."
#su - hdfs -c "hdfs dfs -mkdir -p /mapred/history/done_intermediate"
#su - hdfs -c "hdfs dfs -chown -R mapred:hadoop /mapred"
#su - hdfs -c "hdfs dfs -chmod -R g+rwx /mapred"

echo "#14. Start History Server(su - mapred -c '$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh  start historyserver') "
pdsh -w ^mr_history_host "su - mapred -c '$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh  start historyserver'"

echo "#15. Start HBASE Server(su - hbase -c '$HBASE_HOME/bin/start-hbase.sh') "
pdsh -w ^nn_host "su - hdfs -c '$HBASE_HOME/bin/hbase-daemon.sh start master'"
pdsh -w ^hbase_regionservers "su - hdfs -c '$HBASE_HOME/bin/hbase-daemon.sh start regionserver'"

echo "#16. Running YARN smoke test..."
#export HADOOP_VERSION=2.7.3
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-$HADOOP_VERSION.jar pi -Dmapreduce.clientfactory.class.name=org.apache.hadoop.mapred.YarnClientFactory -libjars $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-$HADOOP_VERSION.jar 16 10000



