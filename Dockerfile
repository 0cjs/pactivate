FROM debian:11
RUN apt-get -qq update && apt-get install -y -qq \
    curl python3 python3-distutils python2 \
    vim-tiny                                    # for debugging
ADD bashrc /root/.bashrc
ADD pactivate cont-test /test/
