#!/bin/bash

set -e

echo "Setting up Bluebox environment..."

# Get to the project root
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# Ensure necessaries directories exist
mkdir -p /var/elasticsearch
sudo chown -R $USER:$USER /var/elasticsearch
sudo chmod -R 755 /var/elasticsearch

# Setup system limits for elasticsearch
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-elasticsearch.conf
sudo sysctl -p /etc/sysctl.d/99-elasticsearch.conf

# Start ELK stack
echo "Starting ELK stack..."
cd $PROJECT_ROOT/docker/elk
docker-compose up -d

# Wait for elasticsearch to be ready
echo "Waiting for Elasticsearch to be ready..."
while ! curl -s "http://localhost:9200/_cluster/health" | grep -q '"status":"green"'; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done

# Start suricata
echo "Starting suricata..."
cd $PROJECT_ROOT/docker/suricata
docker-compose up -d

# Start filebeat to connect suricata logs to elk
echo "Starting Filebeat..."
docker-compose -f filebeat-compose.yml up -d

echo "Bluebox environment setup complete!"
echo "Kibana is available at http://localhost:5601"
echo "Elasticsearch is available at http://localhost:9200"

exit 0
