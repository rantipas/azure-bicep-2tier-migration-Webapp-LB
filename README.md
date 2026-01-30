# Secure 2-Tier Azure Infrastructure with Bicep

This repository demonstrates a modular **Infrastructure as Code (IaC)** deployment using **Azure Bicep**. It simulates a migration of a legacy on-premise ASP.NET application to a secure Azure environment.

## 🏗️ Architecture Overview
The project builds a **2-Tier Architecture** (Web Tier + Data Tier) designed with security best practices:

* **Web Tier:** Two Windows Server 2022 VMs running IIS, configured via Custom Script Extensions (PowerShell).
* **Load Balancing:** A **Standard Public Load Balancer** distributes traffic to the Web Tier on Port 80.
* **Data Tier:** An **Azure SQL Database** secured with a **Private Endpoint** (no public internet access).
* **Security:**
    * **Network Security Groups (NSGs)** restrict traffic to only necessary ports (HTTP, RDP).
    * **Private DNS Zones** handle internal resolution for the database.
    * **Web Deploy** installed manually for application deployment.

## 🛠️ Technology Stack
* **IaC:** Azure Bicep (Modular design)
* **Scripting:** PowerShell (Automation & Validation)
* **Compute:** Azure Virtual Machines (Windows Server)
* **Networking:** Virtual Network (VNet), Public Load Balancer, Private Link
* **Database:** Azure SQL Database

## 🚀 Deployment Instructions
1.  Clone the repository.
2.  Run the deployment command:
    ```powershell
    New-AzResourceGroupDeployment -ResourceGroupName "YourRG" -TemplateFile main.bicep -TemplateParameterFile main.bicepparam
    ```
3.  Application connects securely using the private SQL connection string.
