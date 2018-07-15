docker rm -f container-ruby
docker rm -f selenium-hub
docker pull  selenium/standalone-chrome
docker run -d -p 4444:4444 --name selenium-hub selenium/standalone-chrome
docker build -t cucumber/cucumber .
