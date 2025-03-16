# Users and apps used for the testing framework

## User

Login: 'psmodule-user'
Owner of:
- [psmodule-user](https://github.com/psmodule-user) (standalone org)
- [psmodule-test-org2](https://github.com/orgs/psmodule-test-org2) (standalone org)

Secrets:
- TEST_USER_PAT -> 'psmodule-user' (user)
- TEST_USER_USER_FG_PAT -> 'psmodule-user' (user)
- TEST_USER_ORG_FG_PAT -> 'psmodule-test-org2' (org)

## APP_ENT - PSModule Enterprise App

Homed in 'MSX'
ClientID: 'Iv23lieHcDQDwVV3alK1'
Installed on:
- [psmodule-test-org3](https://github.com/orgs/psmodule-test-org3) (enterprise org)
Permissions:
- All
Events:
- Push

Secrets:
- TEST_APP_ENT_CLIENT_ID
- TEST_APP_ENT_PRIVATE_KEY

## APP_ORG - PSModule Organization App

Homed in PSModule
ClientID: 'Iv23liYDnEbKlS9IVzHf'
Installed on:
- [psmodule-test-org](https://github.com/orgs/psmodule-test-org) (standalone org)
Permissions:
- All
Events:
- Push

Secrets:
- TEST_APP_ORG_CLIENT_ID
- TEST_APP_ORG_PRIVATE_KEY
