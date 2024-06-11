def registry = 'https://vomp10.jfrog.io'
pipeline {
    agent {
        node {
            label 'maven'
        }
    }
environment {
    PATH = "/opt/maven/bin:$PATH"
}
    stages {
        stage("build"){
            steps { 
                sh 'mvn clean deploy'
            }
        }

        // stage('SonarQube analysis') {
        //     environment {
        //         scannerHome = tool 's1prove-sonar-scanner'
        //     }
        //     steps{
        //         withSonarQubeEnv('s1prove-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name
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
                                  "target": "vomp-libs-release-local/{1}",
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