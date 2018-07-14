#docker run -v $(pwd):/tmp -e ENV=${ENV} -e SLACK=${SLACK} -e MY_PROFILE=${MY_PROFILE} -t product-editor-acceptance-tests $@
docker run -v "${pwd}":/opt/jenkins -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm container-ruby
