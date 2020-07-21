set -ex
. ./jenkins_env.sh
env

[ -d '.env3' ] || {
    /opt/conda/bin/python3.7 -m venv .env3
}
. .env3/bin/activate
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
# bash train.sh
python train.py --img 640 --batch 16 --epochs 5 --data ./data/digits.yaml --cfg ./models/digits.yaml --weights ''
