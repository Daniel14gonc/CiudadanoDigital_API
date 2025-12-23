#!/bin/bash
# Actualizar los paquetes
apt-get update -y

# Instalar dependencias para que apt use paquetes por HTTPS
apt-get install -y ca-certificates curl

# Crear el directorio para las llaves de Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Añadir el repositorio oficial de Docker a Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker Engine y Docker Compose
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Iniciar Docker y habilitarlo para que arranque al inicio
systemctl start docker
systemctl enable docker

# ... (instalación de docker previa) ...

# Instalar AWS CLI v2 (Necesario para ECR Login)
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Limpiar archivos de instalación
rm -rf aws awscliv2.zip

# --- CONFIGURACIÓN CRÍTICA DE USUARIO ---
# Añadir el usuario 'ubuntu' al grupo 'docker'
# Esto permite ejecutar comandos docker sin escribir 'sudo' cada vez
usermod -aG docker ubuntu

