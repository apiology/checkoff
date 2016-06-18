Command-line and gem client for Asana (unofficial)

[![Circle CI](https://circleci.com/gh/apiology/checkoff.svg?style=svg)](https://circleci.com/gh/apiology/checkoff)
[![Travis CI](https://travis-ci.org/apiology/checkoff.svg?branch=master)](https://travis-ci.org/apiology/checkoff)

## Caching

Note that I don't know of a way through the Asana API to target
individual sections and pull back only those tasks, which is a real
bummer!  As a result, sometimes the number of tasks brought back to
answer a query is really large and takes a while.  To help make that
less annoying, I do caching using memcached; you'll need to install
it.

## Installing

```bash
brew install memcached
gem install checkoff

```

## Using

```bash
$ checkoff --help
View tasks:
  exe/checkoff view workspace project [section]

'project' can be set to a project name, or :my_tasks, :my_tasks_upcoming, :my_tasks_new, or :my_tasks_today
```

## Developing

```bash
bundle install
bundle exec exe/checkoff --help
```
