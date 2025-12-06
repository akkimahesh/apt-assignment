
---

# 📘 **apt-assignment – AWS DevOps Assessment**

> **NOTE:**
> Install **Terraform** and **AWS CLI**, then configure credentials using:

```
aws configure
```

This project deploys a secure 2-tier architecture using **Terraform**:

* **VPC with public & private subnets**
* **NAT gateway** for private subnet internet access
* **Application Load Balancer (ALB)**
* **Auto Scaling Group (ASG) with EC2 instances**
* **NodeJS REST API on port 8080**
* **Secure communication using SG → SG rules**

---

# 🚀 **Deployment Steps (Using Terraform Only)**

Below are the clear step-by-step instructions for completing the assignment.

---

## 🧱 **Step 1 — VPC & Networking Setup**

Using Terraform, create:

### ✔️ VPC

* CIDR: `10.0.0.0/16`

### ✔️ 2 Public Subnets

* `10.0.0.0/24` (AZ: ap-south-1a)
* `10.0.1.0/24` (AZ: ap-south-1b)

### ✔️ 2 Private Subnets

* `10.0.2.0/24` (AZ: ap-south-1a)
* `10.0.3.0/24` (AZ: ap-south-1b)

### ✔️ Internet Gateway (IGW)

Attach to the VPC → Needed for ALB & public subnets.

### ✔️ NAT Gateway

Create inside **public subnet 1** with Elastic IP.
NAT gives **internet access for private EC2** to install packages.

### ✔️ Route tables

* **Public RT** → Route `0.0.0.0/0` via IGW → attach to public subnets
* **Private RT** → Route `0.0.0.0/0` via NAT → attach to private subnets

---

## 🔐 **Step 2 — Security Groups**

Create 2 security groups:

---

### **1️⃣ ALB-SG (Public)**

Inbound:

* Allow **HTTP (80)** from `0.0.0.0/0`
* Allow **8080 (optional)** from `0.0.0.0/0` *(if testing directly)*

Outbound:

* Allow all (default)

---

### **2️⃣ EC2-SG (Private instances)**

Inbound:

* Allow **port 8080** **ONLY from ALB-SG**
  (This secures traffic to backend)

Outbound:

* Allow all (default)

---

### **Why this is important?**

* ALB is public
* EC2 instances must remain **private & secure**
* Only ALB can talk to EC2 on port 8080
* No public access to backend

---

## 🔍 **Step 3 — AMI Datasource**

Use Terraform data source to fetch the **latest Amazon Linux 2023 AMI**:

```
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

This AMI ID is used in **Launch Template**.

---

## ⚙️ **Step 4 — Application Load Balancer & Target Group**

### ✔️ Create ALB

* Type: `application`
* Scheme: internet-facing
* Subnets: both public subnets
* SG: `ALB-SG`

### ✔️ Create Target Group

* Target type: `instance`
* Port: **8080**
* Protocol: HTTP
* Health check:

  * Path: `/health`
  * Port: traffic port (8080)
  * Healthy threshold: 2

### ✔️ Create ALB Listener

* Listener: port **80**
* Default action → forward to target group

---

## ⚙️ **Step 5 — Launch Template**

Create a Launch Template:

* AMI → reference data source
* Instance type → t2.micro
* Security group → EC2-SG
* User data → install NodeJS, clone repo, run app on port 8080
* IAM instance profile → SSM + CloudWatch access

---

## ⚙️ **Step 6 — Auto Scaling Group (ASG)**

Create ASG using:

* Launch Template
* Private subnets (no public access)
* Min = desired = max = **2 instances**
* Attach to target group → ALB health checks manage instance health

ASG tags:

* Name → auto-tag EC2 instances

---

## 🌐 **Step 7 — REST API (NodeJS App)**

API runs on **port 8080** with endpoints:

### `/`

Returns:

```
Hello from private EC2!
```

### `/health`

Returns:

```
ok
```

### Logs

All logs printed using `console.log()` → goes to **stdout**

---

## 🧪 **Step 8 — Testing**

### 1️⃣ Check ALB DNS

```
terraform output application_load_balancer_dns_name
```

Example:

```
assignment-alb-123456.ap-south-1.elb.amazonaws.com
```

### 2️⃣ Test endpoints

```
curl http://<alb-dns>/
curl http://<alb-dns>/health
```

Expected:

```
Hello from private EC2!
ok
```

### 3️⃣ Check target health

AWS → EC2 → Target Groups → Targets
Should show:

```
healthy
```

---

## 🧹 **Step 9 — Destroy**

```
terraform destroy -auto-approve
```

This removes:

* VPC, subnets
* NAT Gateway (important: costs money)
* ALB
* ASG & EC2
* IAM roles

---

# 🏁 **Conclusion**

This project demonstrates:

✔ VPC design
✔ Secure architecture (public ALB → private EC2)
✔ NAT for outbound internet
✔ Terraform IaC
✔ Autoscaling Group
✔ Load Balancing
✔ Node API deployment
✔ Health checks
✔ Logging via stdout

---

---

# 🏁 **Screenshots**

---


