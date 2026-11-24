# Generate snmp.yml from generator.yml
# prom/snmp-generator は amd64 のみ。arm64 ランナーでも amd64 で実行する (snmp.yml は arch 非依存)
# hadolint ignore=DL3029
FROM --platform=linux/amd64 prom/snmp-generator:v0.30.1 AS generator-image

WORKDIR /opt/mibs
COPY Dockerfile/snmp-exporter/mibs .

WORKDIR /opt
COPY Dockerfile/snmp-exporter/generator.yml .
RUN /bin/generator generate

FROM prom/snmp-exporter:v0.30.1

WORKDIR /etc/snmp_exporter
COPY --from=generator-image /opt/snmp.yml .
