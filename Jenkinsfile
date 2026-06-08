pipeline {
    agent any

    environment {
        REMOTE_HOST     = '13.41.167.97'
        REMOTE_USER     = 'samia'
        REMOTE_PASSWORD = 'WelcomeItc@2026'

        // PostgreSQL connection
        PG_HOST         = '13.42.152.118'
        PG_PORT         = '5432'
        PG_DB           = 'testdb'
        PG_USER         = 'admin'
        PG_PASSWORD     = 'admin123'
        PG_SCHEMA       = 'aparna'

        // HDFS target directory
        HDFS_DIR        = '/tmp/tfl_project/hadoop/full_load'
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

        stage('Prepare HDFS Directory') {
            steps {
                echo '========================================='
                echo 'Stage 2: Create HDFS Directory'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "hdfs dfs -rm -r -f -skipTrash ${HDFS_DIR} || true;
                         hdfs dfs -mkdir -p ${HDFS_DIR}"
                '''
            }
        }

        stage('Copy Sqoop Script') {
            steps {
                echo '========================================='
                echo 'Stage 3: Copy Sqoop Script'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" scp -o StrictHostKeyChecking=no \
                        src/sqoop_import.sh ${REMOTE_USER}@${REMOTE_HOST}:/home/${REMOTE_USER}/
                '''
            }
        }

        stage('Run Sqoop Import') {
            steps {
                echo '========================================='
                echo 'Stage 4: Run Sqoop Import'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "PG_HOST=${PG_HOST} PG_PORT=${PG_PORT} PG_DB=${PG_DB} \
                         PG_USER=${PG_USER} PG_PASSWORD=${PG_PASSWORD} PG_SCHEMA=${PG_SCHEMA} \
                         HDFS_DIR=${HDFS_DIR} bash /home/${REMOTE_USER}/sqoop_import.sh"
                '''
            }
        }

        stage('Verify HDFS Output') {
            steps {
                echo '========================================='
                echo 'Stage 5: Verify HDFS Data'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "hdfs dfs -ls ${HDFS_DIR} || echo 'No data found'"
                '''
            }
        }
    }

    post {
        success {
            echo '========================================='
            echo 'SQOOP FULL LOAD COMPLETED SUCCESSFULLY'
            echo '========================================='
        }
        failure {
            echo '========================================='
            echo 'SQOOP PIPELINE FAILED — CHECK LOGS'
            echo '========================================='
        }
    }
}
