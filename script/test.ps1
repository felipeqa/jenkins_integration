docker run -v "${pwd}:/opt/jenkins" -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm container-ruby
