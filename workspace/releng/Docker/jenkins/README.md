Build with: 
sudo docker build -t "ford/jenkins" .
Run with:
docker run -p 8080:8080 --name jenkins --privileged -d ford/dockerjenkins