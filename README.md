# Blue Box - Defensive Operations Platform

**⚠️ WORK IN PROGRESS ⚠️**

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

This repository contains the defensive security components and configurations for our cybersecurity lab environment. The Blue Box serves as our defensive operations center, housing monitoring tools, intrusion detection systems, and security configurations.

## Overview

The Blue Box is designed to:
- Detect and alert on malicious activity within the network
- Log and analyze security events in real-time
- Provide a testbed for defensive security controls
- Host target systems for security testing

## Current Status

This repository is under active development. The core ELK stack (Elasticsearch, Logstash, Kibana, Filebeat, and Nginx) has been implemented using Docker for local log collection and analysis. Suricata IDS/IPS integration is planned. Documentation and automation are still in progress and will be expanded in future updates.

## Key Components

- **Suricata IDS/IPS**: Network intrusion detection and prevention (planned)
- **ELK Stack**: Local log collection and analysis with Dockerized setup
  - Elasticsearch: Log storage and search
  - Logstash: Log processing
  - Kibana: Visualization dashboard
  - Filebeat: Log shipping
  - Nginx: Reverse proxy
- **Security Configurations**: Hardening guidelines and implementations (in progress)
- **Testing Scripts**: Validation of defensive controls (to be added)

## Target Systems

The Blue network hosts a Windows Server 2022 system (`192.168.11.13`) configured as a primary target for security testing, allowing for validation of defensive measures against common attack scenarios.

## Getting Started

### Prerequisites
- Docker and Docker Compose installed
- Git to clone the repository

### Setup Instructions
1. Clone this repository:
   ```bash
   git clone https://github.com/TheoCaudan/bluebox.git
   cd bluebox
   ```
2. Create a `.env` file with your environment variables (e.g., Elasticsearch passwords) and add it to `.gitignore`.
3. Start the ELK stack:
   ```bash
   docker-compose up -d
   ```
4. Access Kibana at `http://localhost:5601` to configure index patterns and visualize logs.
5. (Future) Run the setup script once implemented: `./scripts/setup-bluebox.sh`

### Notes
- Ensure all containers are on the same Docker network (default setup uses `bluebox_net`).
- Check container logs with `docker logs <container_name>` for troubleshooting.

## Future Enhancements
- Integration of Suricata IDS/IPS
- Additional target systems
- Advanced detection rules
- Automated response playbooks
- Integration with threat intelligence feeds
- Host-based intrusion detection

## Network Information

The Blue Box operates on the defensive network (`192.168.11.0/24`) and receives designated attack traffic from the Red network for testing purposes.

## Contributors

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## About This Project

This is a personal portfolio project I developed on my own to showcase my skills in defensive security operations, monitoring, and security engineering. Feel free to use, modify, and learn from this project for your own educational purposes.

The project demonstrates my capabilities in implementing defensive security controls, log aggregation systems (ELK stack), and intrusion detection configurations in a controlled environment.

---

**Last Updated**: June 02, 2025  
**Contact**: Please reach out through GitHub issues for questions

