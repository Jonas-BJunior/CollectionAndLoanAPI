# CollectionAndLoanAPI

Backend API for the CollectionAndLoan app.

## Stack

- Ruby 3.4+
- Rails 8 (API mode)
- PostgreSQL 16
- JWT auth

## Local Setup

1. Install dependencies:

```bash
bundle install
```

2. Create and migrate database:

```bash
bin/rails db:create db:migrate
```

3. Start server:

```bash
bin/rails server
```

Server default URL:

- http://localhost:3000

## API Versioning

All endpoints are under:

- `/api/v1`

## Authentication

JWT Bearer token flow:

1. `POST /api/v1/auth/register`
2. `POST /api/v1/auth/login`
3. Send `Authorization: Bearer <token>` to protected routes.

## Main Resources

- Friends
- Items
- Loans

## Loan Business Rules

1. An item can only have one active loan at a time.
2. Loan `expected_return_date` must be on or after `loan_date`.
3. Item and friend in a loan must belong to the authenticated user.
4. Returning a loan sets item status back to `available`.

## API Blueprint / Contract

OpenAPI file:

- `docs/openapi.yaml`

This file is the source of truth for endpoint contracts during app-backend integration.

## Quick Endpoint List

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`
- `GET/POST /api/v1/friends`
- `GET/PATCH/DELETE /api/v1/friends/:id`
- `GET/POST /api/v1/items`
- `GET/PATCH/DELETE /api/v1/items/:id`
- `GET/POST /api/v1/loans`
- `GET/PATCH/DELETE /api/v1/loans/:id`
- `POST /api/v1/loans/:id/return_item`
