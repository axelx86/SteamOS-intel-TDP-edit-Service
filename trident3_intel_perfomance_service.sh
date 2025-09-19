#!/usr/bin/bash

UNIT=intel-powerlimit.service

PL1_VALUE="${1:-45}"   # Вт
PL2_VALUE="${2:-75}"   # Вт

echo "================================================================="
echo "User input values: PL1=[${PL1_VALUE}w] | PL2=[${PL2_VALUE}w]"
echo "================================================================="

#PL1=`cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw`
#PL2=`cat /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw`

PL1=$(cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw)
PL2=$(cat /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw)

echo "================================================================="
echo "System values before: PL1 = [${PL1}w] | PL2 = [${PL2}w]"
echo "================================================================="

sudo tee /etc/systemd/system/${UNIT} > /dev/null <<EOF
[Unit]
Description=Set Intel CPU Power Limits
After=multi-user.target

[Service]
Type=oneshot
#ExecStart=/bin/sh -c 'echo ${PL1_VALUE}000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw'
#ExecStart=/bin/sh -c 'echo ${PL2_VALUE}000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw'
ExecStart=/bin/sh -c 'echo ${PL1_VALUE}000000 | tee /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw'
ExecStart=/bin/sh -c 'echo ${PL2_VALUE}000000 | tee /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
# sudo systemctl enable --now intel-powerlimit.service
# sudo systemctl restart intel-powerlimit.service

if ! systemctl is-enabled --quiet $UNIT 2>/dev/null; then
    echo "The service does not exist or is not enabled — enabling and starting"
    sudo systemctl enable --now $UNIT
else
    echo "The service already exists — just restart"
    sudo systemctl restart $UNIT
fi

sudo systemctl status intel-powerlimit.service --no-pager

PL1=$(cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw)
PL2=$(cat /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw)

echo "================================================================="
echo "System values after: PL1 = ${PL1}w | PL2 = ${PL2}w"
echo "================================================================="
