FROM python:3.10.16
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml .
COPY .python-version .
COPY app/main.py .
COPY uv.lock .
COPY app/lgbm_model.pkl .

# Install dependencies
RUN uv sync --frozen

CMD ["uv", "run", "main.py"]