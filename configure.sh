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

conda uninstall -y pytorch torchvision cudatoolkit=10.1 -c pytorch
# todo rm numpy dist-info
pip uninstall -y numpy
pip install numpy==1.17.0
conda install -y pytorch torchvision cudatoolkit=10.1 -c pytorch

# [ -d '.env3' ] || {
#     /opt/conda/bin/python3.7 -m venv .env3 --system-site-packages
# }
# . .env3/bin/activate
# python -m pip install -r requirements.txt
