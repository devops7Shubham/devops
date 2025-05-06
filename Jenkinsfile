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
    // ... [Keep all previous stages unchanged until 'Install AWS Load Balancer Controller']

    stage('Install AWS Load Balancer Controller') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            # Clean up any previous installation
            helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || true
            
            # Install/Upgrade controller
            helm repo add eks https://aws.github.io/eks-charts
            helm repo update
            helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
              -n kube-system \
              --set clusterName=${EKS_CLUSTER_NAME} \
              --set serviceAccount.create=false \
              --set serviceAccount.name=aws-load-balancer-controller
          """
        }
      }
    }

    stage('Deploy Application to EKS') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            # Add path prefix if manifests are in k8s/ directory
            kubectl apply -f postgres-deployment.yaml
            kubectl apply -f backend-deployment.yaml
            kubectl apply -f frontend-deployment.yaml
            kubectl apply -f alb-ingress.yaml
          """
        }
      }
    }

    // ... [Keep remaining stages unchanged]
  }

  post {
    always {
      withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
      ]]) {
        script {
          // Gracefully handle missing ingress
          def ALB_HOST = sh(
            script: "kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo 'not-available'",
            returnStdout: true
          ).trim()
          echo "🚀 Application URL: http://${ALB_HOST}"
          cleanWs()
        }
      }
    }
  }
}