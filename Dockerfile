# vim: et sr sw=4 ts=4 smartindent syntax=dockerfile:
FROM alpine:3.7

LABEL \
      name="aries1980/git_secret" \
      vendor="sortuniq"            \
      description="tools to run git-secret"

COPY alpine_build_scripts/* /alpine_build_scripts/

RUN sh /alpine_build_scripts/install_git-secret.sh \
    && rm -rf /var/cache/apk/* /alpine_build_scripts 2>/dev/null

#ENTRYPOINT ["/bootstrap.sh"]

# built with additional labels:
#
# version
# opsgang.awscli_version
# opsgang.credstash_version
# opsgang.jq_version
# opsgang.terraform_version
#
# opsgang.build_git_uri
# opsgang.build_git_sha
# opsgang.build_git_branch
# opsgang.build_git_tag
# opsgang.built_by
#