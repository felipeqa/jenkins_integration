docker run -v "$(pwd):/opt/jenkins" -e BROWSER=remote -e TAG=backend -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm container-ruby
docker rm selenium-hub
