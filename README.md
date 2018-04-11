[1]: http://git-secret.io/ "git-secret"
[2]: https://github.com/opsgang/alpine_build_scripts/ "Opsgang's Alpine build scripts"
# docker\_git\_secret

_…Alpine Docker image to manage secrets with git-secret in a programmatical way_

From [git-secret.io] [1]

> For terraform >=0.10.0, this image also supports a plugins cache dir
> and is preinstalled with some popular ones to reduce download dependencies
> at run-time.

`git-secret` is a `bash` tool to store your private data inside a `git` repo. How’s
that? Basically, it just encrypts, using `gpg`, the tracked files with the public
keys of all the users that you trust. So everyone of them can decrypt these
files using only their personal secret key. Why deal with all this
private-public keys stuff? Well, to make it easier for everyone to manage access
rights. There are no passwords that change. When someone is out - just delete
their public key, reencrypt the files, and they won’t be able to decrypt secrets
anymore.

## featuring ...

* [git-secret] [1]

* [Opsgang's Alpine build scripts] [2]

* bash, git, gnupg, gawk

## docker tags

[![Run Status](https://api.shippable.com/projects/589913a86ee43c0f00b47cb6/badge?branch=master)](https://app.shippable.com/projects/589913a86ee43c0f00b47cb6)

## building

```bash
git clone https://github.com/aries1980/docker_git_secret.git
cd docker_git_secret
./build.sh # adds custom labels to image
```

## installing

```bash
docker pull aries1980/git_secret:stable # or use the tag you prefer
```
