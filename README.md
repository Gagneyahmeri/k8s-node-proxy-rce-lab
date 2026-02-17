Requires tool: https://github.com/vi/websocat 
Comes precompiled for x86 in this repo.

# Kubernetes Node Proxy Lab (Privilege Escalation)

## 1. Project Overview

This mini-lab demonstrates a Kubernetes RBAC vulnerability involving the `nodes/proxy` subresource. It simulates a real-world misconfiguration where a monitoring service account is granted excessive permissions, allowing an attacker to bypass namespace restrictions and execute commands on any pod on the node.

**Features:**
- Automatically downloads `kind`, `kubectl`, and `websocat` locally. No global installation required.
- Deploys a victim pod and exploits it using the Kubernetes API Proxy.
- Applies a patch to remove the permission and verifies the exploit no longer works.
- A bonus "Capture The Flag" mode with a restricted `kubeconfig` file.

---

## 2. Prerequisites

* **Docker:** Must be installed and running (required for Kind).
* **Git:** To clone this repository.
* **Websocat** to use the exploit script and interact with the vulnerable pod using websockets.

---

## 3. Directory Structure

```text
k8s-node-proxy-lab/
├── bin/                    # Binaries (kind, kubectl, websocat) are downloaded here
├── setup.sh                # 1. Starts Cluster & Installs Tools
├── teardown.sh             # 4. Deletes Cluster
├── vulnerable/             # [Scenario A] The Exploit
│   ├── run_vuln.sh         # Deploys vulnerable RBAC & Victim
│   ├── exploit.sh          # Proof-of-Concept Exploit (Reads Flag)
│   └── Better_exploit.sh   # Advanced Exploit (Accepts arguments)
├── challenge/              # [Bonus] CTF Mode
│   └── deploy.sh           # Generates 'player.kubeconfig'
└── solution/               # [Bonus] Answer Key
    └── solve.sh            # Solves the CTF
```

## 4. Running the Lab

**Step 1: Initial setup**

Run the setup script to initialize the environemnt. Setup script will download necessary tools and setup the Kubernetes cluster.
`./setup.sh`

**Step 2: Vulnerable scenario**

You can run vulnerable by going into folder and running the script inside the folder.
```
cd vulnerable
./run_vuln.sh
```

**Step 3: Running exploit**

```
./exploit.sh
```

**Step 4: CTF challenge**

Based on same scenario, but can be possibly used in CTF. Idea is that player finds a kubernetes config with nodes/proxy permission and manages to pivot to other machines using that.

```
cd ../challenge
./deploy.sh
```

## 5. Technical details

## 6. Mitigations

You might wonder why Kubernetes allows `nodes/proxy` to bypass namespace restrictions by default. The Kubernetes Security Team has determined this is "Working as Intended" for architectural reasons.

### The Problem
Patching `nodes/proxy` to inspect the sub-path (e.g., blocking `/exec` but allowing `/metrics`) would require the API Server to parse and understand HTTP streams intended for the Kubelet.

### The Future Solution (KEP-2862)
Instead of patching the old `nodes/proxy` mechanism, Kubernetes is introducing "Fine-Grained Kubelet API Authorization (KEP-2862)".
* **Current State:** We grant `nodes/proxy` (ALL access).
* **Future State (v1.36+):** We will grant `nodes/metrics`, `nodes/stats`, or `nodes/log`.
* **Result:** Monitoring tools will get exactly what they need without ever having access to `nodes/exec`.

**Why KEP-2862 was not used in this lab:**
This feature is a upcoming feature in Kubernetes v1.36 (April 2026). 
As this lab targets standard, widely-deployed Kubernetes environments, solution is to remove the permission or use hardened kubernetes runtime like Edera.


## 6. Resources used

Understanding the nodes/proxy: https://grahamhelton.com/blog/nodes-proxy-rce

Configs are based on this source: https://www.sourcery.ai/vulnerabilities/kubernetes-default-service-account

Exploit script uses mostly this logic: https://labs.iximiuz.com/tutorials/nodes-proxy-rce-c9e436a9




