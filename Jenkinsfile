pipeline {
    agent any

    environment {
        REMOTE_HOST     = '13.41.167.97'
        REMOTE_USER     = 'consultant'
        REMOTE_PASSWORD = 'WelcomeItc@2026'
        PROJECT_DIR     = '/home/ec2-user/samia'
        HDFS_DIR        = '/tmp/tfl_project'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '========================================='
                echo 'Stage 1: Git Checkout'
                echo '========================================='
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('Prepare Remote Directory') {
            steps {
                echo '========================================='
                echo 'Stage 2: Create Directories on Cloudera'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "mkdir -p ${PROJECT_DIR}/sqoop ${PROJECT_DIR}/hive" || true

                    echo "Directories created"
                '''
            }
        }

        stage('Copy Scripts to Cloudera') {
            steps {
                echo '========================================='
                echo 'Stage 3: Copy Sqoop and Hive Scripts'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        src/sqoop_import.sh ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/sqoop/

                    sshpass -p "${REMOTE_PASSWORD}" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        src/hive_ddl.hql ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/hive/

                    echo "Scripts copied successfully"
                '''
            }
        }

        stage('Set Permissions') {
            steps {
                echo '========================================='
                echo 'Stage 4: Set Execute Permissions'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "chmod +x ${PROJECT_DIR}/sqoop/sqoop_import.sh"

                    echo "Permissions set"
                '''
            }
        }

        stage('Prepare Staging Directory') {
            steps {
                echo '========================================='
                echo 'Stage 5: Create local staging directory'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "mkdir -p /tmp/hadoop/mapred/staging"

                    echo "Staging directory ready"
                '''
            }
        }

        stage('Clean HDFS') {
            steps {
                echo '========================================='
                echo 'Stage 6: Clean HDFS directories'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "hdfs dfs -rm -r -f -skipTrash ${HDFS_DIR} || true"

                    echo "HDFS cleaned"
                '''
            }
        }

        stage('Sqoop Import from PostgreSQL to HDFS') {
            steps {
                echo '========================================='
                echo 'Stage 7: Run Sqoop Import'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "bash ${PROJECT_DIR}/sqoop/sqoop_import.sh"

                    echo "Sqoop import completed"
                '''
            }
        }

        stage('Run Spark Analysis') {
            steps {
                echo '========================================='
                echo 'Stage 8: Run PySpark Transformations'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        src/tfl_spark_analysis.py ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/

                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "spark-submit --master local[*] ${PROJECT_DIR}/tfl_spark_analysis.py"

                    echo "Spark analysis completed"
                '''
            }
        }

        stage('Create Hive Tables') {
            steps {
                echo '========================================='
                echo 'Stage 9: Create Hive External Tables'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "beeline -u 'jdbc:hive2://ip-172-31-12-74.eu-west-2.compute.internal:10000/default' -f ${PROJECT_DIR}/hive/hive_ddl.hql"

                    echo "Hive tables created"
                '''
            }
        }

        stage('Verify Results') {
            steps {
                echo '========================================='
                echo 'Stage 10: Verify HDFS Data'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "hdfs dfs -ls ${HDFS_DIR} || echo 'HDFS directory not found'"
                '''
            }
        }
    }

    post {
        success {
            echo '========================================='
            echo 'TFL PIPELINE COMPLETED SUCCESSFULLY'
            echo '========================================='
            echo "Cloudera: ${REMOTE_HOST}:${PROJECT_DIR}"
            echo "HDFS: ${HDFS_DIR}"
            echo '========================================='
        }
        failure {
            echo '========================================='
            echo 'TFL PIPELINE FAILED - check logs above'
            echo '========================================='
        }
        always {
            echo 'Pipeline execution completed'
        }
    }
}
