#! /bin/bash

DEBUG=no
LOG_FILE=/tmp/zabbix_http_status_check.out

if [ "${DEBUG}" = "yes" ]; then
  echo "=== ["`date`"] $0 $*" >> ${LOG_FILE}
fi
if [ -z "$1" ] ; then echo "Usage: $0 domainname.tld[/healthcheck_url] [override_uri]" >&2 ; exit 1; fi
if echo "$*" | grep -q "0.0.0.0" ; then echo `basename $0`": invalid arguments: $*" ; exit 1; fi
if [ ! -z "$2" ] ; then
  shift
fi
# get avg ping to host to substract from responce delay
HOST=$(echo $1 | sed -r 's/^(http|https)(:\/\/)(.*)$/\3/' | sed -r 's/^([^\/]+)\/.*$/\1/')
if [ ! -z ${HOST} ] ; then
  if [ "${DEBUG}" = "yes" ]; then
    echo "ping: ${HOST}" >> ${LOG_FILE}
  fi
  PING=$(ping -n -W 2 -q -c 3 ${HOST} 2> /dev/null | grep -a "^rtt" | cut -f 5 -d / | cut -f 1 -d .)
else
  PING=0
fi
# start timestamp to measure responce delay
TS1=`date +%s%3N`
if [ "${DEBUG}" = "yes" ]; then
  echo "curl: $*" >> ${LOG_FILE}
fi
RES=`( timeout -k 23 19 curl -i -L -Ss -q --insecure -A "Zabbix Web status check" $* 2>&1 ;
  RET=$? ;
  if test ${RET} -eq 124 ; then
    echo "HTTP/0.0 000 Zabbix check timeout" ;
  fi ) | grep -a -v "The TLS connection was non-properly terminated" | grep -a -e "^HTTP/.* " -e "curl:" | tail -n 1`

# end timestamp to measure responce delay
TS2=`date +%s%3N`
TS=`expr 0${TS2} - 0${TS1} - 0${PING}`

if echo ${RES} | grep -a -q 'curl:' ; then
  RES="HTTP/0.0 001 ${RES}"
fi

if echo ${RES} | grep -a -q 'curl:.* Connection refused' ; then
  RES="HTTP/0.0 002 ${RES}"
fi

if [ "${DEBUG}" = "yes" ]; then
  echo "res: $* ${RES} [${TS}] -- PING:${PING}" | sed -r 's/\s+/ /g' >> ${LOG_FILE}
fi

echo "${RES} [${TS}]" | sed -r 's/\s+/ /g'
