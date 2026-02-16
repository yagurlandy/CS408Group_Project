## Author: Andy Lopez-Martinez

# Full-Stack Web Application

This repository contains a full-stack web application built with Node.js,
Express, and SQLite. It includes scripts and documentation for setting up,
configuring, and deploying the application on an AWS EC2 instance. The application
uses Docker for containerization and simplified deployment.

- [Development Guide (Docker)](dev-node/README.md)
- [Deployment Guide (Docker)](deploy-docker/README.md)

>[!TIP]
>Docker is the recommended approach for development and deployment as it abstracts away many of the complexities of server configuration and application setup. It allows you to run the application in a consistent environment across different machines and simplifies the deployment process. You are not required to use Docker for this course, but it is highly recommended for a smoother experience. If you choose to deploy manually without Docker, you will need to follow the manual deployment instructions provided in the documentation.

## Technology Stack

### Backend technology stack
- Backend Runtime: Go
- Web Server: Go `net/http`
- Templating: Go `html/template`

### Frontend technology stack
- Templates: Go HTML templates
- UX/UI: Bootstrap (via CDN)

### Testing Frameworks
- Unit Testing: Go `testing` package
- HTTP Testing: `net/http/httptest`

## Manual Deployment

>[!WARNING]
>These instructions are for students who want to deploy the application manually without using Docker. This is an optional approach and is not required for the course. Manual deployment involves more steps and requires a deeper understanding of server configuration and application setup. It is recommended for students who want to gain hands-on experience with server administration and application deployment beyond the scope of Docker.

- [Deployment Guide (Manual)](deploy-node/README.md)
- [AWS EC2 Launch Guide](aws/README.md)

## Team Workflow
Single repository with collaborators. One team member maintains the main
repository. All changes are made in feature branches and merged into `main`
using pull requests. GitHub Actions runs tests on every push and pull request.
