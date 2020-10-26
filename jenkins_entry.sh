set -e
[ -f "./jenkins_env.sh" ] && {
    . ./jenkins_env.sh
}
# env
EPOCHS=5
BATCH=16
EVAL=
TRAIN=
RUN_IN_DOCKER=
IN_DOCKER=
DOCKER_IMAGE="${EXPERIMENT_NAME}"
DOCKER_FILE="Dockerfile"
DOCKER_BUID=
EXIT_AFTER=
POSITIONAL=("$@")

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --epochs) EPOCHS="$2"; shift ;;
        --batch) BATCH="$2"; shift ;;
        --eval) EVAL=1;;
        --train) TRAIN=1;;
        --configure) PREPARE_ENV="true";;
        --in_docker) IN_DOCKER=1;;
        --docker) RUN_IN_DOCKER=1;;
        --build) DOCKER_BUID=1;;
        --image) DOCKER_IMAGE="$2"; shift ;;
        --exit) EXIT_AFTER=1;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo POSITIONAL="${POSITIONAL[@]}"
echo RUN_IN_DOCKER=${RUN_IN_DOCKER}
echo IN_DOCKER=${IN_DOCKER}
echo DOCKER_IMAGE=${DOCKER_IMAGE}
echo DOCKER_FILE=${DOCKER_FILE}
echo DOCKER_BUID=${DOCKER_BUID}
echo EXIT_AFTER=${EXIT_AFTER}


echo PREPARE_ENV=${PREPARE_ENV}

echo EPOCHS=$EPOCHS
echo BATCH=$BATCH
echo EVAL=$EVAL
WORKDIR=$PWD
echo WORKDIR=$WORKDIR

[ -n "${DOCKER_BUID}" ] && [ -z "${IN_DOCKER}" ] && {
    docker build -t ${DOCKER_IMAGE} -f ${DOCKER_FILE} .
    [ -n "${EXIT_AFTER}" ] && {
        exit 0
    }
}

[ -n "${RUN_IN_DOCKER}" ] && [ -z "${IN_DOCKER}" ] && {
    docker run -ti --rm \
        --name ${EXPERIMENT_NAME} \
        -v $PWD:/cdir \
        -w /cdir \
        ${DOCKER_IMAGE} bash ./$0 --in_docker "${POSITIONAL[@]}"
    exit 0
}

PATH=$PATH:/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[ "${PREPARE_ENV}" == "true" ] && {
    echo "prepare docker image"
    bash ./configure.sh
    echo "image configuration complete!"
    [ -n "${EXIT_AFTER}" ] && {
        exit 0
    }
}

PYTHON=/opt/conda/bin/python3.7
# . .env3/bin/activate
cd yolov5

[ -d 'data/digits' ] || {
    [ -d '/root/data/digits' ] || {
        echo "train dataset not found - trying download"
        mkdir -p /root/data || true
        cd /root/data
        wget http://kan-rt.ddns.net:18000/numbers.tgz -O numbers.tgz        
        tar xvf numbers.tgz
        ls -l
        cd ${WORKDIR}/yolov5
    }
    ln -s /root/data/digits data/digits || true
    ls -l data/digits
}

[ -n "${EVAL}" ] && {
    echo "eval mode ! Not implemented"
    exit 1
}

[ -n "${TRAIN}" ] && {
    $PYTHON train.py --img 128 --batch $BATCH --epochs $EPOCHS --data ./data/digits.yaml --cfg ./models/digits.yaml --weights ''
}