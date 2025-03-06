# ComposeCtl

Unified Control for Docker Compose &amp; Podman A collection of Docker Compose configurations and Podman systemd services for seamless container management. Automate deployments, manage stacks, and transition effortlessly between Docker and Podman with tool `ComposeCtl`.

`ComposeCtl` is a command-line tool for managing Docker Compose services with ease. It provides an interface to start, stop, restart, view logs, and apply changes to services defined in Docker Compose files.

## Features

- Start, stop, restart, and check the status of services
- Apply configuration changes
- View logs of specific services
- Supports dry-run mode for previewing commands
- Customizable configuration and compose file directories

## Requirements

- Python 3.6+
- Docker & Docker Compose installed

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/pankajackson/composectl.git
   cd composectl
   ```

2. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

## Usage

```bash
python composectl <action> [services] [options]
```

### Actions

- `up` - Start specified services
- `down` - Stop and remove services
- `restart` - Restart services
- `status` - Show running services
- `ls` - List all available services
- `logs` - Show logs of services
- `stop` - Stop services
- `apply` - Apply configuration changes

### Options

- `--dry-run` : Only show commands without executing them
- `-c, --config-file <path>` : Specify a custom config file (default: `~/.config/composectl.yaml`)
- `-d, --compose-dir <path>` : Specify a directory containing compose files

### Examples

Start services:

```bash
python composectl up service1 service2
```

Stop all services:

```bash
python composectl down
```

Restart a specific service:

```bash
python composectl restart service1
```

Show logs of a service:

```bash
python composectl logs service1
```

Perform a dry run to see commands without execution:

```bash
python composectl up service1 --dry-run
```

## License

This project is licensed under the MIT License.

## Contributors

- [Pankaj Kumar Patel](https://github.com/pankajackson)

## Contact

For any questions or issues, please open an issue on this repository.
