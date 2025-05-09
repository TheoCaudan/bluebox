#!/bin/bash

set -e

echo "Testing Bluebox defensive capabilities..."

# Test elasticsearch
echo "Testing Elasticsearch connection..."
if curl -s "http://localhost:9200" | grep -q "You know, for Search"; then
  echo "Elasticsearch is running"
else
  echo "Elasticsearch is not responding"
fi

# Test kibana
echo "Testing Kibana connection..."
if curl -s "http://localhost:5601/api/status" | grep -q "available"; then
  echo "Kibana is running"
else
  echo "Kibana is not responding"
fi

# Test suricata generates logs
echo "Testing Suricata logs..."
if docker logs suricata 2>&1 | grep -q "Engine started"; then
  echo "Suricata is running"
else
  echo "Suricata may not be running properly"
fi

# Generate test alert
echo "Generating test traffic to trigger Suricata alerts..."
ping -c 5 192.168.11.11

# check if alert was registered
sleep 5
echo "Checking for alerts in Elasticsearch..."
if curl -s "http://localhost:9200/suricata-alerts-*/_search?q=event_type:alert" | grep -q "hits"; then
  echo "Alerts are being properly indexed in Elasticsearch"
else
  echo "No alerts found in elasticsearch"
fi

echo "Defense testing complete!"

exit 0
