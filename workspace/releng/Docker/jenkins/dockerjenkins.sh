#!/bin/bash

docker daemon &
exec java -jar /opt/jenkins/jenkins.war
