spark-up:
	docker compose -f docker-compose.Spark.yaml up -d

airflow-up:
	docker compose -f docker-compose.Airflow.yaml up -d

down:
	docker compose -f docker-compose.Airflow.yaml -f docker-compose.Spark.yaml down

note-auth:
	echo -e "\n\nNotebook url: $$(docker logs spark-notebook 2>&1 | grep -A 2 'Or copy and paste one of these URLs:' | grep '127.0.0.1:8888' | sed 's/127.0.0.1/localhost/;s/or //')\n\n"

restart: down up

up: spark-up airflow-up note-auth

spark-sh:
	docker exec -ti spark-master bash

airflow-sh:
	docker exec -ti airflow-webserver bash

#meta:
	#PGPASSWORD=sdepassword pgcli -h localhost -p 5432 -U sdeuser -d metadatadb

#ddl-bronze:
#	docker exec -ti local-spark bash -c '$$SPARK_HOME/bin/spark-submit --master local[*] --packages io.delta:$${DELTA_PACKAGE_VERSION},org.apache.hadoop:hadoop-aws:3.3.2 --conf spark.databricks.delta.retentionDurationCheck.enabled=false --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.hadoop.fs.s3a.access.key=minio --conf spark.hadoop.fs.s3a.secret.key=minio123 --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 --conf spark.hadoop.fs.s3a.region=us-east-1 --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.path.style.access=true ./adventureworks/ddl/create_bronze_tables.py'
#
#ddl-silver:
#	docker exec -ti local-spark bash -c '$$SPARK_HOME/bin/spark-submit --master local[*] --packages io.delta:$${DELTA_PACKAGE_VERSION},org.apache.hadoop:hadoop-aws:3.3.2 --conf spark.databricks.delta.retentionDurationCheck.enabled=false --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.hadoop.fs.s3a.access.key=minio --conf spark.hadoop.fs.s3a.secret.key=minio123 --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 --conf spark.hadoop.fs.s3a.region=us-east-1 --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.path.style.access=true ./adventureworks/ddl/create_silver_tables.py'
#
#ddl-gold:
#	docker exec -ti local-spark bash -c '$$SPARK_HOME/bin/spark-submit --master local[*] --packages io.delta:$${DELTA_PACKAGE_VERSION},org.apache.hadoop:hadoop-aws:3.3.2 --conf spark.databricks.delta.retentionDurationCheck.enabled=false --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.hadoop.fs.s3a.access.key=minio --conf spark.hadoop.fs.s3a.secret.key=minio123 --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 --conf spark.hadoop.fs.s3a.region=us-east-1 --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.path.style.access=true ./adventureworks/ddl/create_gold_tables.py'
#
#ddl-interface:
#	docker exec -ti local-spark bash -c '$$SPARK_HOME/bin/spark-submit --master local[*] --packages io.delta:$${DELTA_PACKAGE_VERSION},org.apache.hadoop:hadoop-aws:3.3.2 --conf spark.databricks.delta.retentionDurationCheck.enabled=false --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.hadoop.fs.s3a.access.key=minio --conf spark.hadoop.fs.s3a.secret.key=minio123 --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 --conf spark.hadoop.fs.s3a.region=us-east-1 --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.path.style.access=true ./adventureworks/ddl/create_interface_views.py'
#
#ddl: ddl-bronze ddl-silver ddl-gold ddl-interface

#etl:
#	docker exec -ti local-spark bash -c '$$SPARK_HOME/bin/spark-submit --master local[*] --packages io.delta:$${DELTA_PACKAGE_VERSION},org.apache.hadoop:hadoop-aws:3.3.2 --conf spark.databricks.delta.retentionDurationCheck.enabled=false --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.hadoop.fs.s3a.access.key=minio --conf spark.hadoop.fs.s3a.secret.key=minio123 --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 --conf spark.hadoop.fs.s3a.region=us-east-1 --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.path.style.access=true ./adventureworks/pipelines/sales_mart.py'
#
#spark-sh:
#	docker exec -ti local-spark bash -c '$$SPARK_HOME/bin/spark-shell --packages io.delta:$${DELTA_PACKAGE_VERSION},org.apache.hadoop:hadoop-aws:3.3.2 --conf spark.hadoop.fs.s3a.access.key=minio --conf spark.hadoop.fs.s3a.secret.key=minio123 --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 --conf spark.hadoop.fs.s3a.region=us-east-1 --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.path.style.access=true --conf spark.databricks.delta.retentionDurationCheck.enabled=false --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog'


######################################################################################################

pytest:
	docker exec -ti local-spark bash -c 'python3 -m pytest --log-cli-level info -p no:warnings -v ./tests'

format:
	docker exec -ti local-spark bash -c 'python3 -m black -S --line-length 79 --preview ./src'
	docker exec -ti local-spark bash -c 'isort ./src'

type:
	docker exec -ti local-spark bash -c 'python3 -m mypy --no-implicit-reexport --ignore-missing-imports --no-namespace-packages ./src'

lint:
	docker exec -ti local-spark bash -c 'flake8 ./src'
	docker exec -ti local-spark bash -c 'flake8 ./tests'

ci: format type lint pytest