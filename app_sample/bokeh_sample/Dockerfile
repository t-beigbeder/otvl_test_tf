FROM quay.io/sclorg/python-311-c9s
USER 0
ADD requirements.txt .
RUN pip install -r requirements.txt
ADD python/bokeh_sample.py .
RUN chown -R 1001:0 ./
USER 1001

ENV BOKEH_SERVER_OPTS --use-xheaders
# --use-xheaders --allow-websocket-origin=alb-a1b2-dev-private-1246541786.eu-west-3.elb.amazonaws.com
CMD bokeh serve bokeh_sample.py ${BOKEH_SERVER_OPTS}
