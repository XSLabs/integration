#!/bin/sh

# Check for Googlers not configuring their email address.
# There are many examples of this in the git logs.
AUTHORINFO="$(git var GIT_AUTHOR_IDENT)" || exit 1
EMAIL="$(printf %s "${AUTHORINFO}" | sed -n 's/^.* <\(.*\)> .*$/\1/p')"

case "${EMAIL}" in
  *.corp.google.com)
    echo "Git is inferring your email to be ${EMAIL}. Please run:"
    echo " git config --global user.email ${USER}@google.com"
    exit 1
    ;;
esac

