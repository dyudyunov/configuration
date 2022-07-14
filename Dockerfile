FROM python:3.8

RUN pip install ansible \
    datadog \
    PyYAML \
    zabbix-api \
    mysqlclient \
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
    ANSIBLE_INVENTORY=/home/ansible/inventory/hosts.yml,./hosts.yml

ENTRYPOINT ["./bootstrap.sh"]
