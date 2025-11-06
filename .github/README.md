# GitHub Configuration

This directory contains GitHub-specific configuration files for the Chatbot de Tributos project.

## Files

### copilot-instructions.md
Comprehensive instructions for GitHub Copilot and other AI coding assistants. This file provides:

- **Architecture Overview**: 3-service orchestration (WAHA → n8n → Python API)
- **Code Patterns**: RAG implementation, LLM provider selection, WAHA integration
- **Development Workflows**: PowerShell scripts, Docker commands, testing procedures
- **Critical Conventions**: Environment variables, webhook payload handling, logging
- **Troubleshooting Guides**: Common issues and solutions
- **Quick Reference**: Essential commands, files, and credentials

**For AI Agents**: This file helps AI coding assistants understand the project's unique patterns and conventions to provide better assistance.

**For Developers**: Use this as a quick reference guide when working on the project.

### workflows/
Contains GitHub Actions workflows for CI/CD:

- `ci.yml`: Continuous integration pipeline (linting, testing, Docker builds)

## Additional Resources

- [Project README](../README.md) - Main project documentation
- [Architecture](../ARCHITECTURE.md) - System architecture details
- [Development Guide](../DEVELOPMENT.md) - Developer workflows
- [Start Here](../START-HERE.md) - Quick start guide
