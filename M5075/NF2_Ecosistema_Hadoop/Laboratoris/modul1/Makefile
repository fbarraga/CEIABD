.PHONY: help download-cache build up clean deep-clean shell-master shell-slave1 shell-slave2

help:
	@echo "Información de todas las opciones"

# Descargar Hadoop y Hive al caché local (acelera reconstrucciones)
download-cache:
	@echo "📦 Descargando archivos al caché local..."
	@cd Base && ./download-cache.sh

# Variables
# Autodetección de Docker Compose (V2 "docker compose" o V1 "docker-compose")
DOCKER_COMPOSE := $(shell \
	if docker compose version >/dev/null 2>&1; then echo "docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; \
	else echo "docker compose"; fi)

# Construir las imágenes
build:
	@echo "🔨 Construyendo imágenes Docker..."
	$(DOCKER_COMPOSE) build

# Levantar el clúster
up:
	@echo "🚀 Levantando clúster Hadoop (2 nodos)..."
	$(DOCKER_COMPOSE) up -d
	@echo "⏳ Esperando 20 segundos a que los servicios estén listos..."
	@for i in $$(seq 1 20); do \
		printf "\r["; \
		for j in $$(seq 1 20); do \
			if [ $$j -le $$i ]; then printf "█"; else printf "░"; fi; \
		done; \
		printf "] $$i/20s"; \
		sleep 1; \
	done; \
	echo ""
	@echo "✅ Clúster levantado!"
	@echo "📊 NameNode UI: http://localhost:9870"
	@echo "📊 ResourceManager UI: http://localhost:8088"

clean:
	@echo "🧹 Limpiando contenedores, volúmenes y red del proyecto..."
	$(DOCKER_COMPOSE) down -v
	@echo "✅ Limpieza completada!"
	@echo "💡 Para eliminar también las imágenes usa: make deep-clean"


# Limpieza profunda: elimina ABSOLUTAMENTE TODO (contenedores, volúmenes, imágenes, red y caché)
deep-clean:
	@echo "🔥 LIMPIEZA PROFUNDA - Eliminando recursos del proyecto..."
	@echo "⚠️  Esto eliminará:"
	@echo "   - Contenedores del clúster Hadoop (master, slave1)"
	@echo "   - Volúmenes de datos del proyecto"
	@echo "   - Imágenes Docker del proyecto (modulo1-*)"
	@echo "   - Red del clúster"
	@echo "   - Caché de build del proyecto"
	@echo ""
	@read -p "¿Estás seguro? (s/N): " confirm && [ "$$confirm" = "s" ] || [ "$$confirm" = "S" ] || (echo "Operación cancelada" && exit 1)
	@echo ""
	@echo "🗑️  Deteniendo y eliminando contenedores y volúmenes del proyecto..."
	@$(DOCKER_COMPOSE) down -v 2>/dev/null || true
	@echo "🗑️  Eliminando imágenes del proyecto..."
	@docker rmi modulo1-master modulo1-slave1 2>/dev/null || true
	@echo "🗑️  Eliminando volúmenes del proyecto..."
	@docker volume rm modulo1_master-data modulo1_slave1-data 2>/dev/null || true
	@echo "🗑️  Eliminando red del proyecto..."
	@docker network rm modulo1_hadoop-net 2>/dev/null || true
	@echo "🗑️  Limpiando caché de build (solo capas no utilizadas)..."
	@docker build

# Acceder al shell del master
shell-master:
	docker exec -it -u hadoop hadoop-master bash

# Acceder al shell de slave1
shell-slave1:
	docker exec -it -u hadoop hadoop-slave1 bash

# Acceder al shell de slave2
shell-slave2:
	docker exec -it -u hadoop hadoop-slave2 bash
