FROM ruby:2.1.5
MAINTAINER Justin Hennessy <justin.hennessy@everydayhero.com>

RUN mkdir /srv/app
ENV HOME /srv/app
WORKDIR /srv/app/

ADD Gemfile Gemfile.lock /srv/app/
RUN bundle install

ADD . /srv/app/

CMD ["./serve"]

