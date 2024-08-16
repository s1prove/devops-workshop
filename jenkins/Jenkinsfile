def registry = 'https://s1prove12.jfrog.io'

pipeline {
    agent {
        node {
            label 'maven'
        }
    }

environment {
    PATH = "/opt/apache-maven-3.9.8/bin:$PATH"
}

    stages {
        stage('build'){
            steps {
                sh 'mvn clean deploy -Dmaven.test.skip=true'
            }
        }

        stage('test'){
            steps {
                sh 'mvn surefire-report:report'
            }
        }
        
        // stage('SonarQube analysis') {
        //     environment {
        //         scannerHome = tool 'sonar-scanner';
        //     }
        //     steps {
        //         withSonarQubeEnv('sonarqube-server') 
        //         { // if you have configured more than one global server connection, you can specify its name1
        //             sh "${scannerHome}/bin/sonar-scanner"
        //         }
        //     }
        // }

        stage("Jar Publish") {
            steps {
                script {
                        echo '<--------------- Jar Publish Started --------------->'
                         def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"art-cred"
                         def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                         def uploadSpec = """{
                              "files": [
                                {
                                  "pattern": "jarstaging/(*)",
                                  "target": "v-libs-release-local/{1}",
                                  "flat": "false",
                                  "props" : "${properties}",
                                  "exclusions": [ "*.sha1", "*.md5"]
                                }
                             ]
                         }"""
                         def buildInfo = server.upload(uploadSpec)
                         buildInfo.env.collect()
                         server.publishBuildInfo(buildInfo)
                         echo '<--------------- Jar Publish Ended --------------->'  
                }
            }
        }
    }
}