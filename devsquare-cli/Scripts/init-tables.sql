/* GENERAL */
-- Source - https://stackoverflow.com/a/1036010
-- Posted by Charles Ma
-- Retrieved 2026-08-14, License - CC BY-SA 2.5

CREATE OR REPLACE FUNCTION update_timestamp_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now(); 
    RETURN NEW;
END;
$$ language 'plpgsql';

/* USER TABLE */
CREATE TABLE IF NOT EXISTS account (
    id UUID PRIMARY KEY NOT NULL DEFAULT uuidv7(),
    username VARCHAR(40) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_blocked BOOLEAN NOT NULL DEFAULT false,
    is_deleted BOOLEAN NOT NULL DEFAULT false
);

CREATE OR REPLACE TRIGGER set_updated_at 
BEFORE UPDATE ON account
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp_updated_at();


/* ARTICLE TABLE */
CREATE TABLE IF NOT EXISTS article (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    account_id UUID NOT NULL REFERENCES account(id),
    title VARCHAR(50) NOT NULL,
    short_description VARCHAR(75) NOT NULL,
    code_blocks TEXT NOT NULL,
    body varchar(2000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_draft boolean NOT NULL DEFAULT true,
    is_published BOOLEAN NOT NULL DEFAULT false,
    is_blocked BOOLEAN NOT NULL DEFAULT false,
    blocked_reason VARCHAR(255) DEFAULT NULL,
    CHECK (NOT (is_draft AND is_published))
);

CREATE INDEX IF NOT EXISTS idx_article_user_id
    ON article(account_id);
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON article
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp_updated_at();

CREATE OR REPLACE FUNCTION force_unpublish_when_blocked()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_blocked THEN
        NEW.is_draft := false;
        NEW.is_published := false;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER set_blocked_status
BEFORE INSERT OR UPDATE ON article
FOR EACH ROW
EXECUTE FUNCTION force_unpublish_when_blocked();


/* TAG TABLE */
CREATE TABLE IF NOT EXISTS tag (
    name VARCHAR(40) PRIMARY KEY NOT NULL 
);

/* ARTICLE_TAG TABLE */
CREATE TABLE IF NOT EXISTS article_tag (
    article_id BIGINT NOT NULL REFERENCES article(id),
    tag_name VARCHAR(20) NOT NULL REFERENCES tag(name),
    PRIMARY KEY (article_id, tag_name)
);

CREATE INDEX IF NOT EXISTS idx_article_tag_tag_name_article_id
    ON article_tag (tag_name, article_id);

/* LANGUAGE TABLE */
CREATE TABLE IF NOT EXISTS language (
    name VARCHAR(40) PRIMARY KEY NOT NULL 
);

/* ARTICLE_LANGUAGE TABLE */
CREATE TABLE IF NOT EXISTS article_language (
    article_id BIGINT NOT NULL REFERENCES article(id),
    language_name VARCHAR(20) NOT NULL REFERENCES language(name),
    PRIMARY KEY (article_id, language_name)
);

CREATE INDEX idx_article_language_language_name_article_id
    ON article_language (language_name, article_id);

