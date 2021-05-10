# Development

## fix.sh

If you want to use rbenv/pyenv/etc to manage versions of tools,
there's a `fix.sh` script which may be what you'd like to install
dependencies.

## Overcommit

This project uses [overcommit](https://github.com/sds/overcommit) for
quality checks.  `bundle exec overcommit --install` will install it.

## Publishing

To publish new version as a maintainer:

```sh
git log "v$(bump current)..."
# Set type_of_bump to patch, minor, or major
bump --tag --tag-prefix=v ${type_of_bump:?}
rake release
```
