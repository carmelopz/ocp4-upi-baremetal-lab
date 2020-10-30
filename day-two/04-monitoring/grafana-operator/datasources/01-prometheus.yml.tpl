apiVersion: integreatly.org/v1alpha1
kind: GrafanaDataSource
metadata:
  name: prometheus-ocp4
  namespace: grafana-operator
  labels:
    app: grafana-operator
    component: prometheus
spec:
  name: prometheus-ocp4.yaml
  datasources:
    - name: Prometheus-OCP4
      type: prometheus
      access: proxy
      isDefault: true
      editable: true
      url: https://thanos-querier.openshift-monitoring.svc.cluster.local:9091
      jsonData:
        httpHeaderName1: 'Authorization'
        timeInterval: 5s
        tlsSkipVerify: true
      basicAuth: false
      secureJsonData:
        httpHeaderValue1: 'Bearer ${PROMETHEUS_TOKEN}'
