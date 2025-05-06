pipeline {
  agent any

  environment {
    DOCKERHUB_NAMESPACE = 'shubhamdevops'
    BACKEND_IMAGE       = "${DOCKERHUB_NAMESPACE}/backend-app:latest"
    FRONTEND_IMAGE      = "${DOCKERHUB_NAMESPACE}/frontend-app:latest"
    EKS_CLUSTER_NAME    = 'simple-eks'
    AWS_REGION          = 'us-east-1'
  }

  stages {
    stage('Git Checkout') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          checkout scmGit(
            branches: [[name: '*/demo']],
            extensions: [],
            userRemoteConfigs: [[
              url: 'https://github.com/devops7Shubham/devops.git'
            ]]
          )
        }
      }
    }

    stage('Build Docker Images') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh "docker buildx build --load -t ${BACKEND_IMAGE} ./backend"
          sh "docker buildx build --load -t ${FRONTEND_IMAGE} ./frontend"
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'shubhamdevops',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          ),
          [$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws_credentials',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]
        ]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${BACKEND_IMAGE}
            docker push ${FRONTEND_IMAGE}
          '''
        }
      }
    }

    stage('Configure kubectl for EKS') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            aws eks update-kubeconfig \
              --region ${AWS_REGION} \
              --name ${EKS_CLUSTER_NAME}
          """
        }
      }
    }

    stage('Verify EKS Nodes') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh "kubectl get nodes -o wide"
        }
      }
    }

    stage('Install NGINX Ingress Controller') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            # Remove AWS LB webhook if present
            kubectl delete mutatingwebhookconfigurations aws-load-balancer-webhook 2>/dev/null || true

            # Uninstall AWS Load Balancer Controller if installed
            helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || true

            # Install NGINX Ingress Controller
            helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
              --namespace ingress-nginx \
              --create-namespace \
              --set controller.service.type=LoadBalancer \
              --set controller.ingressClassResource.name=nginx \
              --set controller.ingressClassResource.controllerValue=k8s.io/ingress-nginx \
              --atomic --wait
          '''
        }
      }
    }

    stage('Apply Kubernetes Manifests') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            kubectl apply -f postgres-deployment.yaml --validate=false
            kubectl apply -f backend-deployment.yaml  --validate=false
            kubectl apply -f frontend-deployment.yaml --validate=false
            kubectl apply -f ingress.yaml             --validate=false
          '''
        }
      }
    }

    stage('Wait for Ingress Ready') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            echo "Waiting for Ingress controller to be ready..."
            kubectl wait --namespace ingress-nginx \
              --for=condition=available deployment/ingress-nginx-controller \
              --timeout=180s
          '''
        }
      }
    }

    stage('Get Application URL') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          script {
            def host = sh(
              script: "kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
              returnStdout: true
            ).trim()
            if (!host) {
              host = sh(
                script: "kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
                returnStdout: true
              ).trim()
            }
            echo "🎉 Your application is available at: http://${host}/"
          }
        }
      }
    }

  } // stages

  post {
    always {
      cleanWs() // Clean up the workspace
    }
  }
}
