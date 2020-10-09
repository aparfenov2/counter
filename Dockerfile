FROM nvcr.io/nvidia/pytorch:20.03-py3
ADD configure.sh .
RUN bash configure.sh
