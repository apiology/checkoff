# Development

## fix.sh

If you want to use rbenv/pyenv/etc to manage versions of tools,
there's a `fix.sh` script which may be what you'd like to install
dependencies.

## Overcommit

This project uses [overcommit](https://github.com/sds/overcommit) for
quality checks.  `bundle exec overcommit --install` will install it.

## direnv

This project uses direnv to manage environment variables used during
development.  See the `.envrc` file for detail.

## cache_method

Checkoff uses the
[`cache_method`](https://github.com/seamusabshere/cache_method) gem to
cache results between invocations.  Configuration details can be found
[here](https://github.com/seamusabshere/cache_method#configuration-and-supported-cache-clients).
By default a memcached client on the default port (11211) on the host
`memcached` will be used.

You can run memcached locally on macOS with Homebrew by running:

```sh
brew install memcached
brew services start memcached
```

You may want to add a `memcached` alias for `127.0.0.1` in `/etc/hosts`.

Please make sure this is only listening on loopback for security, of course.


## gli

Checkoff uses [`gli`](https://github.com/davetron5000/gli) on the CLI.
To get a full stack trace when encountering a problem, run as follows:

```sh
GLI_DEBUG=true checkoff your-arguments-here
```

## Publishing

To publish new version as a maintainer:

```sh
git checkout main && git pull
git log "v$(bump current)..."
# Set type_of_bump to patch, minor, or major
bump --tag --tag-prefix=v ${type_of_bump:?}
rake release
git push --no-verify
git push --tags
```


## Developing

```sh
bundle install
bundle exec exe/checkoff --help
```
