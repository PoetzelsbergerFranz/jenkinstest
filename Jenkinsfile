pipeline {
    agent any

    stages {
        stage('Ping Check') {
            steps {
                script {
                    // Host, der angepingt werden soll
                    def host = "google.com"
                    
                    echo "Pinge ${host} an..."
                    
                    // -c 3 sendet 3 Pakete (Linux/macOS)
                    // Bei Windows stattdessen: bat "ping -n 3 ${host}"
                    sh "ping -c 3 ${host}"
                }
            }
        }
    }
}