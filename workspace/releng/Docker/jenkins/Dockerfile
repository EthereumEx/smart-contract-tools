FROM ubuntu:16.04
MAINTAINER dan@keoja.com
ENV REFRESHED_AT 2016-07-05

# Build with: 
# sudo docker build -t "ford/jenkins" .
# Run with:
# docker run -p 8080:8080 --name jenkins --privileged -d ford/dockerjenkins

RUN apt-get update -qq
RUN apt-get install -qq -y curl apt-transport-https
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo deb https://apt.dockerproject.org/repo ubuntu-xenial main > /etc/apt/sources.list.d/docker.list
RUN apt-get update -qq

RUN apt-get -y install software-properties-common
RUN apt-get -y install apt-utils

# Add PPA for Java 7
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update -qq
RUN apt-get -y install openjdk-7-jdk
RUN apt-get -y install openjdk-8-jdk

RUN apt-get install -qqy iptables ca-certificates 
RUN apt-get install -qqy git-core docker-engine

RUN apt-get -y install maven

ENV JENKINS_HOME /opt/jenkins/data
ENV JENKINS_MIRROR http://mirrors.jenkins-ci.org

RUN mkdir -p $JENKINS_HOME/plugins
#RUN curl -sf -o /opt/jenkins/jenkins.war -L $JENKINS_MIRROR/war-stable/latest/jenkins.war
RUN curl -sf -o /opt/jenkins/jenkins.war -L $JENKINS_MIRROR/war/latest/jenkins.war

RUN for plugin in greenballs ws-cleanup;\
        do   curl -sfL -o $JENKINS_HOME/plugins/${plugin}.hpi \
	        $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi;\
        done
      
RUN for plugin in matrix-project ssh-credentials scm-api run-condition conditional-buildstep parameterized-trigger workflow-scm-step credentials mailer git-client token-macro git;\
        do   curl -sfL -o $JENKINS_HOME/plugins/${plugin}.hpi \
	        $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi;\
        done        
    
RUN for plugin in junit script-security matrix-project git;\
        do   curl -sfL -o $JENKINS_HOME/plugins/${plugin}.hpi \
	        $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi;\
        done   
        
RUN for plugin in conditional-buildstep parameterized-trigger;\
        do   curl -sfL -o $JENKINS_HOME/plugins/${plugin}.hpi \
	        $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi;\
        done  
        
RUN for plugin in structs workflow-step-api workflow-scm-step git;\
        do   curl -sfL -o $JENKINS_HOME/plugins/${plugin}.hpi \
	        $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi;\
        done          
        
RUN for plugin in javadoc maven-plugin;\
        do   curl -sfL -o $JENKINS_HOME/plugins/${plugin}.hpi \
	        $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi;\
        done 
                
# Jenkins Configuration
ADD ./config.xml $JENKINS_HOME/config.xml

# Maven Configuration for root
ADD ./toolchains.xml /root/.m2/toolchains.xml

# The definitions of the build jobs and their configuration files
RUN mkdir -p $JENKINS_HOME/jobs/SolidityBuild_mars
ADD ./jobs/SolidityBuild_mars/config.xml $JENKINS_HOME/jobs/SolidityBuild_mars/config.xml

ADD ./dockerjenkins.sh /usr/local/bin/dockerjenkins.sh
RUN chmod +x /usr/local/bin/dockerjenkins.sh

VOLUME /var/lib/docker

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dockerjenkins.sh"]
