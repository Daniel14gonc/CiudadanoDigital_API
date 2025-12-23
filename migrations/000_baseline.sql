CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE Usuario (
    userId SERIAL PRIMARY KEY,
    email VARCHAR(254) UNIQUE NOT NULL,
    names VARCHAR(100) NOT NULL,
    lastnames VARCHAR(100) NOT NULL,
    birthdate DATE,
    phoneCode VARCHAR(10),
    phoneNumber VARCHAR(12),
    password VARCHAR(128) NOT NULL,
    role VARCHAR(100) DEFAULT 'user', -- 'user', 'admin'
    CONSTRAINT unique_phone UNIQUE (phoneCode, phoneNumber)
);

CREATE TABLE Chat (
    chatId SERIAL PRIMARY KEY,
    userId INT NOT NULL,
    fechaInicio TIMESTAMPTZ DEFAULT NOW(),
    nombre VARCHAR(100),
    CONSTRAINT fk_chat_usuario FOREIGN KEY (userId)
        REFERENCES Usuario(userId)
        ON DELETE CASCADE
);

CREATE TABLE Mensaje (
    messageId SERIAL PRIMARY KEY,
    chatId INT,
    source VARCHAR(20) NOT NULL CHECK (source IN ('user', 'assistant')),
    content TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    assigned BOOLEAN DEFAULT false,
    reference TEXT,
    responseTime BIGINT,
    CONSTRAINT fk_mensaje_chat FOREIGN KEY (chatId)
        REFERENCES Chat(chatId)
        ON DELETE CASCADE
);

CREATE TABLE Sesion (
    refreshId UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userId INT,
    deviceId VARCHAR(255) NOT NULL,
    refreshToken VARCHAR(255) NOT NULL,
    createdAt TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expiresAt TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    revokedAt TIMESTAMP,
    CONSTRAINT fk_sesion_usuario FOREIGN KEY (userId)
        REFERENCES Usuario(userId)
        ON DELETE SET NULL
);

CREATE TABLE CodigoRecuperacion (
    userId INT PRIMARY KEY,
    codeHash VARCHAR(255) NOT NULL,
    createdAt TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expiresAt TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_codRec_usuario FOREIGN KEY (userId)
        REFERENCES Usuario(userId)
        ON DELETE CASCADE
);

CREATE TABLE Categoria (
    categoryId SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE Documento (
    documentId SERIAL PRIMARY KEY,
    userId INT,
    category INT,
    document_url TEXT NOT NULL,
    title VARCHAR(200),
    author VARCHAR(200),
    year INT,
    CONSTRAINT fk_documento_usuario FOREIGN KEY (userId)
        REFERENCES Usuario(userId)
        ON DELETE SET NULL,
    CONSTRAINT fk_documento_categoria FOREIGN KEY (category)
        REFERENCES Categoria(categoryId)
        ON DELETE SET NULL
);

CREATE TABLE ResumenChat (
    userId INT NOT NULL,
    chatId INT NOT NULL,
    content TEXT NOT NULL,
    PRIMARY KEY (userId, chatId),
    CONSTRAINT fk_resChat_usuario FOREIGN KEY (userId)
        REFERENCES Usuario(userId)
        ON DELETE CASCADE,
    CONSTRAINT fk_resChat_chat FOREIGN KEY (chatId)
        REFERENCES Chat(chatId)
        ON DELETE CASCADE
);