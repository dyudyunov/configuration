#!/bin/bash

REDIS_CLI="/usr/bin/redis-cli"
CONFIG_FILE="/etc/zabbix/scripts/scripts.cfg"
HOST=$(sed -nr "/^\[redis\]/ { :l /host[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $CONFIG_FILE)
PORT=$(sed -nr "/^\[redis\]/ { :l /port[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $CONFIG_FILE)
PASSWORD=$(sed -nr "/^\[redis\]/ { :l /password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $CONFIG_FILE)

# LLD queues list
if [ "$1" = "lld_queues" ]; then
  FIRST="yes"
  echo '{'
  echo '  "data": ['
  for q in `$REDIS_CLI -h $HOST -p $PORT -a "$PASSWORD" -n 0 keys \* 2>/dev/null | grep _kombu | sed 's/_kombu.binding.//g' | sort`; do
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
  LIST_QUEUES=$($REDIS_CLI -h $HOST -p $PORT -a "$PASSWORD" keys \* 2>/dev/null | grep _kombu | sed 's/_kombu.binding.//g')
  for i in $LIST_QUEUES; do
    MESSAGES_IN_QUEUE=$($REDIS_CLI -h $HOST -p $PORT -a "$PASSWORD" LLEN $i 2>/dev/null)
    MESSAGES_COUNT=$(expr $MESSAGES_COUNT + $MESSAGES_IN_QUEUE)
  done
  echo $MESSAGES_COUNT
  exit
fi

if [ "$1" = "stat" ]; then
  LIST_QUEUES=$($REDIS_CLI -h $HOST -p $PORT -a "$PASSWORD" keys \* 2>/dev/null | grep _kombu | sed 's/_kombu.binding.//g')
  for i in $LIST_QUEUES; do
  echo "$i" `$REDIS_CLI -h $HOST -p $PORT -a "$PASSWORD" LLEN $i 2>/dev/null`
  done
  exit
fi

$REDIS_CLI -h $HOST -p $PORT -a "$PASSWORD" $* 2>/dev/null
