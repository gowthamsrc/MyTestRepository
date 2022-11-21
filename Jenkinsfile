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
            sh 'mvn clean package'
          }
        }

      }
    }

  }
}