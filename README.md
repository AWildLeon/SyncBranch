# SyncBranch

A Docker-based tool for automatically syncing changes from one Git repository branch to another repository branch at regular intervals.

## Overview

SyncBranch monitors a source repository and branch, then automatically pushes changes to a target repository and branch. This is useful for:

- Mirroring public repositories to private ones (This is my Usecase)
- Syncing upstream changes to forks
- Automated branch synchronization between different Git hosting services

## Quick Start

1. Clone this repository
2. Set up your SSH key and configuration
3. Configure the environment variables
4. Run with Docker Compose

## Setup

### 1. SSH Configuration

Place your SSH private key in the `ssh/` directory:

```bash
# Copy your SSH private key
cp ~/.ssh/id_rsa ssh/ssh_key
cp ~/.ssh/id_rsa.pub ssh/ssh_key.pub

# Ensure proper permissions
chmod 600 ssh/ssh_key
chmod 644 ssh/ssh_key.pub
```

The SSH configuration is automatically set up with these defaults:
- `UserKnownHostsFile /ssh/known_hosts`
- `IdentityFile /ssh/ssh_key`
- `User git`  
- `StrictHostKeyChecking accept-new`

### 2. Environment Configuration

Configure the environment variables in `compose.yml`:

| Variable | Description | Example |
|----------|-------------|---------|
| `Every` | Sync interval | `5m`, `1h`, `30s` |
| `PUID` | User ID for file permissions | `1000` |
| `FROM_BRANCH` | Source branch to sync from | `main` |
| `TO_BRANCH` | Target branch to sync to | `upstream` |
| `FROM_REPO` | Source repository URL | `https://github.com/user/repo.git` |
| `TO_REPO` | Target repository URL | `git@github.com:user/other-repo.git` |

### 3. Repository Structure

The container uses these mounted directories:
- `./repo:/repo` - Git repository workspace
- `./ssh:/ssh` - SSH keys and configuration

## Usage

### Using Docker Compose

```bash
# Build and start the service
docker compose up --build -d

# View logs
docker compose logs -f syncbranch

# Stop the service
docker compose down
```

### Using Pre-built Image

You can also use the pre-built image from GitHub Container Registry: ``ghcr.io/AWildLeon/SyncBranch:latest``
for more details read [compose.yml](compose.yml)

## How It Works

1. **Initialization**: Creates a user with the specified PUID and sets up SSH configuration
2. **Repository Setup**: Clones or fetches from the source repository
3. **Branch Management**: Creates or switches to the target branch
4. **Synchronization**: Resets the target branch to match the source branch exactly
5. **Push**: Force pushes changes to the target repository
6. **Loop**: Waits for the specified interval and repeats

## Security Considerations

- SSH keys are mounted as volumes and have proper permissions set automatically
- The container runs as a non-root user with configurable UID
- Host key verification is handled automatically with `accept-new` policy
- All Git operations use SSH for authentication to the target repository

## Troubleshooting

### Common Issues

**SSH Authentication Failed**
- Ensure your SSH key has access to the target repository
- Verify the SSH key is in the correct location (`ssh/ssh_key`)
- Check that the target repository URL uses SSH format (`git@github.com:...`)

**Permission Denied**
- Make sure `PUID` matches your user ID (`id -u`)
- Verify SSH key permissions are correct (600 for private key)

**Repository Not Found**
- Check that both repositories exist and are accessible
- Verify repository URLs are correct
- Ensure the source repository is publicly accessible or you have access

### Logs

View detailed logs to troubleshoot issues:

```bash
docker compose logs -f syncbranch
```

The logs include timestamps and detailed information about each sync operation.

## Development

### Local Development

For development, you can use the local build:

```bash
docker compose -f compose.dev.yml up --build
```

## License

See [LICENSE](LICENSE) file for details.
