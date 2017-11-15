# Microservice API Gateway

Based on Openresty. Many business logic are implemented by lua.

## Features

### auto-cache
TODO

#### Test:

With auto-cache

```shell
ab -n 10000 -c 1000 -k http://localhost:7777/cache-test/mockBackend
```

Without auto-cache

```shell
ab -n 10000 -c 1000 -k http://localhost:7778/cache-test/mockBackend
```

### api-sign-check
TODO

