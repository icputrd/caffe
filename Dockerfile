FROM ubuntu:16.04
MAINTAINER caffe-maint@googlegroups.com

#ENV http_proxy proxy:port
#ENV https_proxy proxy:port

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cpio \
        build-essential \
        cmake \
        git \
        wget \
        ssh \
        sssd \
        sssd-tools \
        openssh-server \
    libnss-sss \
    libpam-pwquality \
    libpam-sss \
    libsss-sudo \
    ldap-utils \
        numactl \
        vim \
        net-tools \
        lsof sudo \
        iputils-ping \
        screen \
        libmlx4-1 libmlx5-1 ibutils  rdmacm-utils libibverbs1 ibverbs-utils perftest infiniband-diags \
        openmpi-bin libopenmpi-dev \
        ufw \
        iptables \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

# Install conda and Intel Caffe conda package
WORKDIR /root/
RUN wget -c https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    bash Miniconda2-latest-Linux-x86_64.sh -b && \
    ./miniconda2/bin/conda config --add channels intel && \
    ./miniconda2/bin/conda install -c intel caffe && \
    rm -rf /root/miniconda2/pkgs/* && \
    rm ~/Miniconda2-latest-Linux-x86_64.sh -f && \
    echo "export PATH=/root/miniconda2/bin:$PATH" >> /root/.bashrc
WORKDIR /root/miniconda2/caffe

#RUN mkdir /var/run/sshd && \
#    echo 'root:intelcaffe@123' | chpasswd
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/;s/Port 22/Port 10010/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


COPY eecsCA_v3.crt /etc/ssl/ 
COPY sssd.conf /etc/sssd/ 
COPY common* /etc/pam.d/ 
RUN chmod 0600 /etc/sssd/sssd.conf /etc/pam.d/common* 
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; chmod 0755 /var/run/sshd; fi
COPY startsvc.sh startshell.sh notebook.sh startDef.sh /bin/ 

