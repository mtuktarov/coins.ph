FROM jenkins/jenkins:alpine
USER root
RUN echo "======Installing tools======"                         &&  \
    apk --no-cache add tzdata shadow                            &&  \
    echo "======Configuring local time======"                   &&  \
    /bin/ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime

COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
COPY installPlugins.groovy /usr/share/jenkins/ref/init.groovy.d/installPlugins.groovy
COPY plugins.txt /usr/share/jenkins/ref/init.groovy.d/plugins.txt
COPY plugins.txt /tmp/plugins.txt

ADD http://updates.jenkins-ci.org/latest/jenkins.war /usr/share/jenkins/jenkins.war
RUN echo "======Configuring latest jenkins version======"       &&  \
    chmod 644 /usr/share/jenkins/jenkins.war

ADD https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/linux/amd64/kubectl /bin/kubectl
RUN echo "======Configuring kubectl tool================"       &&  \
    chmod 755 /bin/kubectl

RUN echo "======Configuring docker tool================"        &&  \
    addgroup -g 994 docker                                      &&  \
    apk add docker && usermod -aG docker jenkins && apk del shadow

ADD https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64 /bin/yq
RUN echo "======Configuring yq tool================"            &&  \
    chmod 755 /bin/yq

RUN echo "======Installing jenkins plugins======"               &&  \
    /usr/local/bin/plugins.sh /tmp/plugins.txt                  &&  \
    rm /tmp/plugins.txt

WORKDIR /var/jenkins_home
USER jenkins
