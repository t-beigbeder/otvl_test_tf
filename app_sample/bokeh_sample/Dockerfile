FROM python:3.11 as build-stage
RUN apt-get update && apt-get install -y virtualenv && rm -rf /var/lib/apt/lists/*
RUN python -m venv /venv
RUN mkdir -p /python
ADD requirements.txt /python
RUN /venv/bin/pip install -r /python/requirements.txt

FROM python:3.11
COPY --from=build-stage /venv /venv
RUN addgroup --gid 1000 guest && \
  adduser --disabled-password --ingroup guest --uid 1000 --shell /bin/sh --gecos guest guest
ADD python /python
WORKDIR /python
ADD shell/entrypoint.sh /
RUN chmod +x /entrypoint.sh
USER guest:guest

ENTRYPOINT /entrypoint.sh /venv/bin/bokeh serve bokeh_sample.py
