#!/bin/sh
# test: used to run the test suite of the application.

#docker run -v $(pwd):/tmp -e ENV=${ENV} -e SLACK=${SLACK} -e MY_PROFILE=${MY_PROFILE} -t product-editor-acceptance-tests $@
docker run -v "$(pwd)":/opt/jenkins -e BROWSER=${BROWSER} -e TAG=${TAG} -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm -f container-ruby
docker rm -f selenium-hub
