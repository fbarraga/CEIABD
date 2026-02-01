.PHONY: help download-cache build up clean deep-clean shell-master

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles para Módulo 2 Simple - Hadoop & Spark Single Node:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Ejemplos de uso:"
	@echo "  make download-cache  # Descargar paquetes al caché central (/downloads)"
	@echo "  make build           # Construir la imagen Docker"
	@echo "  make up              # Levantar el clúster Hadoop"
	@echo "  make test            # Ejecutar test MapReduce"

# Descargar Hadoop y Hive al caché local (acelera reconstrucciones)
download-cache: ## Descargar paquetes al caché central (/downloads)
	@echo "📦 Descargando archivos al caché local..."
	@cd Base && ./download-cache.sh

# Variables
# Autodetección de Docker Compose (V2 "docker compose" o V1 "docker-compose")
DOCKER_COMPOSE := $(shell \
    if docker compose version >/dev/null 2>&1; then echo "docker compose"; \
    elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; \
    else echo "docker compose"; fi)

# Construir las imágenes
build: ## Construir la imagen Docker
	@echo "🔨 Construyendo imágenes Docker..."
	$(DOCKER_COMPOSE) build

# Levantar el clúster
up: ## Levantar el clúster Hadoop (1 nodo)
	@echo "🚀 Levantando clúster Hadoop (1 nodo)..."
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
	@echo "⚡ Spark Master UI: http://localhost:8080"
	@echo "📓 Jupyter Notebook: http://localhost:8888"
	@echo "📜 Spark History Server: http://localhost:18080"

clean: ## Limpiar contenedores, volúmenes y red
	@echo "🧹 Limpiando contenedores, volúmenes y red del proyecto..."
	$(DOCKER_COMPOSE) down -v
	@echo "✅ Limpieza completada!"
	@echo "💡 Para eliminar también las imágenes usa: make deep-clean"


# Limpieza profunda: elimina ABSOLUTAMENTE TODO (contenedores, volúmenes, imágenes, red y caché)
deep-clean: ## Limpieza profunda (elimina contenedores, volúmenes, imágenes y red)
	@echo "🔥 LIMPIEZA PROFUNDA - Eliminando recursos del proyecto..."
	@echo "⚠️  Esto eliminará:"
	@echo "   - Contenedor del clúster Hadoop (master)"
	@echo "   - Volúmenes de datos del proyecto"
	@echo "   - Imágenes Docker del proyecto"
	@echo "   - Red del clúster"
	@echo "   - Caché de build del proyecto"
	@echo ""
	@read -p "¿Estás seguro? (s/N): " confirm && [ "$$confirm" = "s" ] || [ "$$confirm" = "S" ] || (echo "Operación cancelada" && exit 1)
	@echo ""
	@echo "🗑️  Deteniendo y eliminando contenedores y volúmenes del proyecto..."
	@$(DOCKER_COMPOSE) down -v 2>/dev/null || true
	@echo "🗑️  Eliminando imágenes del proyecto..."
	@docker rmi modulo2-master 2>/dev/null || true
	@echo "🗑️  Eliminando volúmenes del proyecto..."
	@docker volume rm modulo2_master-data 2>/dev/null || true
	@echo "🗑️  Eliminando red del proyecto..."
	@docker network rm modulo2_hadoop-net 2>/dev/null || true
	@echo "🗑️  Limpiando caché de build (solo capas no utilizadas)..."
	@docker buildx prune -f

# Ejecutar test MapReduce
test: ## Ejecutar test MapReduce (word count)
	@echo "🧪 Ejecutando test MapReduce..."
	@cd ejercicios && sh test_docker.sh

# Acceder al shell del master
shell-master: ## Acceder al shell del contenedor como usuario hadoop
	docker exec -it -u hadoop hadoop-master-simple bash
