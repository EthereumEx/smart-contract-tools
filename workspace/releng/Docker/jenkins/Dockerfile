FROM ubuntu:14.04
MAINTAINER dan@keoja.com
ENV REFRESHED_AT 2016-05-27

# Build with: 
# sudo docker build -t "ford/jenkins" .
# Run with:
# docker run -p 8080:8080 --name jenkins --privileged -d ford/dockerjenkins

RUN apt-get update -qq
RUN apt-get install -qq -y curl apt-transport-https
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list
RUN apt-get update -qq
RUN apt-get install -qqy iptables ca-certificates openjdk-7-jdk git-core docker-engine
#RUN apt-get -y install maven

ENV JENKINS_HOME /opt/jenkins/data
ENV JENKINS_MIRROR http://mirrors.jenkins-ci.org

RUN mkdir -p $JENKINS_HOME/plugins
RUN curl -sf -o /opt/jenkins/jenkins.war -L $JENKINS_MIRROR/war-stable/latest/jenkins.war

RUN for plugin in chucknorris greenballs scm-api git-client git ws-cleanup;\
        do   curl -sfL -o $JENKINS_HOME/plugins/${plugin}.hpi \
	        $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi;\
        done

# Jenkins Configuration
ADD ./config.xml $JENKINS_HOME/config.xml

# Map the jobs and their configuration files
RUN mkdir -p $JENKINS_HOME/jobs/SolidityBuild_mars
ADD ./jobs/SolidityBuild_mars/config.xml $JENKINS_HOME/jobs/SolidityBuild_mars/config.xml

ADD ./dockerjenkins.sh /usr/local/bin/dockerjenkins.sh
RUN chmod +x /usr/local/bin/dockerjenkins.sh

VOLUME /var/lib/docker

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dockerjenkins.sh"]
