FROM nvcr.io/nvidia/pytorch:20.03-py3
RUN bash jenkins_entry.sh --configure --exit
