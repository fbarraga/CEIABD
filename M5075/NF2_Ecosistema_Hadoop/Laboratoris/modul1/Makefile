.PHONY: help download-cache build up clean deep-clean shell-master shell-slave1 shell-slave2

help:
	@echo "Informació de totes les opcions"

# Descarregar Hadoop i Hive a la memòria cau local (accelera reconstruccions)
download-cache:
	@echo "📦 Descarregant fitxers a la memòria cau local..."
	@cd Base && ./download-cache.sh

# Variables
# Autodetecció de Docker Compose (V2 "docker compose" o V1 "docker-compose")
DOCKER_COMPOSE := $(shell \
	if docker compose version >/dev/null 2>&1; then echo "docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; \
	else echo "docker compose"; fi)

# Construir les imatges
build:
	@echo "🔨 Construint imatges Docker..."
	$(DOCKER_COMPOSE) build

# Aixecar el clúster
up:
	@echo "🚀 Aixecant clúster Hadoop (2 nodes)..."
	$(DOCKER_COMPOSE) up -d
	@echo "⏳ Esperant 20 segons perquè els serveis estiguin llestos..."
	@for i in $$(seq 1 20); do \
		printf "\r["; \
		for j in $$(seq 1 20); do \
			if [ $$j -le $$i ]; then printf "█"; else printf "░"; fi; \
		done; \
		printf "] $$i/20s"; \
		sleep 1; \
	done; \
	echo ""
	@echo "✅ Clúster aixecat!"
	@echo "📊 NameNode UI: http://localhost:9870"
	@echo "📊 ResourceManager UI: http://localhost:8088"

clean:
	@echo "🧹 Netejant contenidors, volums i xarxa del projecte..."
	$(DOCKER_COMPOSE) down -v
	@echo "✅ Neteja completada!"
	@echo "💡 Per eliminar també les imatges utilitza: make deep-clean"


# Neteja profunda: elimina ABSOLUTAMENT TOT (contenidors, volums, imatges, xarxa i memòria cau)
deep-clean:
	@echo "🔥 NETEJA PROFUNDA - Eliminant recursos del projecte..."
	@echo "⚠️  Això eliminarà:"
	@echo "   - Contenidors del clúster Hadoop (master, slave1)"
	@echo "   - Volums de dades del projecte"
	@echo "   - Imatges Docker del projecte (modulo1-*)"
	@echo "   - Xarxa del clúster"
	@echo "   - Memòria cau de build del projecte"
	@echo ""
	@read -p "Estàs segur? (s/N): " confirm && [ "$$confirm" = "s" ] || [ "$$confirm" = "S" ] || (echo "Operació cancel·lada" && exit 1)
	@echo ""
	@echo "🗑️  Aturant i eliminant contenidors i volums del projecte..."
	@$(DOCKER_COMPOSE) down -v 2>/dev/null || true
	@echo "🗑️  Eliminant imatges del projecte..."
	@docker rmi modulo1-master modulo1-slave1 2>/dev/null || true
	@echo "🗑️  Eliminant volums del projecte..."
	@docker volume rm modulo1_master-data modulo1_slave1-data 2>/dev/null || true
	@echo "🗑️  Eliminant xarxa del projecte..."
	@docker network rm modulo1_hadoop-net 2>/dev/null || true
	@echo "🗑️  Netejant memòria cau de build (només capes no utilitzades)..."
	@docker build

# Accedir a la shell del master
shell-master:
	docker exec -it -u hadoop hadoop-master bash

# Accedir a la shell de slave1
shell-slave1:
	docker exec -it -u hadoop hadoop-slave1 bash

# Accedir a la shell de slave2
shell-slave2:
	docker exec -it -u hadoop hadoop-slave2 bash
