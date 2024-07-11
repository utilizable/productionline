#!/bin/bash

# Wait until GitLab is ready to accept connections
until $(curl --output /dev/null --silent --head --fail http://anykey.pl/gitlab/-/readiness); do
  printf '.'
  sleep 5
done

gitlab-rails console <<-EOS
u = User.new(username: 'test_user', email: 'test@example.com', name: 'Test User', password: 'StrongPassword@', password_confirmation: 'StrongPassword@')
u.assign_personal_namespace(Organizations::Organization.default_organization)
u.skip_confirmation! # Use it only if you wish user to be automatically confirmed. If skipped, user receives confirmation e-mail
u.save!
EOS

gitlab-rails console <<-EOS
user = User.find_by_username('test_user')
token = user.personal_access_tokens.create(scopes: ['read_user', 'read_repository'], name: 'Automation token', expires_at: 365.days.from_now)
token.set_token('token-string-here123')
token.save!
EOS
