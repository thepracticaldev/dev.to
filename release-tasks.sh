#!/bin/bash

STATEMENT_TIMEOUT=180000 bundle exec rails db:migrate && rails runner "puts 'app load success'; raise 'Deploy blocked' if ENV['DEPLOY_STATUS']=='blocked'"
