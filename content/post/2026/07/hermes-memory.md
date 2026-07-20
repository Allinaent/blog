+++
title = "团队如何使用hermes共享记忆"
date = 2026-07-10T11:12:00+08:00
lastmod = 2026-07-20T19:04:03+08:00
categories = ["ai"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/a5024b3cfabbbb97c49656e4223d6be8.png"
+++

<https://www.zhihu.com/question/2039044882887616442> ，已经有人研究了怎么做。常用的软件有 mem0 ，Hindsight。


## 我的做法 {#我的做法}

nas中布署了 hindsight-slim 的服务。使用阿里百炼的 text-embedding-v4 做向量化。然后 hindsight 接的 deepseek-flash做后端大模型。实测可用，速度和效果暂时都还觉得不错。

分享一下配置：

```yaml
version: "3.8"

services:
  db:
    image: pgvector/pgvector:pg16
    container_name: hindsight-db
    environment:
      POSTGRES_USER: hindsight
      POSTGRES_PASSWORD: mmm
      POSTGRES_DB: hindsight
    volumes:
      - /share/Docker/ai-memory/postgres-data:/var/lib/postgresql/data
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
  hindsight:
    image: ghcr.io/vectorize-io/hindsight:latest-slim
    container_name: hindsight-app
    ports:
      - "18888:8888"
      - "9999:9999"
    volumes:
      - /share/Docker/ai-memory/hindsight-data:/home/hindsight/.pg0
    environment:
      TZ: Asia/Shanghai
      HINDSIGHT_DB_HOST: db
      HINDSIGHT_DB_PORT: 5432
      HINDSIGHT_DB_NAME: hindsight
      HINDSIGHT_DB_USER: hindsight
      HINDSIGHT_DB_PASSWORD: mmm
      HINDSIGHT_API_EMBEDDINGS_PROVIDER: openai
      HINDSIGHT_API_EMBEDDINGS_OPENAI_BASE_URL: https://ws-x0pz7lt9imoytqek.cn-beijing.maas.aliyuncs.com/compatible-mode/v1
      HINDSIGHT_API_EMBEDDINGS_OPENAI_BATCH_SIZE: "10"
      HINDSIGHT_API_EMBEDDINGS_OPENAI_API_KEY: xxx
      OPENAI_API_KEY: xxx
      HINDSIGHT_API_OPENAI_API_KEY: xxx
      HINDSIGHT_API_KEY: xxx
      HINDSIGHT_API_EMBEDDINGS_OPENAI_MODEL: text-embedding-v4
      HINDSIGHT_API_LLM_PROVIDER: openai
      HINDSIGHT_API_LLM_BASE_URL: https://api.deepseek.com/v1
      HINDSIGHT_API_LLM_API_KEY: xxx
      HINDSIGHT_API_LLM_MODEL: deepseek-chat
      HINDSIGHT_API_LLM_TIMEOUT: 60
      HINDSIGHT_API_RERANKER_PROVIDER: rrf
      HINDSIGHT_CONSOLIDATE_INTERVAL: 86400
      HINDSIGHT_API_RECALL_MAX_CONCURRENT: 4
      HINDSIGHT_API_WORKER_REFRESH_MENTAL_MODEL_MAX_SLOTS: 1
      HINDSIGHT_API_WORKER_RETAIN_MAX_SLOTS: 1
      HINDSIGHT_API_DB_POOL_MAX_SIZE: 50
      HINDSIGHT_API_TENANT_EXTENSION: hindsight_api.extensions.builtin.tenant:ApiKeyTenantExtension
      HINDSIGHT_API_TENANT_API_KEY: yyy
      HINDSIGHT_CP_ACCESS_KEY: yyy
      HINDSIGHT_API_MCP_AUTH_TOKEN: yyy
    deploy:
      resources:
        limits:
          memory: 1.8G
          cpus: '1.0'
    depends_on:
      - db
    restart: unless-stopped
```
