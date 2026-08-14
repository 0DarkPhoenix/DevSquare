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
CREATE TABLE `user` (
    id UUID PRIMARY KEY NOT NULL DEFAULT uuid7(),
    username VARCHAR(40) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
    blocked BOOLEAN NOT NULL DEFAULT false
    deleted BOOLEAN NOT NULL DEFAULT false
)

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON `user`
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();


/* ARTICLE TABLE */
CREATE TABLE article (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    user_id UUID NOT NULL REFERENCES `user`(id),
    title VARCHAR(50) NOT NULL,
    short_description VARCHAR(75) NOT NULL,
    code_blocks TEXT NOT NULL,
    body varchar(2000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    draft boolean NOT NULL DEFAULT true,
    published BOOLEAN NOT NULL DEFAULT false,
    blocked BOOLEAN NOT NULL DEFAULT false,
    blocked_reason VARCHAR(255) DEFAULT NULL,
    CHECK (NOT (draft AND published))
)

CREATE INDEX idx_article_user_id
    ON article (user_id);
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON article
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE OR REPLACE FUNCTION force_unpublish_when_blocked()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.blocked THEN
        NEW.draft := false;
        NEW.published := false;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_blocked_status
BEFORE INSERT OR UPDATE ON article
FOR EACH ROW
EXECUTE FUNCTION force_unpublish_when_blocked();


/* TAG TABLE */
CREATE TABLE tag (
    name VARCHAR(40) PRIMARY KEY NOT NULL 
)

/* ARTICLE_TAG TABLE */
CREATE TABLE article_tag (
    article_id BIGINT NOT NULL REFERENCES article(id),
    tag_name VARCHAR(20) NOT NULL REFERENCES tag(name),
    PRIMARY KEY (article_id, tag_name)
)

CREATE INDEX idx_article_tag_tag_name_article_id
    ON article_tag (tag_name, article_id);

/* LANGUAGE TABLE */
CREATE TABLE language (
    name VARCHAR(40) PRIMARY KEY NOT NULL 
)

/* ARTICLE_LANGUAGE TABLE */
CREATE TABLE article_language (
    article_id BIGINT NOT NULL REFERENCES article(id),
    language_name VARCHAR(20) NOT NULL REFERENCES language(name),
    PRIMARY KEY (article_id, language_name)
)

CREATE INDEX idx_article_language_language_name_article_id
    ON article_language (language_name, article_id);
