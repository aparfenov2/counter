set -ex
. ./jenkins_env.sh
env
PATH=$PATH:/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
conda update -yn base -c defaults conda
conda install -yc anaconda numpy opencv matplotlib tqdm pillow ipython
conda install -yc conda-forge scikit-image pycocotools tensorboard
conda install -yc spyder-ide spyder-line-profiler
conda install -yc pytorch pytorch torchvision
conda install -yc conda-forge protobuf numpy && pip install onnx==1.6.0  # https://github.com/onnx/onnx#linux-and-macos

# [ -d '.env3' ] || {
#     /opt/conda/bin/python3.7 -m venv .env3 --system-site-packages
# }
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

python -m pip install -r requirements.txt

# apt update
# apt install -y libglib2.0-0
# apt install -y libsm6 libxext6
# apt install -y libxrender-dev

python train.py --img 640 --batch 16 --epochs 5 --data ./data/digits.yaml --cfg ./models/digits.yaml --weights ''
