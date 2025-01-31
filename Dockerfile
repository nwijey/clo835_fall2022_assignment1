FROM ubuntu:20.04
RUN apt-get update -y
COPY . /app
WORKDIR /app
RUN set -xe \
    && apt-get update -y \
    && apt-get install -y python3-pip \
    && apt-get install -y mysql-client 
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
EXPOSE 8081
ENV APP_COLOR=blue
ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]
