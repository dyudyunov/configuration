
Mongo-pruner
############

Role which add cron task for running the script to detect and prune old Structure
documents from the "Split" Modulestore MongoDB (edxapp.modulestore.structures by default).
See docstring/help for the "make_plan" and "prune" commands for more details.
https://github.com/edx/tubular/blob/master/tubular/scripts/structures.py


Configuration & Deployment
*************************
The mongopruner pipeline can be deployed together with the edxapp role, on
small deployments that use a single AppServer to host all services, or
standalone, which is the default for bigger installs.

You can also use ansible-playbook to test this role independently.
It requires you to pass more variables manually because they're not available
except when running inside "edxapp" role.

When running this role, you'll need to set:

* `COMMON_MONGOPRUNER_SERVICE_SETUP`: Set to true to configure the mongopruner service pipeline
* `MONGOPRUNER_SERVICE_ENABLE_CRON_JOB`: Set to true if you want to set up a daily cron job for the mongopruner service

To use a custom mongopruner pipeline, you'll need to configure the git remotes
and also the mongopruner pipeline "steps".

To set up the git repository, you can follow this template:

```
MONGOPRUNER_SERVICE_GIT_IDENTITY: !!null
MONGOPRUNER_SERVICE_GIT_REPOS:
  - PROTOCOL: "https"
    DOMAIN: "github.com"
    PATH: "edx"
    REPO: "tubular.git"
    VERSION: "master"
    DESTINATION: "{{ mongopruner_service_app_dir }}"
    SSH_KEY: "{{ MONGOPRUNER_SERVICE_GIT_IDENTITY }}"
```
