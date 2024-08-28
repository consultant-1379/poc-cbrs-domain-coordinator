#!/usr/bin/env groovy

def defaultBobImage = 'armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob.2.0:1.7.0-55'
def bob = new BobCommand()
    .bobImage(defaultBobImage)
    .envVars([
        HELM_REPO_TOKEN:'${HELM_REPO_TOKEN}',
        HOME:'${HOME}',
        RELEASE:'${RELEASE}',
        // KUBECONFIG:'${KUBECONFIG}',
        USER:'${USER}'
    ])
    .needDockerSocket(true)
    .toString()

pipeline {
    agent {
        node {
            label "cbrs_node"
        }
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        RELEASE = "true"
        KUBECONFIG = ""
    }

    stages {
        stage('Clean') {
            steps {
                archiveArtifacts allowEmptyArchive: true, artifacts: 'ruleset2.0.yaml, publish.Jenkinsfile'
                sh "${bob} clean"
            }
        }

        stage('Init') {
            steps {
                sh "${bob} init-drop"
                archiveArtifacts 'artifact.properties'
            }
        }

        stage('Lint') {
            steps {
                parallel(
                    "lint helm": {
                        sh "${bob} lint:helm"
                    },
                    "lint helm design rule checker": {
                        sh "${bob} lint:helm-chart-check"
                    }
                )
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: '.bob/design-rule-check-report.*'
                }
            }
        }

        stage('Image') {
            steps {
                sh "${bob} image"
                sh "${bob} image-dr-check"
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: '.bob/check-image/image-design-rule-check-report.*, .bob/check-init-image/image-design-rule-check-report.*'
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'lciadm100', variable: 'HELM_REPO_TOKEN')]) {
                        sh "${bob} package"
                    }
                }
            }
        }

        stage('K8S Resource Lock') {
            stages {
                stage('Helm Install') {
                    steps {
                        echo 'sh "${bob} helm-dry-run"'
                        echo 'sh "${bob} create-namespace"'
                        echo 'sh "${bob} helm-install"'
                        echo 'sh "${bob} healthcheck"'
                    }
                    post {
                        failure {
                            sh "${bob} collect-k8s-logs || true"
                            archiveArtifacts allowEmptyArchive: true, artifacts: 'k8s-logs/**/*.*'
                            echo 'sh "${bob} delete-namespace"'
                        }
                    }
                }

                stage('K8S Test') {
                    steps {
                        echo 'sh "${bob} helm-test"'
                    }
                    post {
                        failure {
                            sh "${bob} collect-k8s-logs || true"
                            archiveArtifacts allowEmptyArchive: true, artifacts: 'k8s-logs/**/*.*'
                        }
                        cleanup {
                            echo 'sh "${bob} delete-namespace"'
                        }
                    }
                }
            }
        }

        stage('Publish') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'lciadm100', variable: 'HELM_REPO_TOKEN')]) {
                        sh "${bob} publish"
                    }
                }
            }
        }
    }
}

// More about @Builder: http://mrhaki.blogspot.com/2014/05/groovy-goodness-use-builder-ast.html
import groovy.transform.builder.Builder
import groovy.transform.builder.SimpleStrategy

@Builder(builderStrategy = SimpleStrategy, prefix = '')
class BobCommand {

    def bobImage = 'bob.2.0:latest'
    def envVars = [:]

    def needDockerSocket = false

    String toString() {
        def env = envVars
                .collect({ entry -> "-e ${entry.key}=\"${entry.value}\"" })
                .join(' ')

        def cmd = """\
            |docker run
            |--init
            |--rm
            |--workdir \${PWD}
            |--user \$(id -u):\$(id -g)
            |-v \${PWD}:\${PWD}
            |-v /etc/group:/etc/group:ro
            |-v /etc/passwd:/etc/passwd:ro
            |-v \${HOME}:\${HOME}
            |${needDockerSocket ? '-v /var/run/docker.sock:/var/run/docker.sock' : ''}
            |${env}
            |\$(for group in \$(id -G); do printf ' --group-add %s' "\$group"; done)
            |--group-add \$(stat -c '%g' /var/run/docker.sock)
            |${bobImage}
            |"""
        return cmd
                .stripMargin()           // remove indentation
                .replace('\n', ' ')      // join lines
                .replaceAll(/[ ]+/, ' ') // replace multiple spaces by one
    }
}