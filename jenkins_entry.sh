set -ex

[ -d '.env3' ] || {
    python3.7 -m venv .env3
}
. .env3/bin/activate
cd yolov5

[ -d '../data/digits' ] || {
    echo "train dataset not found"
    exit 1
}

ln -s ../data/digits data/digits || true

python -m pip install -r requirements.txt
# bash train.sh
python train.py --img 640 --batch 16 --epochs 5 --data ./data/digits.yaml --cfg ./models/digits.yaml --weights ''
