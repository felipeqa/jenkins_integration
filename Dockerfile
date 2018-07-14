FROM ruby:2.3

ENV app_path /opt/jenkins/
WORKDIR ${app_path}

COPY Gemfile* ${app_path}

RUN bundle install


COPY . ${app_path}

ENTRYPOINT ["bundle", "exec", "cucumber BROWSER=remote --format json -o /opt/jenkins/cucumber.json"]
