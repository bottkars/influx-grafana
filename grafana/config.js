  datasources: {
    influxdb: {
      type: 'influxdb',
      url: "http://influxdb:8086/db/influxdb",
      username: 'root',
      password: 'root',
    },
    grafana: {
      type: 'influxdb',
      url: "http://influxdb:8086/db/grafana",
      username: 'root',
      password: 'root',
      grafanaDB: true
    },
  },