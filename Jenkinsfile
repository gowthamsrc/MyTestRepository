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

        stage('Build') {
          steps {
            dir(path: 'java-tomcat-sample') {
              sh 'mvn clean package'
            }

          }
        }

      }
    }

    stage('Archive Artifact') {
      steps {
        archiveArtifacts 'java-tomcat-sample/target/*.war'
      }
    }

  }
}