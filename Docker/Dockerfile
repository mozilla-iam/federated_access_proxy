FROM centos:latest
MAINTAINER kang <kang@insecure.ws>

# Update image & basic dev tools
RUN yum update -y && \
    yum install -y sudo && \
    yum install -y epel-release && \
    yum groupinstall -y 'Development Tools' && \
    yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
    yum install -y python36u python36u-pip python36u-devel

# Install dumb-init
RUN pip3.6 install dumb-init

# Install access-proxy-specific packages
RUN yum install -y luarocks openssl-devel lua-devel yum-utils

# Install things from luarocks
RUN luarocks install lua-resty-openidc

# Install OpenResty
RUN yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
RUN yum install -y openresty openresty-resty
ENV PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/

# Install app-specific packages
RUN yum install -y rubygem-sass python-virtualenv git

# Logs and setup
USER root
RUN  ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log
COPY etc/conf.d /usr/local/openresty/nginx/conf/conf.d/
COPY etc/nginx.conf /usr/local/openresty/nginx/conf/

# User to run things
RUN useradd -ms /bin/bash user
RUN mkdir /srv/app ; chown user:user /srv/app
USER user
WORKDIR /srv/app

# Deploy app as user
ENV LANG=en_US.utf8
ENV LC_ALL=en_US.utf8
# Force rebuild this step
ARG GITCACHE=1
RUN git clone https://github.com/mozilla-iam/federated_access_proxy/ ./
RUN python3.6 -m venv venv && source venv/bin/activate && \
    cd /srv/app/ && pip3.6 install -r requirements.txt

# Ports and Docker stuff
EXPOSE 80
STOPSIGNAL SIGTERM

# Init
USER root
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "openresty -g 'daemon on;' && sudo -u user -E sh -c 'source venv/bin/activate && /srv/app/start.sh'"]
