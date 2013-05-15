#!/bin/sh

exitcode=0
RAILS_ENV=ci rake db:migrate
rake ci || exitcode=1
exit $exitcode
