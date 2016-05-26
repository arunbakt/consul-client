FROM gliderlabs/consul
COPY service-registration-handler.sh /service-registration-handler.sh
COPY key-value-update.sh /key-value-update.sh
COPY consul-client-agent.json /consul-client-agent.json
RUN chmod +x /key-value-update.sh
RUN curl -o /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod +x /usr/bin/jq
ENTRYPOINT ["/bin/consul"]
CMD /service-registration-handler.sh
