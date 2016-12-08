#!/bin/bash
curl -G http://influxdb:8086/query --data-urlencode "q=CREATE DATABASE influxdb" &&\
curl -G http://influxdb:8086/query --data-urlencode "q=CREATE DATABASE grafana"