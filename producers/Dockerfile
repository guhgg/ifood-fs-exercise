FROM python:3.8

ENV APP_DIR /feature_store

RUN mkdir -p ${APP_DIR}

WORKDIR ${APP_DIR}

COPY . .

RUN pip install -U -r requirements.txt 