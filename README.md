# Planning Game Server

## Running the Backend Locally

The backend server is a Swift Vapor application that can be run by pressing the "Play" button in Xcode.

* [Vapor (Server Side Swift)](https://vapor.codes)
* [Xcode IDE](https://developer.apple.com/xcode/)
* [Swift Programming Language](https://developer.apple.com/swift/)

The server can also be started with a terminal command on any supported OS platform:

```zsh
swift run
```

### Inital Setup (Xcode)

Xcode requires a one-time setup for use with Vapor.

* [Getting Started: Xcode](https://docs.vapor.codes/getting-started/xcode/)

---

## Frontend App

The frontend application is built with the Elm programming language and the elm-ui package for developing the UI.

* [Elm Lang](https://elm-lang.org)
* [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/)

### Compiling the Frontend

Elm programs compile to standard JavaScript for execution inside a web browser.

Use one of the following commands to compile the frontend code.

#### Without Optimization (Development)

```zsh
cd ./Frontend
elm make src/Main.elm --output=../Public/scripts/main.js
```

#### With Optimization (Production)

```zsh
cd ./Frontend
elm make src/Main.elm --optimized --output=../Public/scripts/main.js
```

For details on optimizing the frontend app for production deployment see
[Elm Optimization & Minification Guide](https://guide.elm-lang.org/optimization/asset_size.html).

---

## Building for Production

### Install Docker Desktop

Download the Docker Desktop application for your OS platform from the official site:

* [Docker Desktop Download Site](https://www.docker.com/products/docker-desktop/)

### Docker/Docker Compose

This application can be deployed using Docker and Docker Compose.

### Building the Project

It is recommended to build the Elm frontend using the `--optimize` flag for production. The latest release version
should already be build with this flag.

```zsh
docker compose build
```

### Running the Application with Docker

```zsh
docker compose up app
```

or in detached mode:

```zsh
docker compose up --detach app
```

---

### Running the Game Locally

The servers binds to point 8080 by default, so you'll need to be sure that port is available, or update the
`docker-compose.yml` file to bind to a different host point.

Goto `http://localhost:8080/` in your favorite web browser.

### Enable the Debug Console View

The frontend application provides a debugging console that can be enabled only when running in the `development`
environment. This feature is enabled by setting an environment variable.

```zsh
CONSOLE=true
```

This variable can be set by editing the Run Scheme in Xcode.

```text
Product -> Scheme -> Edit Scheme...
```

Select the "Run" step and add the new environment variable.
