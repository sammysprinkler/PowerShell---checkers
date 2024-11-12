
# PowerShell PC Checks 🖥️

PowerShell PC Checks is a toolkit for monitoring and securing Windows systems. This project provides scripts and modules to monitor network connections, processes, system logs, and file integrity, all customizable for different security needs. This is a work-in-progress (WIP) and will be regularly updated with new features.

## 🚀 Project Overview
This project includes PowerShell scripts that:

- Monitor network connections and processes for suspicious activity
- Inspect system logs for signs of unauthorized access or errors
- Verify file integrity to detect unauthorized modifications

Each component is modular, making it easy to adapt or extend the scripts for specific environments.

## 📜 Features
- **Network Monitoring**: Identify active connections on potentially dangerous ports.
- **Process Monitoring**: Scan for known malicious or unauthorized processes.
- **System Log Analysis**: Search event logs for errors or signs of unauthorized access.
- **File Integrity Monitoring**: Detect unauthorized changes to critical system files.

These features can be configured with user-defined settings and thresholds to meet different security needs.

## 🔧 Modules Breakdown
The project is built using reusable modules, each designed for a specific function:

- **ConfigLoader.psm1**: Loads and manages settings from `config.json`.
- **EnvLoader.psm1**: Loads environment variables from a `.env` file for sensitive information.
- **FileHasher.psm1**: Provides hashing functions to verify file integrity.
- **Logger.psm1**: Standardized logging with timestamped entries and log levels.
- **NetworkUtils.psm1**: Network utility functions to identify open and suspicious ports.

## 📋 Getting Started

### Prerequisites
- **PowerShell**: Version 7.0 or higher is recommended. Check your version with:

    ```powershell
    $PSVersionTable.PSVersion
    ```

- **Git (optional)**: If you want to clone this repository from GitHub.

### Installation
Prepare PowerShell Modules: Unblock all scripts and modules to ensure they can be run:

```powershell
Get-ChildItem -Path . -Recurse -Filter *.ps1,*.psm1 | Unblock-File
```

### Configuration
1. **Set Up the .env File**: Create a `.env` file in the project’s root directory to securely store sensitive information. Here’s an example:

    ```plaintext
    GITHUB_USERNAME=yourusername
    GITHUB_EMAIL=youremail@example.com
    GITHUB_TOKEN=your-personal-access-token
    WINDOWS_USER=yourwindowsusername
    PUBLIC_IP=yourpublicip
    LAN_NETWORK=yourlanaddress
    ```

2. **Edit config.json**: Customize `config.json` to define monitored files, suspicious ports, keywords, and other settings:

    ```json
    {
      "LogDirectory": "C:\path\to\logs\",
      "MonitoredFiles": ["C:\Windows\System32\drivers\etc\hosts"],
      "SuspiciousProcesses": ["nc", "powershell", "cmd.exe"],
      "SuspiciousPorts": [4444, 8080],
      "MaxLogEntries": 100,
      "ErrorKeywords": ["failed password", "unauthorized"]
    }
    ```

## 🚀 Usage
Each script is designed to run independently. Here’s an example for each:

- **Network Connections Check**:

    ```powershell
    cd Scripts
    .\CheckNetworkConnections.ps1
    ```

- **Running Processes Check**:

    ```powershell
    .\CheckRunningProcesses.ps1
    ```

- **System Logs Check**:

    ```powershell
    .\CheckSystemLogs.ps1
    ```

- **File Integrity Check**:

    ```powershell
    .\CheckUnauthorizedFileChanges.ps1
    ```

Each script writes logs to the directory specified in `config.json`, with detailed information about detected activity.

## 📄 Logs and Output
Logs are created with timestamps, making it easy to trace and investigate suspicious activity. Log files are located in the Logs directory and follow a standard format:

- **INFO**: General information about script activity
- **WARNING**: Indicates suspicious or notable activity
- **ERROR**: Details any errors or issues encountered

Example log entry:

```
[2024-10-10 10:30:25] [INFO] Starting network connection check...
[2024-10-10 10:30:45] [WARNING] Suspicious connection detected: LocalPort 8080
```

## 💡 Troubleshooting
- **Permissions**: Run PowerShell as Administrator if you encounter permission errors.
- **Modules Not Loaded**: Ensure all modules in `Modules/` are unblocked (`Unblock-File`) and imported correctly.
- **Sensitive Data**: Double-check that `.env` and `.idea/` are listed in `.gitignore` to prevent sensitive data from being committed.

## 🤝 Contributing
Interested in contributing? Here’s how:

1. Fork the repository on GitHub.
2. Create a feature branch:

    ```bash
    git checkout -b feature-new-check
    ```

3. Make your changes and commit them with a descriptive message.
4. Push your branch and open a pull request.

## 🙏 Acknowledgements
A big thanks to [Dan Duran](https://github.com/Dan-Duran) for his inspiring work and contributions to the tech community. His dedication to cybersecurity and technology optimization has provided invaluable insights and tools. Grateful for the knowledge shared through his repos and the inspiration to keep pushing boundaries in the field. 🚀

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.


