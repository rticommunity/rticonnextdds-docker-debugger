##############################################################################
# Copyright (c) 2017 Real-Time Innovations, Inc.
# All rights reserved. RTI grants Licensee a license to use, modify,
# compile, and create derivative works of the Software.  Licensee has the right
# to distribute object form only for use with RTI products. The Software
# is provided "as is", with no warranty of any type, including any warranty for
# fitness for any purpose. RTI is under no obligation to maintain or
# support the Software.  RTI shall not be liable for any incidental
# or consequential damages arising out of the use or inability to
# use the software.
##############################################################################
FROM debian:buster-slim as builder
LABEL "com.example.vendor"="Real-Time Innovations" \
    version="1.2" \
    maintainer="israel@rti.com" \
    description="This image helps you to debug your network issues with \
    RTI Connext DDS and RTI Micro."

# Install some packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        zip \
        curl \
        dnsutils \
        iperf \
        iproute2 \
        iputils-* \
        nmap \
        net-tools \
        netcat \
        python \
        python-pip \
        tcpdump \
        tcpflow \
        traceroute \
        vim \
        wget \
        python-setuptools

# Install RTI Connector
RUN git clone --recurse-submodules \
        https://github.com/rticommunity/rticonnextdds-connector-py.git && \
    pip install -e rticonnextdds-connector-py && \
    rm -rf \
        /usr/local/lib/python2.7/dist-packages/lib/armv6vfphLinux3.xgcc4.7.2 \
        /usr/local/lib/python2.7/dist-packages/lib/armv7aAndroid2.3gcc4.8 \
        /usr/local/lib/python2.7/dist-packages/lib/armv7aQNX6.5.0SP1qcc_cpp4.4.2 \
        /usr/local/lib/python2.7/dist-packages/lib/i86Linux3.xgcc4.6.3 \
        /usr/local/lib/python2.7/dist-packages/lib/i86Win32VS2010 \
        /usr/local/lib/python2.7/dist-packages/lib/x64Darwin16clang8.0 \
        /usr/local/lib/python2.7/dist-packages/lib/x64Win64VS2013 && \
    apt-get autoremove -y

# Install RTI Logparser
RUN git clone https://github.com/rticommunity/rticonnextdds-logparser.git
WORKDIR /rticonnextdds-logparser
RUN ./create_redist.sh && \
    cp /rticonnextdds-logparser/rtilogparser /usr/local/bin/

# Add the ddsping application to the container
COPY ddsping.py /usr/local/bin/ddsping
COPY PingConfiguration.xml /usr/local/bin

FROM debian:buster-slim

COPY --from=builder /usr /usr
