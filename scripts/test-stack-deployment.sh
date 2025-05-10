#!/bin/bash

set -e

# Colors for better readibility
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # no color

echo -e "${YELLOW}=== DEPLOYMENT TEST OF BLUEBOX STACK ===${NC}"

# Check docker is installed and running
echo -e "\n${YELLOW}Checking Docker...${NC}"
if command -v docker &> /dev/null && docker info &> /dev/null; then
  echo -e "${GREEN}Docker is installed and runs properly${NC}"
else
  echo -e "${RED}Docker is not installed or does not function properly${NC}"
  exit 1
fi

# Check installation of docker-compose
echo -e "\n${YELLOW}Checking Docker Compose...${NC}"
if command -v docker-compose &> /dev/null; then
  echo -e "${GREEN}Docker Compose is installed${NC}"
else
  echo -e "${RED}Docker Compose is not installed${NC}"
  exit 1
fi

# Stop existing containers (clean test)
echo -e "\n${YELLOW}Stopping existing containers...${NC}"
cd ~/bluebox/docker/elk
docker-compose down 2>/dev/null || true
cd ~/bluebox/docker/suricata
docker-compose down 2>/dev/null || true
docker-compose -f filebeat-compose.yml down 2>/dev/null || true

# Check/create data directory for elasticsearch
echo -e "\n${YELLOW}Configuration of Elasticsearch's data directory...${NC}"
if [ ! -d "/var/elasticsearch" ]; then
  echo "Creating directory /var/elasticsearch..."
  sudo mkdir -p /var/elasticsearch
fi
sudo chown -R $USER:$USER /var/elasticsearch
sudo chmod -R 755 /var/elasticsearch
echo -e "${GREEN}Data directory configured${NC}"

# Ensure memory limit for elasticsearch
echo -e "\n${YELLOW}Configuring system limits for Elasticsearch...${NC}"
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-elasticsearch.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/99-elasticsearch.conf > /dev/null
echo -e "${GREEN}System limits configured${NC}"

# Start ELK stack
echo -e "\n${YELLOW}Starting ELK stack...${NC}"
cd ~/bluebox/docker/elk
docker-compose up -d
echo -e "${GREEN}Starting command for ELK executed${NC}"

# Waiting for elasticsearch to be ready
echo -e "\n${YELLOW}Waiting for elasticsearch to start (can take up to 2 minutes)...${NC}"
for i in {1..24}; do
  if curl -s "http://localhost:9200/_cluster/health" | grep -q '"status":\s*"'; then
    echo -e "${GREEN}Elasticsearch is up and running${NC}"
    break
  fi
  if [ $i -eq 24 ]; then
    echo -e "${RED}Elasticsearch did not start properly after 2 minutes${NC}"
    echo -e "${YELLOW}Try checking the logs with: docker logs elasticsearch${NC}"
    exit 1
  fi
  echo -n "."
  sleep 5
done

# Start suricata
echo -e "\n${YELLOW}Starting Suricata...${NC}"
cd ~/bluebox/docker/suricata
docker-compose up -d
echo -e "${GREEN}Starting command for Suricata executed${NC}"

# Check Suricata is running
echo -e "\n${YELLOW}Checking Suricata status...${NC}"
sleep 5
if docker ps | grep -q "suricata"; then
  echo -e "${GREEN}Suricata container is running${NC}"
else
  echo -e "${RED}Suricata container is not running${NC}"
  echo -e "${YELLOW}Check logs with: docker logs suricata${NC}"
  exit 1
fi

# Start filebeat
echo -e "\n${YELLOW}Starting Filebeat...${NC}"
docker-compose -f filebeat-compose.yml up -d
echo -e "${GREEN}Starting command for Filebeat executed${NC}"

# Check filebeat is running
echo -e "\n${YELLOW=Checking filebeat status...${NC}"
sleep 5
if docker ps | grep -q "filebeat"; then
  echo -e "${GREEN}Filebeat container is running${NC}"
else
  echo -e "${RED}Filebeat container is not running${NC}"
  echo -e "${YELLOW}Check logs with: docker logs filebeat${NC}"
  exit 1
fi

# Traffic test for Suricata
echo -e "\n${YELLOW}Traffic test generation...${NC}"
ping -c 5 127.0.0.1 > /dev/null
echo -e "${GREEN}Trafic test generated${NC}"

# Wait for logs to be treated
echo -e "\n${YELLOW}Waiting for logs processing (10 seconds)...${NC}"
sleep 10

# Check web interfaces
echo -e "\n${YELLOW}Checking Kibana access...${NC}"
if curl -s http://localhost:5601 > /dev/null; then
    echo -e "${GREEN}Kibana is available at http://localhost:5601${NC}"
else
    echo -e "${RED}Kibana is not reachable${NC}"
    echo -e "${YELLOW}Check logs with: docker logs kibana${NC}"
fi

echo -e "\n${YELLOW}Checking Elasticsearch access...${NC}"
if curl -s http://localhost:9200 > /dev/null; then
    echo -e "${GREEN}Elasticsearch is available at http://localhost:9200${NC}"
else
    echo -e "${RED}Elasticsearch is not reachable${NC}"
fi

# Sumup
echo -e "\n${YELLOW}=== DEPLOYMENT TEST SUMMARY ===${NC}"
echo -e "Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n${GREEN}Deployment test done!${NC}"
echo -e "To reach Kibana: http://localhost:5601"
echo -e "To reach Elasticsearch: http://localhost:9200"

exit 0
