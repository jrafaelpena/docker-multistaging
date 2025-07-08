# Docker Multistage Optimization for LGBMClassifier Deployment

## 📦 Project Overview

This project demonstrates the application of **Docker multistaging** to efficiently package and deploy a Python application that uses an **LGBMClassifier** model. By leveraging Docker multistage builds, the final image is significantly reduced in size, leading to faster deployments, reduced attack surface, and optimized runtime environments.

---

## 🚀 Key Features

- **Multistage Docker Build:** Separate build and runtime stages to exclude unnecessary development dependencies.
- **Optimized Runtime Image:** Uses a slim Python base image with only essential libraries.
- **Efficient Dependency Management:** Installs dependencies using [uv](https://github.com/astral-sh/uv), a fast Python package manager.
- **Lightweight LGBM Environment:** Installs only required system-level libraries (e.g., `libgomp1` for LightGBM).

---

## 🛠️ Dockerfile Structure

### Stage 1: Builder

- **Base Image:** `python:3.10.16`
- **Tools:** Copies the `uv` binary from an upstream container to manage dependencies.
- **Dependency Installation:** Uses project files (`pyproject.toml`, `uv.lock`) to install all required packages into a virtual environment (`.venv`).
- **Bytecode Optimization:** Pre-compiles Python bytecode to improve startup times.

### Stage 2: Slim Final Image

- **Base Image:** `python:3.10.16-slim`
- **System Libraries:** Installs only `libgomp1`, required by LightGBM.
- **Optimizations:** 
  - Disables Python bytecode generation and enables unbuffered output.
  - Copies only the virtual environment and the application source code from the builder stage.
- **Execution:** Runs the application via `python main.py`.

---

## 🐳 Example Dockerfile (Simplified)

```Dockerfile
# ------------------------
# Stage 1: Builder
# ------------------------
FROM python:3.10.16 AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PROJECT_ENVIRONMENT=/app/.venv
WORKDIR /app

RUN --mount=type=cache,target=/root/.cache \
    --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project

# ------------------------
# Stage 2: Slim Final Image
# ------------------------
FROM python:3.10.16-slim

RUN apt-get update && apt-get install -y libgomp1
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
COPY app/ .

ENV PATH="/app/.venv/bin:$PATH"
CMD ["python", "main.py"]