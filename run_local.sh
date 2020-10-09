
EXPERIMENT_NAME=default_experiment
BRANCH_NAME=develop
CMDLINE="bash ./jenkins_entry.sh"
DELETE_IF_EXIST=false
EXPERIMENT_DIR="./jenkins_experiments"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--exp_name)
    EXPERIMENT_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--branch)
    BRANCH_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--cmdline)
    CMDLINE="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--delete)
    DELETE_IF_EXIST=1
    shift # past argument
    ;;
    *)    # unknown option
    echo "unknown option $1"
    exit 1
    ;;
esac
done

WORKDIR="${EXPERIMENT_DIR}/${EXPERIMENT_NAME}"

[ -d "${WORKDIR}" ] || {
    mkdir -p ${WORKDIR}
    cd ${WORKDIR}
    git clone git@github.com:kantengri/counter.git .
    git checkout ${BRANCH_NAME}
}

cd ${WORKDIR}
echo BRANCH_NAME=\"${BRANCH_NAME}\" > jenkins_env.sh
echo CMDLINE=\"${CMDLINE}\" >> jenkins_env.sh
echo WORKDIR=\"${WORKDIR}\" >> jenkins_env.sh
echo EXPERIMENT_NAME=\"${EXPERIMENT_NAME}\" >> jenkins_env.sh

${CMDLINE}
