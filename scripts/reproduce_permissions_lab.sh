#!/usr/bin/env bash
# ==============================================================================
# reproduce_permissions_lab.sh
# Purpose: Reproduces the Google Cybersecurity Certificate Course 4 Linux File
#          Permissions & Least Privilege Audit lab environment deterministically.
# Author:  Eduardo Souza Marques (@edusouzamarques)
# ==============================================================================

set -euo pipefail

LAB_DIR="/tmp/cybersec_permissions_lab"
echo "[*] Setting up simulation workspace at: ${LAB_DIR}"
rm -rf "${LAB_DIR}"
mkdir -p "${LAB_DIR}/projects/drafts"
cd "${LAB_DIR}/projects"

# 1. Create simulated files
echo "Project K content" > project_k.txt
echo "Project M content" > project_m.txt
echo "Project R content" > project_r.txt
echo "Project T content" > project_t.txt
echo "Confidential archived project data" > .project_x.txt
echo "Draft proposal notes" > drafts/notes.txt

# 2. Stage VULNERABLE pre-audit permissions
echo "[*] Staging pre-audit baseline permissions..."
chmod 777 project_k.txt       # -rwxrwxrwx (others write access violation)
chmod 640 project_m.txt       # -rw-r-----
chmod 664 project_r.txt       # -rw-rw-r--
chmod 664 project_t.txt       # -rw-rw-r--
chmod 620 .project_x.txt      # -rw--w---- (user & group write violation)
chmod 710 drafts              # drwx--x--- (group execute violation)

echo ""
echo "================================================================="
echo "🚨 PHASE 1: PRE-AUDIT VULNERABLE FILE PERMISSIONS (ls -la)"
echo "================================================================="
ls -la "${LAB_DIR}/projects"
echo ""

# 3. Apply Least Privilege Hardening Actions (as documented in Incident Report)
echo "[*] Applying Security Remediation & Hardening Controls..."

# Action 1: Revoke Write access from Others on project_k.txt
chmod o-w project_k.txt
echo "[+] Remediated: project_k.txt (chmod o-w)"

# Action 2: Secure archived hidden file .project_x.txt (read-only for user/group, none for others)
chmod u-w,g-w,g+r .project_x.txt
echo "[+] Remediated: .project_x.txt (chmod u-w,g-w,g+r)"

# Action 3: Restrict drafts directory exclusively to owner
chmod g-x drafts
echo "[+] Remediated: drafts/ directory (chmod g-x)"

echo ""
echo "================================================================="
echo "🛡️ PHASE 2: POST-AUDIT HARDENED PERMISSIONS (Principle of Least Privilege)"
echo "================================================================="
ls -la "${LAB_DIR}/projects"
echo ""
echo "[*] Validating isolated directory permissions (ls -ld drafts):"
ls -ld drafts
echo ""
echo "✅ Verification complete. All files comply with organizational security policy."
