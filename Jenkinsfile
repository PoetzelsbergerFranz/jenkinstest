pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kubectl
    image: alpine/kubectl:latest
    command: ['sleep']
    args: ['99d']
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['sleep']
    args: ['99d']
    volumeMounts:
      - name: registry-auth
        mountPath: /kaniko/.docker
  volumes:
    - name: registry-auth
      emptyDir: {}
"""
        }
    }
    
    environment {
        REGISTRY = "docker-registry.azure.poetzelsberger.net"
        IMAGE_NAME = "${REGISTRY}/jenkins-webapp:${env.BUILD_ID}"
    }

    stages {
        stage('Build with Kaniko') {
            steps {
                container('kaniko') {
                    script {
                        // Kaniko baut und pusht in einem Schritt
                        // --insecure erlaubt HTTP zur internen Registry
                        sh """
                        /kaniko/executor --context `pwd` \
                          --dockerfile `pwd`/Dockerfile \
                          --destination ${IMAGE_NAME}
                        """
                    }
                }
            }
        }
        
        stage('K8s Deployment Update') {
            steps {
                // Hier wechseln wir in den 'kubectl' Container
                container('kubectl') {
                    // Nutze die hochgeladene Kubeconfig
                    withKubeConfig([credentialsId: 'jenkins-k8s-token', serverUrl: 'https://kubernetes.default.svc']) {
                        script {
                            // 1. Image-Tag im Deployment-File dynamisch anpassen
                            sh "sed -i 's|image:.*|image: ${IMAGE_NAME}|' k8s-deployment/deployment.yaml"
                            
                            // 2. Alle Ressourcen in Kubernetes anwenden
                            sh "kubectl apply -f k8s-deployment/deployment.yaml --kubeconfig=${KUBECONFIG}"
                            sh "kubectl apply -f k8s-deployment/service.yaml --kubeconfig=${KUBECONFIG}"
                            sh "kubectl apply -f k8s-deployment/ingress.yaml --kubeconfig=${KUBECONFIG}"
                        }
                    }
                }
            }
        }
        
        stage('Verify') {
            steps {
                // Hier wechseln wir in den 'kubectl' Container
                container('kubectl') {
                    withKubeConfig([credentialsId: 'jenkins-k8s-token', serverUrl: 'https://kubernetes.default.svc']) {
                        // Status des Rollouts prüfen
                        sh "kubectl rollout status deployment/jenkins-webapp -n jenkins-webapp --kubeconfig=${KUBECONFIG}"
                    }
                }
            }
        }
    }
}