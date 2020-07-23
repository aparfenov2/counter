pipeline {
    agent any
    
    parameters {
        string (name: 'EXPERIMENT_NAME', defaultValue: 'default_experiment')
        string (name: 'BRANCH_NAME', defaultValue: 'develop')
        string (name: 'SSH_HOST', defaultValue: 'ssh4.vast.ai')
        string (name: 'SSH_PORT', defaultValue: '17000')
        string (name: 'CMDLINE', defaultValue: 'bash ./jenkins_entry.sh')
        booleanParam (name : 'DELETE_IF_EXIST', defaultValue: false, description: 'delete experiment directory if exists')
        choice (name: 'EXECUTION_QUEUE', choices: ['queue1', 'queue2', 'queue3', 'queue4'])
    }

    environment {
        EXPERIMENT_DIR="/root/jenkins_experiments"
        EXPERIMENT_NAME="${EXPERIMENT_NAME.trim()}"
        WORKDIR="${EXPERIMENT_DIR}/${EXPERIMENT_NAME.trim()}"
        CMDLINE="${CMDLINE.trim()}"
        SSH_HOST="${SSH_HOST.trim()}"
        SSH_PORT="${SSH_PORT.trim()}"
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
                        sshagent (credentials: ['inst']) {
sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} root@${SSH_HOST} 'bash -s << 'ENDSSH'
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
[ "${DELETE_IF_EXIST}" == "true" ] && {
    echo "deleting existing experiment directory"
    rm -rf ${WORKDIR} || true
}
command -v git >/dev/null 2>&1 || {
    apt update && apt install -y git
}
[ -d "${WORKDIR}" ] || {
    mkdir -p ${WORKDIR}
    cd ${WORKDIR}
    git clone git@github.com:kantengri/counter.git .
    git checkout ${BRANCH_NAME}
}
cd ${WORKDIR}
echo BRANCH_NAME=\\\"${BRANCH_NAME}\\\" > jenkins_env.sh
echo CMDLINE=\\\"${CMDLINE}\\\" >> jenkins_env.sh
echo WORKDIR=\\\"${WORKDIR}\\\" >> jenkins_env.sh
echo EXPERIMENT_NAME=\\\"${EXPERIMENT_NAME}\\\" >> jenkins_env.sh

git pull

${CMDLINE}

ENDSSH'
     """

                        } // sshagent
                    } // script
                } // lock
            }
        }
    }
    // post {
    //     always {
    //         script {
    //             sh "cp ${WORKDIR}/jenkins_env.sh ."
    //         }
    //         archiveArtifacts artifacts: 'jenkins_env.sh'
    //     }
    // }
}