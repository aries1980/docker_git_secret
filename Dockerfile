# vim: et sr sw=4 ts=4 smartindent syntax=dockerfile:
FROM alpine:3.7

LABEL \
      org.label-schema.name="aries1980/git_secret" \
      org.label-schema.schema-version=1.0 \
      org.label-schema.description="Alpine-based image for git-secret" \
      org.label-schema.vendor="https://janosfeher.com"

COPY alpine_build_scripts/* /alpine_build_scripts/

RUN sh /alpine_build_scripts/install_git-secret.sh \
    && rm -rf /var/cache/apk/* /alpine_build_scripts 2>/dev/null

# built with additional labels:
#
# org.label-schema.schema-version
# org.label-schema.build-date
# org.label-schema.url
# org.label-schema.vcs-url
# misc.git_version
# misc.git_secret_sha
# misc.gnupg_version
# misc.build_git_uri
# misc.build_git_sha
# misc.build_git_branch
# misc.build_git_tag
# misc.built_by
