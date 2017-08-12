INCDIR = /home/fml/onm/src/bin
PP = /usr/bin/pp
CP = /bin/cp -p
DIR_BASE = /home/fml/onm
DIR_LIB = /home/fml/onm/src/bin/libexec
DIR_BBIN = /opt/crawler/bbin/libexec
DIR_BUILD = /home/fml/onm/rpm-build/BUILD
DIR_FINAL1=/opt/crawler/bin/libexec

all : mon_dns.o mon_icmp.o mon_tcp.o mon_snmp.o mon_http.o walk_mib.o  \
		mon_ssh.o mon_smtp.o mon_pop3.o mon_imap.o mibt.o get_iid.o \
		chk_metric.o chk_notif_modem.o chk_notif_sms.o mon_smb.o mon_ntp.o
 
mon_dns.o : ${DIR_LIB}/mon_dns
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_dns ${DIR_LIB}/mon_dns

mon_icmp.o : ${DIR_LIB}/mon_icmp
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_icmp ${DIR_LIB}/mon_icmp

mon_tcp.o : ${DIR_LIB}/mon_tcp
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_tcp ${DIR_LIB}/mon_tcp

mon_snmp.o : ${DIR_LIB}/mon_snmp
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_snmp ${DIR_LIB}/mon_snmp

mon_http.o : ${DIR_LIB}/mon_http
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_http ${DIR_LIB}/mon_http

walk_mib.o : ${DIR_LIB}/walk_mib
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/walk_mib ${DIR_LIB}/walk_mib

mon_ssh.o : ${DIR_LIB}/mon_ssh
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_ssh ${DIR_LIB}/mon_ssh

mon_smtp.o : ${DIR_LIB}/mon_smtp
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_smtp ${DIR_LIB}/mon_smtp

mon_pop3.o : ${DIR_LIB}/mon_pop3
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_pop3 ${DIR_LIB}/mon_pop3

mon_imap.o : ${DIR_LIB}/mon_imap
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_imap ${DIR_LIB}/mon_imap

mibt.o : ${DIR_LIB}/mibt
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mibt ${DIR_LIB}/mibt

get_iid.o : ${DIR_LIB}/get_iid
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/get_iid ${DIR_LIB}/get_iid

chk_metric.o : ${DIR_LIB}/chk_metric
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/chk_metric ${DIR_LIB}/chk_metric

chk_notif_modem.o : ${DIR_LIB}/chk_notif_modem
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/chk_notif_modem ${DIR_LIB}/chk_notif_modem

chk_notif_sms.o : ${DIR_LIB}/chk_notif_sms
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/chk_notif_sms ${DIR_LIB}/chk_notif_sms

mon_smb.o : ${DIR_LIB}/mon_smb
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_smb ${DIR_LIB}/mon_smb

mon_ntp.o : ${DIR_LIB}/mon_ntp
			${PP} -f Bleach -I ${INCDIR} -o ${DIR_BASE}/o/libexec/mon_ntp ${DIR_LIB}/mon_ntp


install:
	${CP} ${DIR_BASE}/o/libexec/mon_dns ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_icmp ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_tcp ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_snmp ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_http ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/walk_mib ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_ssh ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_smtp ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_pop3 ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_imap ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mibt ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/get_iid ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/chk_metric ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/chk_notif_modem ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/chk_notif_sms ${DIR_BBIN)
	${CP} ${DIR_BASE}/o/libexec/mon_smb ${DIR_BBIN}
	${CP} ${DIR_BASE}/o/libexec/mon_ntp ${DIR_BBIN}

install-rpm:
	${CP} ${DIR_BASE}/o/libexec/mon_dns ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_icmp ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_tcp ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_snmp ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_http ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/walk_mib ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_ssh ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_smtp ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_pop3 ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_imap ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mibt ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/get_iid ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/chk_metric ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/chk_notif_modem ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/chk_notif_sms ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_smb ${DIR_BUILD}${DIR_FINAL1}
	${CP} ${DIR_BASE}/o/libexec/mon_ntp ${DIR_BUILD}${DIR_FINAL1}


