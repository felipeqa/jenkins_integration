docker run -v "$(pwd)":/opt/jenkins -e BROWSER=${BROWSER} -e TAG=${TAG} -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm container-ruby
docker rm selenium-hub
