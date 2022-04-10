#! /bin/sh

DEBUG=no # set to "yes" to debug

if [ -z "$1" -o -z "$2" ]; then echo "Usage: $0 domainname.tld zabbix_host_name [nginx_basic_status_url]" >&2 ; exit 1; fi
if [ ! -z "$3" ] ; then
  NGINX_STATUS_URL="$3"
else
  NGINX_STATUS_URL="http://$1/nginx_basic_status"
fi

OUT=" "`timeout 8 curl -L -A "Zabbix nginx status check" "${NGINX_STATUS_URL}" 2> /dev/null | head -n 6`" "

if [ x${DEBUG} = xyes ]; then
	echo "=== $0 $*: ${OUT}" >> /tmp/zabbix_http_nginx_status.out
fi

if echo ${OUT} | grep -q "Active connections" ; then : ; else echo 0 ; exit ; fi

ACT_CONN=`echo ${OUT} | sed 's/^.*Active connections: \([0-9][0-9]*\) .*$/\1/'`
ACCEPTS=`echo ${OUT} | sed 's/^.*accepts handled requests \([0-9][0-9]*\) \([0-9][0-9]*\) \([0-9][0-9]*\).*$/\1/'`
HANDLED=`echo ${OUT} | sed 's/^.*accepts handled requests \([0-9][0-9]*\) \([0-9][0-9]*\) \([0-9][0-9]*\).*$/\2/'`
REQUESTS=`echo ${OUT} | sed 's/^.*accepts handled requests \([0-9][0-9]*\) \([0-9][0-9]*\) \([0-9][0-9]*\).*$/\3/'`
WAITING=`echo ${OUT} | sed 's/^.*Waiting: \([0-9][0-9]*\).*$/\1/'`

if test x${DEBUG} = xyes ; then # debug: true or false

cat << EOF >> /tmp/zabbix_http_nginx_status.out
===${OUT}===
ACT_CONN = $ACT_CONN
ACCEPTS = $ACCEPTS
HANDLED = $HANDLED
REQUESTS = $REQUESTS
WAITING = $WAITING
EOF

fi

echo "connections: ${ACT_CONN}"
echo "accepts: ${ACCEPTS}"
echo "handled: ${HANDLED}"
echo "requests: ${REQUESTS}"
echo "waiting: ${WAITING}"
