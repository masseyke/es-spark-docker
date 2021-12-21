# Elasticsearch Spark on YARN on Docker

This docker image lets you quickly create a development environment where you can run es-spark in a scala or python spark shell using a real (single node) YARN cluster.

## Build the docker image and start the container

     $ git clone https://github.com/masseyke/es-spark-docker.git
     $ cd es-spark-docker
     $ ./build.sh
     $ ./start.sh

That's all it takes. The build.sh command will probably take a few minutes because it is downloading Hadoop, Spark, and Elasticsearch. Once start.sh completes, you will get a command line prompt. In the prompt, just type `es-spark` to get a scala spark shell, or `es-pyspark` to get a python spark shell, and begin using es-spark interactively. For example:

     elastic@localhost:~$ es-pyspark
     Python 3.8.10 (default, Nov 26 2021, 20:14:08) 
     [GCC 9.3.0] on linux
     Type "help", "copyright", "credits" or "license" for more information.
     2021-12-21 23:12:44,365 WARN util.Utils: Your hostname, localhost resolves to a loopback address: 127.0.0.1; using 172.17.0.2 instead (on interface eth0)
     2021-12-21 23:12:44,366 WARN util.Utils: Set SPARK_LOCAL_IP if you need to bind to another address
     2021-12-21 23:12:44,712 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
     Setting default log level to "WARN".
     To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
     2021-12-21 23:12:46,563 WARN yarn.Client: Neither spark.yarn.jars nor spark.yarn.archive is set, falling back to uploading libraries under SPARK_HOME.
     Welcome to
       ____              __
      / __/__  ___ _____/ /__
      _\ \/ _ \/ _ `/ __/  '_/
     /__ / .__/\_,_/_/ /_/\_\   version 3.2.0
        /_/
     
     Using Python version 3.8.10 (default, Nov 26 2021 20:14:08)
     Spark context Web UI available at http://localhost:4040
     Spark context available as 'sc' (master = yarn, app id = application_1640127549823_0002).
     SparkSession available as 'spark'.
     >>> 

It is powered by a real single-node Elasticsearch cluster and real single-node YARN and HDFS clusters. For information on how to get started with es-spark, see https://www.elastic.co/guide/en/elasticsearch/hadoop/current/spark.html.
You can also now interact with Elasticsearch through Kibana's dev tools in a browser on your machine at http://localhost:5602/app/dev_tools#/console.
And you can access the Hadoop resource manager (useful for checking logs of failed spark jobs) at http://localhost:8088/cluster. If you have started a spark shell you will see an application named Spark shell. If you click on that link, and then on the "Application Master" link on the next page, you will get to the Spark Jobs page where you can access logs and other information. Each time you restart the spark shell you will get a different yarn application.
To exit the docker container (which will kill it):

     elastic@localhost:~$ exit

## Security
This is purely for development purposes. There is no security on the docker container, Hadoop, or Elasticsearch.

## Advanced
### Restarting services
You likely won't need to restart Hadoop, Elasticsearch, or Kibana unless you are changing some configuration that requires a restart.:
To stop and start hadoop (for example if you change some hadoop configuration), execute the following commands:

     elastic@localhost:~$ $HADOOP_HOME/sbin/stop-all.sh
     elastic@localhost:~$ $HADOOP_HOME/sbin/start-all.sh

Elasticsearch and Kibana are running as ordinary background processes using nohup. To restart them, find the process ids and kill them. You can find the commands to start them in $HADOOP_HOME/etc/hadoop/docker-entrypoint.sh.

### Custom es-spark jars

The es-spark and es-pyspark commands are just aliases. You can see what they are in ~/.bashrc on the container, and adapt those commands to run a custom es-spark jar if you need to.
