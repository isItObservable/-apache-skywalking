FROM grafana/k6:0.48.0
COPY --chown=root:root ./loadgenerator.js ./loadgenerator.js
ENTRYPOINT ["k6","run","./loadgenerator.js"]