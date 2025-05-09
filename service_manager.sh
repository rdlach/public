#!/bin/bash

SSH_KEY="ssh-key-Web-Continental-PRD.key"
USER="opc"

# Comandos de parada por IP
declare -A hosts_stop=(
  ["10.0.0.4"]="systemctl stop nginx"
)

# Comandos de subida por IP
declare -A hosts_start=(
  ["172.24.3.45"]="systemctl start nginx"
)

# Ordem de parada
order_stop=(
  172.24.3.45
)

# Ordem de subida (reversa)
order_start=(
  172.24.3.45
)

# Função para parar serviços
parar_servicos() {
  echo "=== Parada dos serviços iniciada ==="
  LOG_FILE="log-parada.txt"
  > "$LOG_FILE"

  for IP in "${order_stop[@]}"; do
    echo "Máquina alvo: $IP"
    read -p "Deseja parar os serviços nesta máquina? (s/n): " resposta
    if [[ "$resposta" != "s" ]]; then
      echo "Pulando $IP..." | tee -a "$LOG_FILE"
      echo "---------------------------------------------" >> "$LOG_FILE"
      continue
    fi

    echo "Parando serviços em $IP..." | tee -a "$LOG_FILE"
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$USER@$IP" "sudo su -c '${hosts_stop[$IP]}'" && \
      echo "✔ Serviços parados em $IP" | tee -a "$LOG_FILE"
    echo "---------------------------------------------" >> "$LOG_FILE"
    sleep 3
  done

  echo
  echo "=== Resumo da parada ==="
  cat "$LOG_FILE"
  echo "====================================="
}

# Função para subir serviços
subir_servicos() {
  echo "=== Subida dos serviços iniciada ==="
  LOG_FILE="log-subida.txt"
  > "$LOG_FILE"

  for IP in "${order_start[@]}"; do
    echo "Máquina alvo: $IP"
    read -p "Deseja iniciar os serviços nesta máquina? (s/n): " resposta
    if [[ "$resposta" != "s" ]]; then
      echo "Pulando $IP..." | tee -a "$LOG_FILE"
      echo "---------------------------------------------" >> "$LOG_FILE"
      continue
    fi

    echo "Iniciando serviços em $IP..." | tee -a "$LOG_FILE"
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$USER@$IP" "sudo su -c '${hosts_start[$IP]}'" && \
      echo "✔ Serviços iniciados em $IP" | tee -a "$LOG_FILE"
    echo "---------------------------------------------" >> "$LOG_FILE"
    sleep 3
  done

  echo
  echo "=== Resumo da subida ==="
  cat "$LOG_FILE"
  echo "====================================="
}

# Menu principal
while true; do
  echo
  echo "===================================="
  echo "     GERENCIADOR DE SERVIÇOS"
  echo "===================================="
  echo "1 - Parar serviços das máquinas"
  echo "2 - Subir serviços das máquinas"
  echo "3 - Sair"
  echo "===================================="
  read -p "Escolha uma opção: " opcao

  case $opcao in
    1) parar_servicos ;;
    2) subir_servicos ;;
    3) echo "Saindo."; exit 0 ;;
    *) echo "Opção inválida." ;;
  esac

  sleep 2
done
