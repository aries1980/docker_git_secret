#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# helper script to generate label data for docker image during building
#
# docker_build will generate an image tagged :candidate
#
# It is a post-step to tag that appropriately and push to repo

MIN_DOCKER=1.11.0
GIT_SHA_LEN=8
IMG_TAG=candidate

version_gt() {
    [[ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" ]]
}

valid_docker_version() {
    v=$(docker --version | grep -Po '\b\d+\.\d+\.\d+\b')
    if version_gt $MIN_DOCKER $v
    then
        echo "ERROR: need min docker version $MIN_DOCKER" >&2
        return 1
    fi
}

_pypi_pkg_version() {
    local pkg="$1"
    local uri="https://pypi.python.org/pypi/$pkg/json"
    curl -s --retry 5                \
        --retry-max-time 20 $uri     \
    | jq -r '.releases | keys | .[]' \
        2>/dev/null                  \
    | sort --version-sort            \
    | tail -1 || return 1
}

alpine_img(){
    grep -Po '(?<=^FROM ).*' Dockerfile
}

init_apk_versions() {
    local img="$1"
    docker pull $img >/dev/null 2>&1 || return 1
}

apk_pkg_version() {
    local img="$1"
    local pkg="$2"

    docker run -i --rm $img apk --no-cache --update info $pkg \
    | grep -Po "(?<=^$pkg-)[^ ]+(?= description:)" | head -n 1
}

fetch_alpine_build_scripts() {
    if [[ -d alpine_build_scripts ]]; then
        cd alpine_build_scripts && git pull && cd ..
    else
        git clone --depth 1 https://github.com/opsgang/alpine_build_scripts
    fi
}

built_by() {
    local user="--UNKNOWN--"
    if [[ ! -z "${BUILD_URL}" ]]; then
        user="${BUILD_URL}"
    elif [[ ! -z "${AWS_PROFILE}" ]] || [[ ! -z "${AWS_ACCESS_KEY_ID}" ]]; then
        user="$(aws iam get-user --query 'User.UserName' --output text)@$HOSTNAME"
    else
        user="$(git config --get user.name)@$HOSTNAME"
    fi
    echo "$user"
}

git_uri(){
    git config remote.origin.url || echo 'no-remote'
}

git_sha(){
    git rev-parse --short=${GIT_SHA_LEN} --verify HEAD
}

git_branch(){
    r=$(git rev-parse --abbrev-ref HEAD)
    [[ -z "$r" ]] && echo "ERROR: no rev to parse when finding branch? " >&2 && return 1
    [[ "$r" == "HEAD" ]] && r="from-a-tag"
    echo "$r"
}

img_name(){
    (
        set -o pipefail;
        grep -Po '(?<=[nN]ame=")[^"]+' Dockerfile | head -n 1
    )
}

git_secret_version() {
    curl -s https://api.github.com/repos/sobolevn/git-secret/commits | jq -r ".[0] | .sha" || return 1
}

labels() {
    local ai av cv jv tv bb gu gs gb gt
    ai=$(alpine_img) || return 1
    init_apk_versions $ai || return 1

    gv=$(apk_pkg_version $ai 'git') || return 1
    gpgv=$(apk_pkg_version $ai 'gnupg') || return 1
    gsv=$(git_secret_version) || return 1
    bb=$(built_by) || return 1
    gu=$(git_uri) || return 1
    gs=$(git_sha) || return 1
    gb=$(git_branch) || return 1
    gt=$(git describe 2>/dev/null || echo "no-git-tag")
    n=$(img_name) || return 1

    cat<<EOM
    --label org.label-schema.version=dirty
    --label org.label-schema.build-date=$(date +'%Y%m%d%H%M%S')
    --label org.label-schema.name=$n
    --label org.label-schema.url=https://github.com/aries1980/docker_git_secret
    --label org.label-schema.vcs-url=$gu
    --label misc.git_version=$gv
    --label misc.git_secret_sha=$gsv
    --label misc.gnupg_version=$gpgv
    --label misc.build_git_sha=$gs
    --label misc.build_git_branch=$gb
    --label misc.build_git_tag=$gt
    --label misc.built_by="$bb"
EOM
}

docker_build(){

    valid_docker_version || return 1

    labels=$(labels) || return 1
    n=$(img_name) || return 1

    echo "INFO: adding these labels:"
    echo "$labels"
    echo "INFO: building $n:$IMG_TAG"
set -x
    docker build --no-cache=true --force-rm $labels -t $n:$IMG_TAG .
}

docker_build
