FROM centos:7.8.2003

ENV LC_ALL=en_US.UTF-8

RUN yum update -y && yum install -y which && \
  yum install -y centos-release-scl

RUN yum update -y && yum install -y devtoolset-9 && \
  yum install -y python3 patch bzip2 file git && \
  update-alternatives --install /usr/bin/python python /usr/bin/python2 50 && \
  update-alternatives --install /usr/bin/python python /usr/bin/python3 60 && \
  echo "source /opt/rh/devtoolset-9/enable" >> /etc/bashrc

SHELL ["/bin/bash", "--login", "-c"]

COPY part /home/temp_file
COPY environment.yml /home/environment.yml
COPY entrypoints.sh /home/entrypoints.sh

RUN git clone -c feature.manyFiles=true https://github.com/spack/spack.git /home/spack && \
. /home/spack/share/spack/setup-env.sh && \
sed -i '16 r /home/temp_file' /home/spack/etc/spack/defaults/packages.yaml && \
spack compiler find && \
CXX=g++ && CC=gcc && FC=gfortran && \
spack install nvhpc@22.2 %gcc@9.3.1 && \
spack load nvhpc@22.2 %gcc@9.3.1 && \
spack compiler find && \
CXX=nvc++ && CC=nvc && FC=nvfortran && \
spack install openmpi@4.1.5 %nvhpc@22.2 && \
spack install cuda@12.1.1 %nvhpc@22.2 && \
spack install intel-oneapi-compilers@2021.4.0 %gcc@9.3.1  &&CXX=g++ && CC=gcc && FC=gfortran && \
spack load intel-oneapi-compilers@2021.4.0 && CXX=icpc && CC=icc && FC=ifort && \
spack compiler add `spack location -i intel-oneapi-compilers@2021.4.0`/compiler/latest/linux/bin/intel64 && \
spack compiler add `spack location -i intel-oneapi-compilers@2021.4.0`/compiler/latest/linux/bin && \
spack install openmpi@4.1.1 %oneapi@2021.4.0 && \
spack install openmpi@4.1.1 %intel@2021.4.0 && \
spack install cuda@12.1.1 %intel@2021.4.0 && \
spack install netcdf-fortran@4.6.0 %gcc@9.3.1 &&CXX=g++ && CC=gcc && FC=gfortran && \


RUN spack env create myenv /home/environment.yml && spack env activate myenv && spack install

ENV PATH="/home/spack/bin:$PATH"
ENV LD_LIBRARY_PATH=/home/spack/lib:$LD_LIBRARY_PATH
ENV PATH="/opt/rh/devtoolset-9/root/usr/bin:$PATH"

ENTRYPOINT ["/entrypoint.sh"]
