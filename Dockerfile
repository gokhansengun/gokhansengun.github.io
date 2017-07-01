FROM jekyll/jekyll:3.5 AS build-env

COPY . /src/jekyll

# jekyll docker image uses 'jekyll' as user
# so change all permissions in the folder to jekyll
RUN chown -R jekyll /src/jekyll

WORKDIR /src/jekyll

RUN jekyll clean

RUN jekyll build 

FROM nginx:1.10 AS runtime-env

COPY --from=build-env /src/jekyll/_site /usr/share/nginx/html/
