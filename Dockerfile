FROM kalantar/iter8cli:pr-1040-1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
