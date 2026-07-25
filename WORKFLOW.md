# React App → Docker → Jenkins → EC2: Deployment Workflow

## Architecture

```
Developer            GitHub                 Jenkins (on EC2)              DockerHub          EC2 (runtime)
   |  git push  ------->|                        |                            |                    |
   |                    | --- webhook trigger --->|                            |                    |
   |                    |                        | git clone (Checkout)        |                    |
   |                    |                        | ./build.sh <branch>  ------>| (build image)      |
   |                    |                        | docker push          ------>| dev/prod repo      |
   |                    |                        | ./deploy.sh <branch> ---------------------------->| pull + run
```

Two branches, two DockerHub repos:
- `dev` branch → `your-dockerhub-username/dev` (public repo)
- `master` branch → `your-dockerhub-username/prod` (private repo)

## Repo layout

```
.
├── src/                       # React source
├── Dockerfile                 # production image: build React, serve via nginx
├── Dockerfile.dev             # local dev image: CRA dev server with hot reload
├── docker-compose.dev.yml     # local development (port 3000, volume-mounted src)
├── docker-compose.prod.yml    # deployment target on EC2 (port 80, pulls built image)
├── build.sh                   # builds & tags the image for the given branch
├── deploy.sh                  # points docker-compose.prod.yml at the new image and restarts it
├── Jenkinsfile                # pipeline: checkout → build → push → deploy
├── .dockerignore
└── .gitignore
```

## Local development

```bash
docker compose -f docker-compose.dev.yml up
```
Runs the CRA dev server in a container on `localhost:3000` with live reload (`WATCHPACK_POLLING=true` is required so file-change events reach the container on non-Linux hosts / some volume setups).

## Production image

`Dockerfile` is a two-stage build:
1. `node:18-alpine` installs dependencies and runs `npm run build`.
2. `nginx:alpine` serves only the compiled `/build` output on port 80.

This keeps the shipped image small and never includes `node_modules` or source in the final layer.

## CI/CD pipeline (Jenkins)

1. **Checkout** — clones the repo at whichever branch triggered the build (`dev` or `master`).
2. **Build Docker Image** — runs `./build.sh <branch>`, which builds the image once and tags it for the correct DockerHub repo based on branch.
3. **Push to DockerHub** — logs in with the `dockerhub-creds` credential and pushes the branch-appropriate tag.
4. **Deploy** — runs `./deploy.sh <branch>`, which rewrites the `image:` line in `docker-compose.prod.yml` to the branch's image, stops the running container, pulls the new image, and brings it back up.

The branch name is passed explicitly into both scripts (`./build.sh ${BRANCH_NAME}`, `./deploy.sh ${BRANCH_NAME}`) — without this, both scripts silently default to `dev` regardless of which branch triggered the pipeline.

## EC2 setup (one-time)

1. Launch EC2 instance (e.g. `t3.large`).
2. Security group inbound rules:
   - SSH (22) — restricted to your IP
   - HTTP (80) — anywhere, for the deployed app
   - Custom TCP 8080 — restricted to your IP, for Jenkins UI
3. Install Docker, Git, Java (Jenkins dependency), and Jenkins.
4. Access Jenkins at `http://<ec2-public-dns>:8080`, complete setup, install the Docker Pipeline plugin.
5. Create a Pipeline job → "Pipeline script from SCM" → point at this repo → add a GitHub webhook so pushes trigger builds automatically.
6. Add DockerHub credentials in Jenkins as `dockerhub-creds`.

## What was fixed from the original draft

| Issue | Fix |
|---|---|
| `docker-compose.yml` had invalid YAML (`Service:`, bad indent, stray quote) and mixed dev/prod concerns | Split into `docker-compose.dev.yml` (hot reload) and `docker-compose.prod.yml` (deployment) |
| `Dockerfile` copied raw source into nginx, never built the app | Multi-stage build: `npm run build` first, then serve `/build` via nginx |
| `build.sh` / `deploy.sh` never received the branch from Jenkins | `Jenkinsfile` now calls `./build.sh ${BRANCH_NAME}` and `./deploy.sh ${BRANCH_NAME}` |
| `deploy.sh` ran `sed` on an `image:` key that didn't exist in the compose file | `docker-compose.prod.yml` has a real `image:` key for `deploy.sh` to patch |
| `.dockerignore` had leading spaces on some patterns (`.gitignore`, `.dockerignore`, `Dockerfile`) so they never matched | Removed leading whitespace, corrected filename casing |
| `.gitignore` was empty | Populated with standard Node/React ignores |
| Registry name mismatch between `build.sh`/`deploy.sh` (`your-dockerhub-username`) and `Jenkinsfile` (`mubha`) | Standardized on one placeholder — replace `your-dockerhub-username` with your actual DockerHub username throughout |
