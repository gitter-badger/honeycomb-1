FROM alpine

# build-base and python3-dev might be required by honeycomb plugins
RUN apk add --no-cache build-base python3-dev tini bash && \
	wget -qO- https://bootstrap.pypa.io/get-pip.py | python3 && \
	pip install virtualenv

# ensure honeycomb user exists
RUN set -x && \
	addgroup -g 1000 -S honeycomb && \
	adduser -u 1000 -D -S -G honeycomb honeycomb

# set default home and permissions
ENV HC_HOME /usr/share/honeycomb
RUN mkdir ${HC_HOME} && chown -vR 1000:1000 ${HC_HOME}

# drop privileges and install honeycomb
USER 1000
COPY --chown=1000:1000 requirements.txt /app/requirements.txt
WORKDIR /app
RUN virtualenv /app/venv && \
	/app/venv/bin/pip install -r requirements.txt
ENV PATH /app/venv/bin:${PATH}

COPY --chown=1000:1000 . /app/
RUN pip install --editable .

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /usr/share/honeycomb
CMD ["honeycomb", "--config", "${HC_HOME}/honeycomb.yml"]