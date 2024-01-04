#!/bin/sh

#  ci_post_clone.sh
#  StepCountApp
#
#  Created by gx_piggy on 1/3/24.
#  
echo "post clone script phase"

uname -m
system_profiler SPSoftwareDataType SPHardwareDataType

# 운영 체제 정보 출력
echo "==== Operating System ===="
echo "OS: $(uname -s)"
echo "Kernel Version: $(uname -r)"

# 사용 가능한 쉘 정보 출력
echo -e "\n==== Shell Information ===="
echo "Shell: $SHELL"
echo "Available Shells: $(cat /etc/shells)"

# 현재 사용자 정보 출력
echo -e "\n==== User Information ===="
echo "Logged-in User: $USER"
echo "Home Directory: $HOME"

echo "==== CPU Information ===="
echo "Processor: $(sysctl -n machdep.cpu.brand_string)"
echo "Number of Cores: $(sysctl -n hw.ncpu)"

# 메모리(RAM) 정보 출력
echo -e "\n==== Memory Information ===="
echo "Total Memory: $(sysctl -n hw.memsize | awk '{print $0/1024^3 " GB"}')"
echo "Available Memory: $(vm_stat | grep "Pages free:" | awk '{print $3*4096/1024^3 " GB"}')"

# 디스크 용량 정보 출력
echo -e "\n==== Disk Information ===="
df -h | grep '/dev/' | awk '{print "File System: " $1, "\nSize: " $2, "\nUsed: " $3, "\nAvailable: " $4, "\nUsage: " $5, "\nMount Point: " $6, "\n---"}'

# 네트워크 인터페이스 정보 출력
echo -e "\n==== Network Information ===="
ifconfig | grep -E '(en0|en1|eth0|eth1|wlan0|wlan1)' -A 5
