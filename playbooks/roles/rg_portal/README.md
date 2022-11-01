# RG-portal (Richie)
### General info
[RG Portal](https://drive.google.com/file/d/1faJDRDuGTU4RI8Ac53m6OEZS4S6n6LZc/view?usp=sharing)
RG Portal (Richie) repository - https://gitlab.raccoongang.com/rg-developers/rg-portal
Site Factory - https://gitlab.raccoongang.com/owlox-team/rg-portal
Courses sync plugin repository - https://gitlab.raccoongang.com/rg-developers/rg-portal-openedx-sync

#### Richie is a Django application that uses 3 additional services:
- Postgres or MySQL (can be easily switched)
- Elasticsearch
- Redis

The project is fully dockerized and can also be deployed natively, see instructions [here](https://richie.education/docs/native-installation)

To enable syncing courses with Richie we also need to install additional plugin into the platform (see courses sync plugin link above), all other integration with edx platform is done through configuration and env variables.

#### Hosting and cookies
Richie should be hosted on the same root domain as LMS because Richie needs access to LMS session cookie and cross domain CSRF cookie, e.g. LMS hosted on lms.example.com => Richie hosted on portal.example.com and
```
EDXAPP_SESSION_COOKIE_DOMAIN='.example.com'
ENABLE_CROSS_DOMAIN_CSRF_COOKIE=True
CROSS_DOMAIN_CSRF_COOKIE_DOMAIN='.example.com'
CROSS_DOMAIN_CSRF_COOKIE_NAME='edx_csrf_token'
CORS_ORIGIN_WHITELIST=["portal.example.com"]
```
Env variables
Required env variables for Portal service

##### Django
```
DJANGO_SECRET_KEY=SET_ME_PLEASE
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,portal.example.com
````
##### Database
```
DB_ENGINE=django.db.backends.postgresql_psycopg2
DB_HOST=db
DB_NAME=richie
DB_USER=fun
DB_PASSWORD=pass
DB_PORT=5432
```

##### Connection with edx platform
```
AUTHENTICATION_BASE_URL=https://lms-rg-portal-box-dev.raccoongang.com
EDX_BASE_URL=https://lms-rg-portal-box-dev.raccoongang.com
EDX_BACKEND=richie.apps.courses.lms.edx.EdXLMSBackend
EDX_COURSE_REGEX=^.*/courses/(?P<course_id>.*)/info/?$
EDX_JS_BACKEND=openedx-hawthorn
EDX_JS_COURSE_REGEX=^.*/courses/(.*)/info/?$

DJANGO_RICHIE_COURSE_RUN_SYNC_SECRETS=SET_ME_PLEASE
```

##### Elasticsearch
```
RICHIE_ES_HOST=elasticsearch
```

##### Sentry
```
SENTRY_DSN=
```

##### Web analytics
```
WEB_ANALYTICS_ID=None
WEB_ANALYTICS_LOCATION=head
WEB_ANALYTICS_PROVIDER=google_analytics
```
##### Minimum enrollment count value that would be shown on course detail page
```
RICHIE_MINIMUM_COURSE_RUNS_ENROLLMENT_COUNT=1
```

### Example of deployment variables
```
EDXAPP_INSTALL_PRIVATE_REQUIREMENTS: True

EDXAPP_ENABLE_CROSS_DOMAIN_CSRF_COOKIE: True
EDXAPP_CROSS_DOMAIN_CSRF_COOKIE_DOMAIN: '.raccoongang.com'
EDXAPP_CROSS_DOMAIN_CSRF_COOKIE_NAME: 'edx_csrf_token'
EDXAPP_CORS_ORIGIN_WHITELIST:
  - "{{ EDXAPP_PORTAL_BASE_URL }}"

EDXAPP_PRIVATE_REQUIREMENTS:
  - name: 'git+git@gitlab.raccoongang.com:rg-developers/rg-portal-openedx-sync@2.0.1#egg=richie_openedx_sync'
    extra_args: '-e'

EDXAPP_LMS_ENV_EXTRA:
  RICHIE_OPENEDX_SYNC_COURSE_HOOKS:
    - url: "{{ EDXAPP_PORTAL_BASE_URL }}/api/v1.0/course-runs-sync/"
      secret: {{ RG_PORTAL_DJANGO_RICHIE_COURSE_RUN_SYNC_SECRETS }}

EDXAPP_CMS_ENV_EXTRA:
  RICHIE_OPENEDX_SYNC_COURSE_HOOKS:
    - url: "{{ EDXAPP_PORTAL_BASE_URL }}/api/v1.0/course-runs-sync/"
      secret: {{ RG_PORTAL_DJANGO_RICHIE_COURSE_RUN_SYNC_SECRETS }}

EDXAPP_PORTAL_BASE_URL: "https://{{ RG_PORTAL_PUBLIC_DNS }}"

RG_PORTAL_REGISTRY_PASSWORD: SET_ME_PLEASE
RG_PORTAL_PUBLIC_DNS: portal-rg-portal-box-dev.raccoongang.com
RG_PORTAL_DB_PASSWORD: SET_ME_PLEASE
RG_PORTAL_DJANGO_SECRET_KEY: SET_ME_PLEASE
RG_PORTAL_DJANGO_RICHIE_COURSE_RUN_SYNC_SECRETS: "SET_ME_PLEASE"
```

### Useful links from official docs
Native installation - [Installing Richie on your machine | Richie](https://richie.education/docs/native-installation)

Docker development - [Developing Richie with Docker | Richie](https://richie.education/docs/docker-development)

Syncing user info with edx - [Displaying OpenEdX connection status in Richie | Richie](https://richie.education/docs/displaying-connection-status)

Connecting LMS - [Configuring LMS Backends | Richie](https://richie.education/docs/lms-backends/)

Syncing course. run details - [Synchronizing course runs between Richie and OpenEdX | Richie](https://richie.education/docs/synchronizing-course-runs)  
