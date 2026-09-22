# Flying Nimbus Code-Based Prototype

This directory contains the initial code-based prototype for Section 4 of the Flying Nimbus Capstone proposal.

## Prototype representation

- `diagram/flying-nimbus-architecture.svg` is the graphical architecture representation.
- `terraform/` contains the Proxmox VM provisioning configuration.
- `ansible/` contains post-deployment configuration for the Kubernetes control plane, worker, and validation client.

The physical environment is not yet deployed. The code and diagram are the initial prototype artifacts and must be adapted to the actual Proxmox node names, datastores, network, credentials, and available hardware before deployment.

## Architecture assumption

The Terraform configuration assumes that the two Proxmox hosts belong to the same Proxmox VE cluster and are reachable through one Proxmox API endpoint. If the hosts are separate standalone Proxmox servers, the configuration will need separate provider configurations and state handling.

## Layer boundaries

- Terraform provisions the VM layer.
- Ansible configures the operating systems and bootstraps the Kubernetes cluster.
- The Gradebook repository's GitHub Actions workflow builds and deploys the application.
- Project testers validate the application from the client VM.

## Validation status

The SVG was rendered and visually inspected. The Ansible YAML parses successfully. Terraform and Ansible executables are not installed in this workspace, so live provider validation and remote playbook execution remain to be performed against the actual lab environment.
