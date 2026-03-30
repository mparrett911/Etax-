/*
  # Initialize TaxHacker Database Schema

  1. New Tables
    - `users` - User accounts with authentication and subscription info
    - `sessions` - User session management
    - `account` - OAuth and password authentication accounts
    - `verification` - Email verification and password reset tokens
    - `settings` - User-specific settings
    - `categories` - Transaction categories
    - `projects` - Project management for transactions
    - `fields` - Custom fields for transactions
    - `files` - Uploaded files (receipts, invoices)
    - `transactions` - Financial transactions with AI analysis
    - `currencies` - Currency codes and names
    - `app_data` - Application-specific data storage
    - `progress` - Long-running task progress tracking

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to access their own data

  3. Features
    - UUID primary keys
    - Composite unique constraints
    - Foreign key relationships with CASCADE delete
    - JSONB fields for flexible data
    - Indexes for performance
*/

-- CreateTable: users
CREATE TABLE IF NOT EXISTS "users" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "avatar" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "membership_plan" TEXT,
    "membership_expires_at" TIMESTAMP(3),
    "is_email_verified" BOOLEAN NOT NULL DEFAULT false,
    "storage_used" INTEGER NOT NULL DEFAULT 0,
    "storage_limit" INTEGER NOT NULL DEFAULT -1,
    "ai_balance" INTEGER NOT NULL DEFAULT 0,
    "stripe_customer_id" TEXT,
    "business_name" TEXT,
    "business_address" TEXT,
    "business_bank_details" TEXT,
    "business_logo" TEXT,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable: sessions
CREATE TABLE IF NOT EXISTS "sessions" (
    "id" UUID NOT NULL,
    "token" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "user_id" UUID NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable: account
CREATE TABLE IF NOT EXISTS "account" (
    "id" TEXT NOT NULL,
    "account_id" TEXT NOT NULL,
    "provider_id" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "access_token" TEXT,
    "refresh_token" TEXT,
    "id_token" TEXT,
    "access_token_expires_at" TIMESTAMP(3),
    "refresh_token_expires_at" TIMESTAMP(3),
    "scope" TEXT,
    "password" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "account_pkey" PRIMARY KEY ("id")
);

-- CreateTable: verification
CREATE TABLE IF NOT EXISTS "verification" (
    "id" UUID NOT NULL,
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_pkey" PRIMARY KEY ("id")
);

-- CreateTable: settings
CREATE TABLE IF NOT EXISTS "settings" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "value" TEXT,

    CONSTRAINT "settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable: categories
CREATE TABLE IF NOT EXISTS "categories" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "color" TEXT NOT NULL DEFAULT '#000000',
    "llm_prompt" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable: projects
CREATE TABLE IF NOT EXISTS "projects" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "color" TEXT NOT NULL DEFAULT '#000000',
    "llm_prompt" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable: fields
CREATE TABLE IF NOT EXISTS "fields" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'string',
    "llm_prompt" TEXT,
    "options" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_visible_in_list" BOOLEAN NOT NULL DEFAULT false,
    "is_visible_in_analysis" BOOLEAN NOT NULL DEFAULT false,
    "is_required" BOOLEAN NOT NULL DEFAULT false,
    "is_extra" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "fields_pkey" PRIMARY KEY ("id")
);

-- CreateTable: files
CREATE TABLE IF NOT EXISTS "files" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "filename" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "mimetype" TEXT NOT NULL,
    "metadata" JSONB,
    "is_reviewed" BOOLEAN NOT NULL DEFAULT false,
    "is_splitted" BOOLEAN NOT NULL DEFAULT false,
    "cached_parse_result" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "files_pkey" PRIMARY KEY ("id")
);

-- CreateTable: transactions
CREATE TABLE IF NOT EXISTS "transactions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT,
    "description" TEXT,
    "merchant" TEXT,
    "total" INTEGER,
    "currency_code" TEXT,
    "converted_total" INTEGER,
    "converted_currency_code" TEXT,
    "type" TEXT DEFAULT 'expense',
    "items" JSONB NOT NULL DEFAULT '[]',
    "note" TEXT,
    "files" JSONB NOT NULL DEFAULT '[]',
    "extra" JSONB,
    "category_code" TEXT,
    "project_code" TEXT,
    "issued_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "text" TEXT,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable: currencies
CREATE TABLE IF NOT EXISTS "currencies" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "currencies_pkey" PRIMARY KEY ("id")
);

-- CreateTable: app_data
CREATE TABLE IF NOT EXISTS "app_data" (
    "id" UUID NOT NULL,
    "app" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "data" JSONB NOT NULL,

    CONSTRAINT "app_data_pkey" PRIMARY KEY ("id")
);

-- CreateTable: progress
CREATE TABLE IF NOT EXISTS "progress" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "data" JSONB,
    "current" INTEGER NOT NULL DEFAULT 0,
    "total" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "progress_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "users_email_key" ON "users"("email");
CREATE UNIQUE INDEX IF NOT EXISTS "sessions_token_key" ON "sessions"("token");
CREATE UNIQUE INDEX IF NOT EXISTS "settings_user_id_code_key" ON "settings"("user_id", "code");
CREATE UNIQUE INDEX IF NOT EXISTS "categories_user_id_code_key" ON "categories"("user_id", "code");
CREATE UNIQUE INDEX IF NOT EXISTS "projects_user_id_code_key" ON "projects"("user_id", "code");
CREATE UNIQUE INDEX IF NOT EXISTS "fields_user_id_code_key" ON "fields"("user_id", "code");
CREATE UNIQUE INDEX IF NOT EXISTS "currencies_user_id_code_key" ON "currencies"("user_id", "code");
CREATE UNIQUE INDEX IF NOT EXISTS "app_data_user_id_app_key" ON "app_data"("user_id", "app");

-- CreateIndex for performance
CREATE INDEX IF NOT EXISTS "transactions_user_id_idx" ON "transactions"("user_id");
CREATE INDEX IF NOT EXISTS "transactions_project_code_idx" ON "transactions"("project_code");
CREATE INDEX IF NOT EXISTS "transactions_category_code_idx" ON "transactions"("category_code");
CREATE INDEX IF NOT EXISTS "transactions_issued_at_idx" ON "transactions"("issued_at");
CREATE INDEX IF NOT EXISTS "transactions_name_idx" ON "transactions"("name");
CREATE INDEX IF NOT EXISTS "transactions_merchant_idx" ON "transactions"("merchant");
CREATE INDEX IF NOT EXISTS "transactions_total_idx" ON "transactions"("total");
CREATE INDEX IF NOT EXISTS "progress_user_id_idx" ON "progress"("user_id");

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'sessions_user_id_fkey'
    ) THEN
        ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'account_user_id_fkey'
    ) THEN
        ALTER TABLE "account" ADD CONSTRAINT "account_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'settings_user_id_fkey'
    ) THEN
        ALTER TABLE "settings" ADD CONSTRAINT "settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'categories_user_id_fkey'
    ) THEN
        ALTER TABLE "categories" ADD CONSTRAINT "categories_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'projects_user_id_fkey'
    ) THEN
        ALTER TABLE "projects" ADD CONSTRAINT "projects_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fields_user_id_fkey'
    ) THEN
        ALTER TABLE "fields" ADD CONSTRAINT "fields_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'files_user_id_fkey'
    ) THEN
        ALTER TABLE "files" ADD CONSTRAINT "files_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'transactions_user_id_fkey'
    ) THEN
        ALTER TABLE "transactions" ADD CONSTRAINT "transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'transactions_category_code_user_id_fkey'
    ) THEN
        ALTER TABLE "transactions" ADD CONSTRAINT "transactions_category_code_user_id_fkey" FOREIGN KEY ("category_code", "user_id") REFERENCES "categories"("code", "user_id") ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'transactions_project_code_user_id_fkey'
    ) THEN
        ALTER TABLE "transactions" ADD CONSTRAINT "transactions_project_code_user_id_fkey" FOREIGN KEY ("project_code", "user_id") REFERENCES "projects"("code", "user_id") ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'currencies_user_id_fkey'
    ) THEN
        ALTER TABLE "currencies" ADD CONSTRAINT "currencies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'app_data_user_id_fkey'
    ) THEN
        ALTER TABLE "app_data" ADD CONSTRAINT "app_data_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'progress_user_id_fkey'
    ) THEN
        ALTER TABLE "progress" ADD CONSTRAINT "progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

-- Enable Row Level Security
ALTER TABLE "users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "sessions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "account" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "verification" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "settings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "categories" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "projects" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "fields" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "files" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "transactions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "currencies" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "app_data" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "progress" ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own data"
  ON "users" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own data"
  ON "users" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text)
  WITH CHECK (auth.uid()::text = id::text);

-- RLS Policies for sessions table
CREATE POLICY "Users can view own sessions"
  ON "sessions" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own sessions"
  ON "sessions" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for account table
CREATE POLICY "Users can view own accounts"
  ON "account" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for settings table
CREATE POLICY "Users can view own settings"
  ON "settings" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own settings"
  ON "settings" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own settings"
  ON "settings" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own settings"
  ON "settings" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for categories table
CREATE POLICY "Users can view own categories"
  ON "categories" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own categories"
  ON "categories" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own categories"
  ON "categories" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own categories"
  ON "categories" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for projects table
CREATE POLICY "Users can view own projects"
  ON "projects" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own projects"
  ON "projects" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own projects"
  ON "projects" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own projects"
  ON "projects" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for fields table
CREATE POLICY "Users can view own fields"
  ON "fields" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own fields"
  ON "fields" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own fields"
  ON "fields" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own fields"
  ON "fields" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for files table
CREATE POLICY "Users can view own files"
  ON "files" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own files"
  ON "files" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own files"
  ON "files" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own files"
  ON "files" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for transactions table
CREATE POLICY "Users can view own transactions"
  ON "transactions" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own transactions"
  ON "transactions" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own transactions"
  ON "transactions" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own transactions"
  ON "transactions" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for currencies table
CREATE POLICY "Users can view own currencies"
  ON "currencies" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text OR user_id IS NULL);

CREATE POLICY "Users can insert own currencies"
  ON "currencies" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own currencies"
  ON "currencies" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own currencies"
  ON "currencies" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for app_data table
CREATE POLICY "Users can view own app_data"
  ON "app_data" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own app_data"
  ON "app_data" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own app_data"
  ON "app_data" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own app_data"
  ON "app_data" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);

-- RLS Policies for progress table
CREATE POLICY "Users can view own progress"
  ON "progress" FOR SELECT
  TO authenticated
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own progress"
  ON "progress" FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own progress"
  ON "progress" FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own progress"
  ON "progress" FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id::text);