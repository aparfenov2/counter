set -ex
. ./jenkins_env.sh
env
EPOCHS=5
BATCH=16
EVAL=""
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
        --eval) EVAL="$2"; shift ;;
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

[ -n "${DOCKER_BUID}" ] && [ -z "${IN_DOCKER}" ] && {
    docker build -t ${DOCKER_IMAGE} -f ${DOCKER_FILE} .
    [ -n "${EXIT_AFTER}" ] && {
        exit 0
    }
}

[ -n "${RUN_IN_DOCKER}" ] && [ -z "${IN_DOCKER}" ] && {
    docker run -ti --rm ${DOCKER_IMAGE} bash ./$0 --in_docker "${POSITIONAL[@]}"
    exit 0
}

PATH=$PATH:/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[ "${PREPARE_ENV}" == "true" ] && {
    echo "prepare docker image"

apt update
apt install -y libglib2.0-0
apt install -y libsm6 libxext6
apt install -y libxrender-dev

conda update -yn base -c defaults conda
conda install -yc anaconda numpy opencv matplotlib tqdm pillow ipython
conda install -yc conda-forge scikit-image pycocotools tensorboard
conda install -yc spyder-ide spyder-line-profiler
conda install -yc pytorch pytorch torchvision
conda install -yc conda-forge protobuf numpy && pip install onnx==1.6.0  # https://github.com/onnx/onnx#linux-and-macos

conda uninstall pytorch torchvision cudatoolkit=10.1 -c pytorch
# todo rm numpy dist-info
pip uninstall numpy
pip install numpy==1.17.0
conda install pytorch torchvision cudatoolkit=10.1 -c pytorch

# [ -d '.env3' ] || {
#     /opt/conda/bin/python3.7 -m venv .env3 --system-site-packages
# }
# . .env3/bin/activate
# python -m pip install -r requirements.txt
echo "image configuration complete!"
[ -n "${EXIT_AFTER}" ] && {
    exit 0
}
}

PYTHON=/opt/conda/bin/python3.7
# . .env3/bin/activate
cd yolov5

[ -d '/root/data/digits' ] || {
    echo "train dataset not found - trying download"
    mkdir -p /root/data || true
    cd /root/data
    wget http://kan-rt.ddns.net:8000/numbers.tgz .
    tar xvf numbers.tgz
    ls -l
    cd ${WORKDIR}/yolov5
}
ln -s /root/data/digits data/digits || true
ls -l data/digits

[ -n "$EVAL" ] && {
    echo "eval mode ! Not implemented"
    exit 1
}

$PYTHON train.py --img 640 --batch $BATCH --epochs $EPOCHS --data ./data/digits.yaml --cfg ./models/digits.yaml --weights ''
