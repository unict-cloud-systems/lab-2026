# Cloud Systems Lab 2026 — Course Plan

**University of Catania (UniCT)**  
Lab course (companion to the main theory course)  
10 lessons × 2 hours each — one notebook per lesson

---

## Lesson 1 — Docker ✅
**Notebook:** `Docker.ipynb`

- What is a container? Linux containers, namespaces, cgroups
- Docker architecture: daemon, CLI, registry
- Images vs containers
- Dockerfile: writing, building, layering
- Essential CLI commands (`run`, `build`, `exec`, `logs`, `rm`, `rmi`)
- Port mapping & volumes (bind mounts, named volumes)
- Docker Hub & image tagging/pushing
- Hands-on: containerise a simple Python/Node web app

---

## Lesson 2 — Composition: From Business Drivers to Docker

**Notebook:** `Composition.ipynb`

### Intro framing: Gartner → MACH → Docker

- **Business motivation (Gartner lens):** why organisations need modular, composable capabilities to improve speed, resilience, and adaptability.
- **Architecture translation:** connect composable business capabilities to composable application design.
- **MACH as implementation style:**
	- **M**icroservices
	- **A**PI-first
	- **C**loud-native
	- **H**eadless
- **Docker opportunity:** containers as a practical enabler for packaging, portability, environment consistency, and independent service lifecycle management.

### Journey in practice: Compose → Swarm → Stack

### Phase 1: Docker Compose (the “Dev” phase)

- **Concept:** Docker Compose defines multi-container applications on a single machine using declarative YAML.
- **Problem it solves:** Running multiple `docker run ...` commands with manual network, volume, and port flags is error-prone and hard to maintain.
- **Hands-on activity:** Students write a `docker-compose.yml` for a simple app (e.g., web frontend + Redis/Postgres backend).
- **Key commands:** `docker compose up -d`, `docker compose down`, `docker compose logs`.

### Phase 2: Docker Swarm (the “Prod” phase)

- **Concept:** Clustering and high availability; roles of **Manager** and **Worker** nodes.
- **Problem it solves:** Transition question: “What happens if your laptop catches fire?”
	- Introduce self-healing and workload distribution across nodes.
- **Hands-on activity:** Initialize a swarm with `docker swarm init`; if possible, join a second machine/VM with `docker swarm join`.
- **Key commands:** `docker node ls`, `docker service create`, `docker service scale`.

### Phase 3: The Bridge (Compose in Swarm)

- **Concept:** Docker Stack as the bridge from local Compose to clustered Swarm deployments.
- **Aha moment:** Swarm can deploy from the same `docker-compose.yml` students already know.
- **Differences to highlight:**
	- Swarm ignores `build` instructions (images must be pre-built and available via registry).
	- Introduce `deploy:` in YAML (e.g., replicas and rollout behavior).
- **Hands-on activity:** Extend the Phase 1 Compose file with:
	- `deploy:`
	- `replicas: 3`
	- Deploy to swarm as a stack.
- **Key commands:** `docker stack deploy -c docker-compose.yml myapp`, `docker stack ls`, `docker stack services myapp`.

---

## Lessons 3–10 — TBD

> Programme to be defined.
