pipeline {
    agent any
    
    parameters {
        string (name: 'EXPERIMENT_NAME', defaultValue: 'default_experiment')
        string (name: 'BRANCH_NAME', defaultValue: 'aparfenov/try_jenkins')
        string (name: 'CMDLINE', defaultValue: 'echo hello')
        booleanParam (name : 'DELETE_IF_EXIST', defaultValue: false, description: 'delete experiment directory if exists')
        choice (name: 'EXECUTION_QUEUE', choices: ['queue1', 'queue2', 'queue3', 'queue4'])
    }

    environment {
        EXPERIMENT_DIR="/mnt/xvdf1/data/jenkins_experiments"
        EXPERIMENT_NAME="${EXPERIMENT_NAME.trim()}"
        WORKDIR="${EXPERIMENT_DIR}/${EXPERIMENT_NAME.trim()}"
        CMDLINE="${CMDLINE.trim()}"
        BRANCH_NAME="${BRANCH_NAME.trim()}"
        DELETE_IF_EXIST="${DELETE_IF_EXIST}"
    }

    stages {
        stage('run') {
            steps {
                addShortText(text: EXPERIMENT_NAME, background: 'orange', border: 1)
                addShortText(text: EXECUTION_QUEUE, background: 'green', border: 1)
                
                lock(resource: env.EXECUTION_QUEUE, quantity:1, inversePrecedence: true) {
                    script {
                        if (env.DELETE_IF_EXIST == 'true') {
                            echo "deleting existing experiment directory"
                            sh "rm -rf ${WORKDIR}"
                        }
                        sh "mkdir ${WORKDIR}"

                        dir("${WORKDIR}") {
                            checkout([
                                $class: 'GitSCM', branches: [[name: BRANCH_NAME]],
                                extensions: [
                                    [$class: 'CloneOption', noTags: true, reference: '', shallow: true],
                                    [$class: 'SubmoduleOption',
                                        disableSubmodules: false,
                                        parentCredentials: true,
                                        recursiveSubmodules: true,
                                        reference: '',
                                        trackingSubmodules: false]
                                    ],
                                userRemoteConfigs: [[url: 'git@github.com:kantengri/3dmg.git', credentialsId:'github']]
                            ])                       
                            // sh("git checkout ${BRANCH_NAME}")
                            sh "echo BRANCH_NAME=\\\"${BRANCH_NAME}\\\" > jenkins_env.sh"
                            sh "echo CMDLINE=\\\"${CMDLINE}\\\" >> jenkins_env.sh"
                            sh "echo WORKDIR=\\\"${WORKDIR}\\\" >> jenkins_env.sh"
                            sh "echo EXPERIMENT_NAME=\\\"${EXPERIMENT_NAME}\\\" >> jenkins_env.sh"

                        }
                        sshagent (credentials: ['localhost']) {
                            sh "echo 'cd ${WORKDIR}; ${CMDLINE}' | ssh ubuntu@localhost bash -s"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                sh "cp ${WORKDIR}/jenkins_env.sh ."
            }
            archiveArtifacts artifacts: 'jenkins_env.sh'
        }
    }
}