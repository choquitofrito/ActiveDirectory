FROM python:3.12-slim AS builder
WORKDIR /app
COPY . .
RUN pip install mkdocs-material && mkdocs build

FROM nginx:alpine
COPY --from=builder /app/site /usr/share/nginx/html
EXPOSE 80
