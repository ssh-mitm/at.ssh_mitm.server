
# [SSH-MITM Server](https://github.com/ssh-mitm/ssh-mitm)


**SSH-MITM is a man in the middle (mitm) server for security audits supporting public key authentication, session hijacking and file manipulation.**

## Installation SSH-MITM

The first step to using any software package is getting it properly installed.

To install SSH-MITM, simply run this simple command in your terminal of choice:

    $ flatpak install at.ssh_mitm.server

## Connect to the network

To start an intercepting mitm-ssh server on Port 10022, all you have to do is run a single command.

```bash
# start the mitm server
$ flatpak run at.ssh_mitm.server --remote-host 192.168.0.x

# connect to the mitm server
$ ssh -p 10022 user@proxyserver
```

## Hijack SSH sessions

When a client connects, the ssh-mitm starts a new server, which is used for session hijacking.

```
[INFO] created injector shell on port 34463
```

To hijack this session, you can use your favorite ssh client. All you have to do is to connect to the hijacked session.

```bash
$ ssh -p 34463 127.0.0.1 
```


## Updating to a new ssh-mitm release

1. Install the runtime referenced in `at.ssh_mitm.server.yml`:
   `flatpak install flathub org.freedesktop.Sdk//<version>`
2. `./update-dependencies.sh <new-version>` regenerates
   `python3-ssh-mitm.json` (pinned wheel URLs/hashes for x86_64 and
   aarch64) against the runtime's Python.
3. Add a `<release>` entry for the new version to
   `at.ssh_mitm.server.metainfo.xml`.
4. Bump `runtime-version` in `at.ssh_mitm.server.yml` if the pinned
   freedesktop runtime has gone stale (Flathub rejects EOL runtimes).
5. Open a PR against [flathub/at.ssh_mitm.server](https://github.com/flathub/at.ssh_mitm.server).

Every pip source has `x-checker-data`, so Flathub's hourly
[flatpak-external-data-checker](https://github.com/flathub-infra/flatpak-external-data-checker)
run opens a PR against [flathub/at.ssh_mitm.server](https://github.com/flathub/at.ssh_mitm.server)
automatically whenever ssh-mitm or one of its existing dependencies
gets a new release on PyPI - review and merge it instead of tracking
upstream releases by hand. It only bumps existing pins, though: if a
new ssh-mitm release adds a dependency that wasn't in the manifest
before, its PR for the `ssh_mitm` source itself is still the signal to
run `update-dependencies.sh` and pick up the new entry. paramiko is the
one exception: ssh-mitm pins it to an exact version because it relies
on paramiko's private internals, so its source has no `x-checker-data`
and must only ever move in lockstep with ssh-mitm's own paramiko pin.

## Contributing

Please contribute to [SSH-MITM server](https://github.com/ssh-mitm/ssh-mitm)

**Pull requests are welcome.** 

For major changes, please open an issue first to discuss what you would like to change.
