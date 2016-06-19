Command-line and gem client for Asana (unofficial)

[![Circle CI](https://circleci.com/gh/apiology/checkoff.svg?style=svg)](https://circleci.com/gh/apiology/checkoff)
[![Travis CI](https://travis-ci.org/apiology/checkoff.svg?branch=master)](https://travis-ci.org/apiology/checkoff)

## Using

```
$ checkoff --help
View tasks:
  checkoff view workspace project [section]

'project' can be set to a project name, or :my_tasks, :my_tasks_upcoming, :my_tasks_new, or :my_tasks_today
```

Let's say we have a project like this:

![project screenshot from asana.com](https://github.com/apiology/checkoff/raw/master/docs/example_project.png "Example project")

Checkoff outputs things in JSON.  'jq' is a great tool to use in combination:

```
$ checkoff view 'Personal Projects' 'Create demo'
{"":[{"name":"This is a task that doesn't belong to any sections."}],"Write it:":[{"name":"Write something"}],"Publish to github:":[{"name":"git push!"}],"Make sure it looks OK!:":[{"name":"Looks it up in your browser..."}]}
$
```

```json
$ checkoff view 'Personal Projects' 'Create demo' | jq
{
  "": [
    {
      "name": "This is a task that doesn't belong to any sections."
    }
  ],
  "Write it:": [
    {
      "name": "Write something"
    }
  ],
  "Publish to github:": [
    {
      "name": "git push!"
    }
  ],
  "Make sure it looks OK!:": [
    {
      "name": "Looks it up in your browser..."
    }
  ]
}
```

You can drill down into a section on the command line:

```
$ checkoff view 'Personal Projects' 'Create demo' 'Publish to github:'
[{"name":"git push!"}]
```

You can use fun `jq` tricks:

```json
$ checkoff view 'Personal Projects' 'Create demo' | jq 'to_entries | map(.value) | flatten | map(.name)'
[
  "This is a task that doesn't belong to any sections.",
  "Write something",
  "git push!",
  "Looks it up in your browser..."
]
```

And even gather counts for project metrics:

```bash
$ checkoff view 'Personal Projects' 'Create demo' | jq 'to_entries | map(.value) | flatten | map(.name) | length'
4
$ 
```

## Caching

Note that I don't know of a way through the Asana API to target
individual sections and pull back only those tasks, which is a real
bummer!  As a result, sometimes the number of tasks brought back to
answer a query is really large and takes a while--especially if you're
querying on something like `:my_tasks_today`.  To help make that less
annoying, I do caching using memcached; you'll need to install it.

If you're working in real time with modifications in Asana, you may
need to occasionally run `echo 'flush_all' | nc localhost 11211` to
clear the cache.

## Installing

This will work under OS X:

```bash
brew install memcached
ln -sfv /usr/local/opt/memcached/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.memcached.plist
gem install checkoff
```

## Configuring

You'll need to create a file called `.asana.yml` in your home directory, that looks like this:

```yaml
---

#
# when you click on 'My Tasks' in Asana, put the number (just the
# number) from the URL in the mapping below.
#
my_tasks:
  'Your workspace name here': 'some_long_number'

#

# Click on your profile in the uppper right in Asana, go to 'My
# Profile Settings', click on 'Apps', got o 'Manage Developer Apps',
# and select 'Create New Personal Access Token'.  Note down the key
# in this section.
#
personal_access_token: 'some_big_long_string_from_asana.com_here'
```

## Developing

```bash
bundle install
bundle exec exe/checkoff --help
```
