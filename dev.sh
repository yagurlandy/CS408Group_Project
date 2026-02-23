#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-}"

die() { echo "✘ $*" >&2; exit 1; }
ok()  { echo "✔ $*"; }

require_file() { [ -f "$1" ] || die "Missing required file: $1"; }

load_env() {
  require_file ".env"
  set -a
  . ./.env
  set +a
  [ -n "${EC2_DEPLOY_HOST:-}" ] || die "EC2_DEPLOY_HOST missing in .env"
  [ -n "${EC2_KEY_NAME:-}" ]    || die "EC2_KEY_NAME missing in .env"
  [ -n "${EC2_DEPLOY_DIR:-}" ]  || die "EC2_DEPLOY_DIR missing in .env"
}

cmd_new() {
  [ ! -f .env ] || die ".env already exists (delete it to recreate)."
  require_file "docker-compose-template.yml"

  echo "EC2 public IP (example: 35.90.193.142):"
  read -r EC2_DEPLOY_HOST
  [ -n "$EC2_DEPLOY_HOST" ] || die "EC2 public IP required."

  echo "EC2 SSH key filename in ~/.ssh (example: aws-AndyLopezmartine.pem):"
  read -r EC2_KEY_NAME
  [ -n "$EC2_KEY_NAME" ] || die "EC2 key name required."
  [ -f "$HOME/.ssh/$EC2_KEY_NAME" ] || die "Key not found at $HOME/.ssh/$EC2_KEY_NAME"

  APP_NAME="$(basename "$PWD" | tr ' ' '-')"
  EC2_DEPLOY_DIR="/home/ubuntu/${APP_NAME}"

  cat > .env <<EOF
EC2_DEPLOY_HOST=${EC2_DEPLOY_HOST}
EC2_KEY_NAME=${EC2_KEY_NAME}
EC2_DEPLOY_DIR=${EC2_DEPLOY_DIR}
EOF

  cp docker-compose-template.yml docker-compose.yml
  ok ".env created"
  ok "docker-compose.yml generated"
  echo "Next: ./dev.sh deploy"
}

cmd_deploy() {
  load_env
  require_file "docker-compose.yml"
  require_file "Dockerfile"

  chmod 600 "$HOME/.ssh/$EC2_KEY_NAME"

  ok "Installing Docker on EC2 (if needed)..."
  ssh -o StrictHostKeyChecking=no -i "$HOME/.ssh/$EC2_KEY_NAME" "ubuntu@${EC2_DEPLOY_HOST}" '
    set -e
    sudo apt update
    sudo apt install -y docker.io docker-compose-plugin rsync
    sudo systemctl enable docker
    sudo systemctl start docker
  '

  ok "Creating deploy directory..."
  ssh -i "$HOME/.ssh/$EC2_KEY_NAME" "ubuntu@${EC2_DEPLOY_HOST}" "mkdir -p '${EC2_DEPLOY_DIR}'"

  ok "Uploading project..."
  rsync -avz -e "ssh -i $HOME/.ssh/$EC2_KEY_NAME" \
    --exclude ".git" --exclude ".github" --exclude "screenshots" --exclude "docs" --exclude ".env" \
    ./ "ubuntu@${EC2_DEPLOY_HOST}:${EC2_DEPLOY_DIR}/"

  ok "Starting containers..."
  ssh -i "$HOME/.ssh/$EC2_KEY_NAME" "ubuntu@${EC2_DEPLOY_HOST}" "
    cd '${EC2_DEPLOY_DIR}' &&
    sudo docker compose up -d --build &&
    sudo docker ps
  "

  ok "Deployment complete"
  echo "Open: http://${EC2_DEPLOY_HOST}/"
}

case "$CMD" in
  new) cmd_new ;;
  deploy) cmd_deploy ;;
  *) echo "Usage: ./dev.sh new | ./dev.sh deploy" ; exit 1 ;;
esac