FROM debian

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get install -y ca-certificates curl

COPY build/batchcli-v0.0.12-linux-amd64/batchcli /usr/local/bin/batchcli
RUN chmod +x /usr/local/bin/batchcli

COPY test-worker/worker.sh /test-worker.sh

ENTRYPOINT ["/usr/local/bin/batchcli"]
# default to just echo inputs
CMD ["--cmd", "/test-worker.sh"]
