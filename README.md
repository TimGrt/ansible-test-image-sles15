# Ansible Test Image - SLES 15

SystemD-enabled container image, based on BCI-Init, for testing Ansible content. By default, the image uses the latest Service Pack 7.

A user `ansible` is created with password-less sudo configured. A couple of default packages are installed, but not all packages as in a *normal* Suse Enterprise Linux installation. Add additional packages in a `prepare.yml` during Molecule *create* stage.

The image is available in the Github container registry with Service Pack 7 (`main`) and Service Pack 6:

```bash
podman pull ghcr.io/timgrt/ansible-test-image-sles15:main
```

```bash
podman pull ghcr.io/timgrt/ansible-test-image-sles15:sp6
```

[![Container Build and Publish](https://github.com/TimGrt/ansible-test-image-sles15/actions/workflows/cd.yml/badge.svg)](https://github.com/TimGrt/ansible-test-image-sles15/actions/workflows/cd.yml)
[![prek](https://raw.githubusercontent.com/j178/prek/master/docs/assets/badge.svg)](https://github.com/j178/prek)

## How to Build

If you need to build the image on your own locally, do the following:

  1. [Install Podman](https://podman.io/docs/installation).
  2. Clone the repository and `cd` into this directory.
  3. Run `podman build -t ansible-test-sles15:sp7 .`

### Build image with different service pack

To build the image with by providing the `SLES_SERVICE_PACK` *build argument*:

```bash
podman build --build-arg SLES_SERVICE_PACK=6 -t ansible-test-sles15:sp6 .
```

## How to Use with Molecule

  1. [Install Podman](https://podman.io/docs/installation).
  2. [Install Molecule](https://ansible.readthedocs.io/projects/molecule/installation/).
  3. Install Ansible Collection dependencies: `ansible-galaxy collection install containers.podman`.
  4. Add Image in `molecule.yml`.

For example:

```yaml
---
driver:
  name: podman
platforms:
  - name: sles15sp7-molecule-test
    image: ghcr.io/timgrt/ansible-test-image-sles15:main
    groups:
      - molecule
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    command: "/usr/sbin/init"
    pre_build_image: true
    exposed_ports:
      - 80/tcp
    published_ports:
      - 8080:80/tcp
provisioner:
  name: ansible
  config_options:
    defaults:
      interpreter_python: auto_silent
      callbacks_enabled: profile_tasks, timer
      callback_result_format: yaml
      remote_user: ansible
      roles_path: "$MOLECULE_PROJECT_DIRECTORY/.."
    ssh_connection:
      pipelining: false
scenario:
  create_sequence:
    - create
  converge_sequence:
    - create
    - converge
  destroy_sequence:
    - destroy
  test_sequence:
    - destroy
    - create
    - syntax
    - converge
    - idempotence
    - destroy

```

The example above uses Callback plugins from `ansible.posix`.
