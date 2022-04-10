#!/bin/sh

if test -z "${1}" ; then
  echo "Usage: $0 [lld_queues|messages|stat|<redis-cli command>]"
  exit 1
fi

HOST="localhost"
PORT="6379"
PASSWORD="_"
DB="0"

CONFIG_FILE="/etc/zabbix/scripts/scripts.cfg"
if test -f ${CONFIG_FILE} ; then
  _HOST=`sed -nr "/^\[redis\]/ { :l /host[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $CONFIG_FILE`
  if test -n "${_HOST}" ; then
    HOST="${_HOST}"
  fi
  _PORT=`sed -nr "/^\[redis\]/ { :l /port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $CONFIG_FILE`
  if test -n "${_PORT}" ; then
    PORT="${_PORT}"
  fi
  _PASSWORD=`sed -nr "/^\[redis\]/ { :l /password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $CONFIG_FILE`
  if test -n "${_PASSWORD}" ; then
    PASSWORD="${_PASSWORD}"
  fi
  _DB=`sed -nr "/^\[redis\]/ { :l /database[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $CONFIG_FILE`
  if test -n "${_DB}" ; then
    DB="${_DB}"
  fi
fi

REDIS_CLI="redis-cli -h $HOST -p $PORT -a $PASSWORD -n $DB"
DJANGO_CELERY_DELIMITER=`/usr/bin/printf '\x16'`

for q in `$REDIS_CLI KEYS \* 2>/dev/null`; do
  t=`$REDIS_CLI TYPE ${q} 2>/dev/null`
  if test x${t} = xlist ; then
    QUEUES="${QUEUES} ${q}"
  else
    if test x${t} = xset ; then
      QUEUES="${QUEUES} "`$REDIS_CLI SMEMBERS ${q} 2>/dev/null | cut -f 2 -d '"' | cut -f 3 -d ${DJANGO_CELERY_DELIMITER}`
    fi
  fi
done

QUEUES=`echo ${QUEUES} | sed 's/ /\n/g' | sort | uniq | grep -v -e celery.pidbox -e ^celeryev`

# LLD queues list
if [ "$1" = "lld_queues" ]; then
  FIRST="yes"
  echo '{'
  echo '  "data": ['
  for q in ${QUEUES}; do
      if [ "${FIRST}" = "yes" ]; then
          FIRST="no"
      else
          echo ','
      fi
      echo '    {'
      echo '      "{#QUEUE_NAME}": "'${q}'"'
      echo -n '    }'
  done
  echo ''
  echo '  ]'
  echo '}'

  exit
fi

# Count total messages in queues
if [ "$1" = "messages" ]; then
  for i in $QUEUES; do
    MESSAGES_IN_QUEUE=$($REDIS_CLI LLEN $i 2>/dev/null)
    MESSAGES_COUNT=$(expr $MESSAGES_COUNT + $MESSAGES_IN_QUEUE)
  done
  echo $MESSAGES_COUNT
  exit
fi

if [ "$1" = "stat" ]; then
  for i in $QUEUES; do
    echo "$i" `$REDIS_CLI LLEN $i 2>/dev/null`
  done
  exit
fi

$REDIS_CLI $* 2>/dev/null
