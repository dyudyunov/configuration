FROM python:3.9

RUN pip install ansible==7.6.0 \
    datadog \
    PyYAML \
    zabbix-api \
    mysqlclient \
    mitogen \
    hvac==1.1.1 \
    && rm -rf ~/.cache

RUN adduser --system --home /home/ansible --disabled-password  --group ansible

USER ansible
WORKDIR /home/ansible

RUN mkdir .ssh

COPY --chown=ansible bootstrap.sh .

COPY --chown=ansible inventory /home/ansible/inventory
COPY --chown=ansible playbooks /home/ansible/playbooks

ENV ANSIBLE_ROLES_PATH=/home/ansible/playbooks/roles \
    ANSIBLE_CONFIG=/home/ansible/playbooks/ansible.cfg \
    ANSIBLE_VAULT_PASSWORD_FILE=/home/ansible/vault_password \
    ANSIBLE_RETRY_FILES_SAVE_PATH=/tmp \
    ANSIBLE_LIBRARY=/home/ansible/playbooks/library \
    ANSIBLE_INVENTORY=/home/ansible/inventory/hosts.yml,./hosts.yml \
    ANSIBLE_STRATEGY_PLUGINS=/usr/local/lib/python3.8/site-packages/ansible_mitogen/plugins/strategy

ENTRYPOINT ["./bootstrap.sh"]
