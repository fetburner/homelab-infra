# Generate snmp.yml from generator.yml
FROM prom/snmp-generator:v0.24.1 AS generator-image

WORKDIR /opt/mibs
COPY Dockerfile/snmp-exporter/mibs .

WORKDIR /opt
COPY Dockerfile/snmp-exporter/generator.yml .
RUN /go/bin/generator generate

FROM prom/snmp-exporter:v0.24.1

WORKDIR /etc/snmp_exporter
COPY --from=generator-image /opt/snmp.yml .
