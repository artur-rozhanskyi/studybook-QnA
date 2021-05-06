FROM ruby:2.6.3
MAINTAINER Artur Rozhanskyi <artur.rozhanskyi@nixsolutions.com>
USER root

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash \
 && apt-get update && apt-get install -y nodejs sphinxsearch && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*

ENV APP_USER app
ENV APP_USER_HOME /home/$APP_USER
ENV APP_HOME /home/$APP_USER/qna

RUN useradd -m -d $APP_USER_HOME $APP_USER

RUN mkdir $APP_HOME -p

RUN chown -R $APP_USER $APP_USER_HOME

USER $APP_USER

WORKDIR $APP_HOME

RUN yarn install --check-files

RUN gem install bundler

COPY ./Gemfile ./Gemfile.lock ./

RUN bundle install --jobs 20 --retry 5 --without development production
