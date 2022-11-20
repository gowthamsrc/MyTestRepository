pipeline {
  agent {
    node {
      label 'ubuntu-Linux'
    }

  }
  stages {
    stage('Buzz Buzz') {
      steps {
        echo 'Bee Buzz!!'
      }
    }

    stage('Bees Bees') {
      steps {
        echo 'Buzz, Bees, Buzz!'
      }
    }

    stage('Bees Buzzing Again') {
      steps {
        echo 'Bees Buzzing Again'
        sh 'mvn clean install "java-tomcat-sample"'
      }
    }

  }
}