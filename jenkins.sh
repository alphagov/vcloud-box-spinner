#!/bin/bash -x
set -e
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake spec
bundle exec rake publish_gem --trace
