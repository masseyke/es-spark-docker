FROM ubuntu:20.04

RUN apt-get update -y && apt-get install vim -y && apt-get install wget -y && apt-get install ssh -y && apt-get install openjdk-8-jdk -y && apt-get install sudo -y && apt-get install curl -y && apt-get install jq -y
RUN useradd -m elastic && echo "elastic:supergroup" | chpasswd && adduser elastic sudo && echo "elastic     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ && sudo ln -s python3 python

COPY ssh_config /etc/ssh/ssh_config

WORKDIR /home/elastic

USER elastic
ARG HADOOP_VERSION=3.3.1
ARG SPARK_VERSION=3.2.1
ARG SPARK_HADOOP_VERSION=3.2
ARG ELASTICSEARCH_VERSION=7.17.0
ARG ES_SPARK_SPARK_VERSION=30
ARG ES_SPARK_SCALA_VERSION=2.12
ARG ES_SPARK_ES_VERSION=$ELASTICSEARCH_VERSION
ARG ES_SPARK_VERSION=${ES_SPARK_SPARK_VERSION}_$ES_SPARK_SCALA_VERSION-$ES_SPARK_ES_VERSION

RUN wget -q https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && tar zxvf hadoop-$HADOOP_VERSION.tar.gz && rm hadoop-$HADOOP_VERSION.tar.gz
RUN wget -q https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz && tar zxvf spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz && rm spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz
RUN wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz && tar zxvf elasticsearch-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz && rm elasticsearch-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz
RUN wget -q https://artifacts.elastic.co/downloads/kibana/kibana-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz && tar zxvf kibana-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz && rm kibana-$ELASTICSEARCH_VERSION-linux-x86_64.tar.gz
RUN wget -q -O ./elasticsearch-spark-$ES_SPARK_VERSION.jar https://search.maven.org/remotecontent?filepath=org/elasticsearch/elasticsearch-spark-${ES_SPARK_SPARK_VERSION}_$ES_SPARK_SCALA_VERSION/$ES_SPARK_ES_VERSION/elasticsearch-spark-$ES_SPARK_VERSION.jar
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

ENV HDFS_NAMENODE_USER elastic
ENV HDFS_DATANODE_USER elastic
ENV HDFS_SECONDARYNAMENODE_USER elastic

ENV YARN_RESOURCEMANAGER_USER elastic
ENV YARN_NODEMANAGER_USER elastic

ENV HADOOP_HOME /home/elastic/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/home/elastic/hadoop-$HADOOP_VERSION/etc/hadoop/
ENV ES_HOME /home/elastic/elasticsearch-$ELASTICSEARCH_VERSION
ENV KIBANA_HOME /home/elastic/kibana-$ELASTICSEARCH_VERSION-linux-x86_64
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo "server.host: 0.0.0.0" >> $KIBANA_HOME/config/kibana.yml
RUN echo 'alias es-spark="/home/elastic/spark-'$SPARK_VERSION'-bin-hadoop'$SPARK_HADOOP_VERSION'/bin/spark-shell --master yarn --deploy-mode client --jars /home/elastic/elasticsearch-spark-'$ES_SPARK_VERSION'.jar"' >> ~/.bashrc
RUN echo 'alias es-pyspark="/home/elastic/spark-'$SPARK_VERSION'-bin-hadoop'$SPARK_HADOOP_VERSION'/bin/pyspark --master yarn --deploy-mode client --jars /home/elastic/elasticsearch-spark-'$ES_SPARK_VERSION'.jar"' >> ~/.bashrc
COPY core-site.xml $HADOOP_HOME/etc/hadoop/
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/

COPY docker-entrypoint.sh $HADOOP_HOME/etc/hadoop/

ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22 9200 9300 5601

#ENTRYPOINT ["${HADOOP_HOME}/etc/hadoop/docker-entrypoint.sh"]
ENTRYPOINT "${HADOOP_HOME}/etc/hadoop/docker-entrypoint.sh"
