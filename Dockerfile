FROM debian

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get install -y ca-certificates
COPY build/batchcli-v0.0.5-linux-amd65/batchcli /usr/local/bin/batchcli
RUN chmod +x /usr/local/bin/batchcli

ENTRYPOINT ["/usr/local/bin/batchcli"]
