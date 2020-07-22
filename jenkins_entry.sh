set -ex
. ./jenkins_env.sh
env
EPOCHS=5
BATCH=16
EVAL=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --epochs) EPOCHS="$2"; shift ;;
        --batch) BATCH="$2"; shift ;;
        --eval) EVAL="$2"; shift ;;
        --configure) PREPARE_ENV="true";;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo EPOCHS=$EPOCHS
echo BATCH=$BATCH
echo EVAL=$EVAL
echo PREPARE_ENV=${PREPARE_ENV}

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
}

PYTHON=/opt/conda/bin/python3.7
# . .env3/bin/activate
cd yolov5

[ -d '/root/data/digits' ] || {
    echo "train dataset not found - trying download"
    mkdir -p /root/data || true
    cd /root/data
    scp pi@kantengri.ddns.net:digits.tgz .
    tar xvf digits.tgz
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
