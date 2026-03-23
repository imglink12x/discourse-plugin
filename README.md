# ImgLink - Fast Image Hosting Platform

A high-performance image hosting platform built with Node.js, Next.js, and Cloudflare R2. Upload, share, and embed images instantly.

## Features

- **Instant uploads** - drag & drop, paste from clipboard, multi-file
- **Anonymous & authenticated** uploads
- **Auto-processing** - metadata stripping, compression, thumbnail generation
- **Direct links, embeds** - Markdown, HTML, BBCode
- **Albums / galleries** - organize images into collections
- **User dashboard** - manage uploads, albums, API keys
- **Admin panel** - full moderation, user management, analytics, IP banning
- **Developer API** - upload and manage via API keys
- **Dark mode** - clean, modern, responsive UI
- **CDN delivery** - Cloudflare R2 + CDN for global performance
- **Docker ready** - single command deployment

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Node.js + Fastify |
| Frontend | Next.js 14 + TailwindCSS |
| Database | PostgreSQL |
| Cache/Queue | Redis + BullMQ |
| Storage | Cloudflare R2 (S3-compatible) |
| Image Processing | Sharp |

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Cloudflare R2 bucket with credentials

### 1. Clone and configure

```bash
cp .env.example .env
# Edit .env with your R2 credentials and JWT secret
```

### 2. Start with Docker Compose

```bash
docker compose up -d
```

This starts PostgreSQL, Redis, the backend API, image processing worker, and the frontend.

### 3. Access

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **Admin login**: username `admin`, password `admin`

## Local Development (without Docker)

### Prerequisites

- Node.js 20+
- PostgreSQL running locally
- Redis running locally

### Backend

```bash
cd backend
npm install
npm run migrate
npm run seed
npm run dev        # API server on :3001
npm run worker     # Image processing worker (separate terminal)
```

### Frontend

```bash
cd frontend
npm install
npm run dev        # Next.js on :3000
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `R2_ENDPOINT` | Cloudflare R2 S3-compatible endpoint |
| `R2_ACCESS_KEY` | R2 access key ID |
| `R2_SECRET_KEY` | R2 secret access key |
| `R2_BUCKET_NAME` | R2 bucket name |
| `JWT_SECRET` | Secret for JWT token signing |
| `CDN_URL` | Base URL for image delivery |
| `FRONTEND_URL` | Frontend URL for CORS and link generation |
| `MAX_FILE_SIZE` | Max upload size in bytes (default: 20MB) |

## API Documentation

### Authentication

All authenticated endpoints use Bearer token:
```
Authorization: Bearer <jwt_token>
```

API key endpoints use:
```
X-API-Key: <api_key>
```

### Endpoints

#### Upload

```
POST /api/upload
Content-Type: multipart/form-data

Body: file (one or more image files)

Response:
{
  "images": [
    {
      "id": "abc123",
      "url": "http://localhost:3001/cdn/abc123.png",
      "thumbnail": "http://localhost:3001/cdn/thumb/abc123.webp",
      "viewer": "http://localhost:3000/i/abc123",
      "width": 1920,
      "height": 1080,
      "size": 245760,
      "mime": "image/png"
    }
  ]
}
```

#### Get Image

```
GET /api/images/:id

Response: image metadata + embed codes
```

#### Delete Image

```
DELETE /api/images/:id
Authorization: Bearer <token>
```

#### Auth

```
POST /api/auth/register   { username, email, password }
POST /api/auth/login      { login, password }
GET  /api/auth/me         (authenticated)
```

#### Albums

```
GET    /api/albums              (authenticated)
POST   /api/albums              { title, description, isPublic }
GET    /api/albums/:id
PUT    /api/albums/:id          { title, description, isPublic }
DELETE /api/albums/:id
POST   /api/albums/:id/images  { imageId }
DELETE /api/albums/:albumId/images/:imageId
```

### Rate Limits

- Anonymous: 10 uploads/hour
- Authenticated: 100 uploads/hour
- General API: 200 requests/minute

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Browser   │────▶│  Next.js     │     │  Cloudflare  │
│             │     │  Frontend    │     │  R2 + CDN    │
└─────────────┘     └──────┬───────┘     └──────▲───────┘
                           │                     │
                    ┌──────▼───────┐     ┌───────┴──────┐
                    │   Fastify    │────▶│   Worker     │
                    │   Backend    │     │  (BullMQ)    │
                    └──────┬───────┘     └──────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │PostgreSQL│ │  Redis   │ │   R2     │
        └──────────┘ └──────────┘ └──────────┘
```

## Storage Structure

Images are stored with hash-sharded paths for optimal distribution:

```
images/
  ab/
    cd/
      abcdef1234.png          (original)
      abcdef1234_thumbnail.webp
      abcdef1234_small.webp
      abcdef1234_medium.webp
```

## Supported Formats

- PNG, JPG/JPEG, WebP, GIF, SVG
- Future: AVIF, HEIC

## License

MIT
