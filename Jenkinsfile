pipeline {
  agent {
    node {
      label 'ubuntu-Linux'
    }

  }
  stages {
    stage('Buzz Buzz') {
      parallel {
        stage('Buzz Buzz') {
          steps {
            echo 'Bee Buzz!!'
          }
        }

        stage('print stage') {
          steps {
            echo 'Hello World'
            sleep 5
          }
        }

        stage('Sleep') {
          steps {
            sleep 5
          }
        }

      }
    }

    stage('Bees Bees') {
      steps {
        echo 'Buzz, Bees, Buzz!'
      }
    }

    stage('Bees Buzzing Again') {
      parallel {
        stage('Bees Buzzing Again') {
          steps {
            echo 'Bees Buzzing Again'
          }
        }

        stage('Build and archive') {
          steps {
            dir(path: 'java-tomcat-sample') {
              sh 'mvn -f pom.xml clean package'
              archiveArtifacts(artifacts: 'target/*.war', fingerprint: true)
            }

          }
        }

      }
    }

    stage('Test') {
      steps {
        junit '**/surefire-reports/**/*.xml'
      }
    }

  }
}