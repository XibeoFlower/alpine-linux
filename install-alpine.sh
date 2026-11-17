#!/usr/bin/env bash
# install-alpine.sh - Cai dat Alpine Linux len VPS (thay the he dieu hanh hien tai)
#
# CANH BAO: Script se XOA TOAN BO du lieu tren VPS va cai lai thanh Alpine Linux.
# Chay duoi quyen root tren VPS Debian/Ubuntu/CentOS... dang chay.
#
# Cach dung:
#   bash install-alpine.sh              # cai ban Alpine moi nhat
#   bash install-alpine.sh 3.22         # cai phien ban chi dinh
#
# Script dung cong cu ma nguon mo "reinstall" cua bin456789:
#   https://github.com/bin456789/reinstall

set -euo pipefail

ALPINE_VERSION="${1:-}"
REINSTALL_URL="https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh"

if [ "$(id -u)" -ne 0 ]; then
  echo "Loi: hay chay script bang root (sudo -i)." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "Loi: can cai curl hoac wget truoc." >&2
  exit 1
fi

echo "=============================================="
echo " Cai Alpine Linux len VPS nay"
echo " TOAN BO DU LIEU TREN O DIA SE BI XOA!"
echo "=============================================="
read -r -p "Go YES de tiep tuc: " CONFIRM
[ "$CONFIRM" = "YES" ] || { echo "Da huy."; exit 1; }

# Mat khau root moi
while true; do
  read -r -s -p "Dat mat khau root moi cho Alpine: " PASS1; echo
  read -r -s -p "Nhap lai mat khau: " PASS2; echo
  if [ -z "$PASS1" ]; then
    echo "Mat khau khong duoc de trong."
  elif [ "$PASS1" != "$PASS2" ]; then
    echo "Hai lan nhap khong khop, thu lai."
  else
    break
  fi
done

# Cong SSH (Enter de dung mac dinh 22)
read -r -p "Cong SSH [22]: " SSH_PORT
SSH_PORT="${SSH_PORT:-22}"
if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ]; then
  echo "Cong SSH khong hop le." >&2
  exit 1
fi

# Tai script reinstall
WORKDIR="$(mktemp -d)"
cd "$WORKDIR"
echo "Dang tai script cai dat..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL -o reinstall.sh "$REINSTALL_URL"
else
  wget -q -O reinstall.sh "$REINSTALL_URL"
fi

# Chay cai dat: se tai Alpine, cau hinh va tu khoi dong lai
echo "Bat dau cai dat. VPS se tu khoi dong lai, hay cho khoang 5-10 phut."
bash reinstall.sh alpine ${ALPINE_VERSION:+"$ALPINE_VERSION"} \
  --password "$PASS1" \
  --ssh-port "$SSH_PORT"

# Neu script reinstall chua tu reboot thi nhac nguoi dung
echo
echo "Xong buoc chuan bi. Neu VPS chua tu khoi dong lai, hay chay: reboot"
echo "Sau do ket noi: ssh -p $SSH_PORT root@<IP-VPS>"
