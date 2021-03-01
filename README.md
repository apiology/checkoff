# Checkoff

WARNING: This is not ready for use yet!

Command-line and gem client for Asana (unofficial)

To publish new version as a maintainer:

```sh
git log "v$(bump current)..."
# Set type_of_bump to patch, minor, or major
bump --tag --tag-prefix=v ${type_of_bump:?}
rake release
```
