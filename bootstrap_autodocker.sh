#!/usr/bin/env bash

set -euo pipefail

install_root="${1:-${HOME}}"
autodocker_dir="${install_root}/AUTOdocker"
project_dir="${install_root}/fitness-movement"
compose_file="${project_dir}/docker-compose.yml"

autodocker_url="https://github.com/rhparker/AUTOdocker.git"
project_url="https://github.com/Tristan-Kolla/fitness-movement.git"

clone_if_missing() {
    repo_url="$1"
    destination="$2"

    if [ -d "${destination}/.git" ]; then
        echo "Using existing repository: ${destination}"
    elif [ -e "${destination}" ]; then
        echo "Error: ${destination} exists but is not a Git repository." >&2
        exit 1
    else
        git clone "${repo_url}" "${destination}"
    fi
}

command -v git >/dev/null 2>&1 || {
    echo "Error: Git is not installed." >&2
    exit 1
}

command -v docker >/dev/null 2>&1 || {
    echo "Error: Docker Desktop is not installed." >&2
    exit 1
}

mkdir -p "${install_root}"

if ! docker info >/dev/null 2>&1; then
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "Starting Docker Desktop..."
        open -a Docker
    else
        echo "Start Docker, then run this script again." >&2
        exit 1
    fi
fi

clone_if_missing "${autodocker_url}" "${autodocker_dir}"
clone_if_missing "${project_url}" "${project_dir}"

case "$(uname -m)" in
    arm64 | aarch64)
        docker_image="rhparker/auto:arm"
        docker_platform="linux/arm64"
        ;;
    x86_64 | amd64)
        docker_image="rhparker/auto:latest"
        docker_platform="linux/amd64"
        ;;
    *)
        echo "Error: unsupported processor architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

{
    echo "services:"
    echo "  auto:"
    echo "    image: ${docker_image}"
    echo "    platform: ${docker_platform}"
    echo "    working_dir: /auto/workspace"
    echo "    volumes:"
    echo "      - .:/auto/workspace"
    echo "    ports:"
    echo '      - "8888:8888"'
} >"${compose_file}"

echo "Waiting for Docker Desktop..."
attempt=0
until docker info >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "${attempt}" -ge 90 ]; then
        echo "Error: Docker Desktop did not become ready within three minutes." >&2
        exit 1
    fi
    sleep 2
done

echo "Starting AUTOdocker with ${project_dir} mounted as /auto/workspace..."
docker compose -f "${compose_file}" up -d --force-recreate

echo "Waiting for Jupyter..."
attempt=0
jupyter_url=""
until [ -n "${jupyter_url}" ]; do
    jupyter_url="$(
        docker compose -f "${compose_file}" exec -T auto \
            jupyter notebook list 2>/dev/null |
            awk '/^http:/{print $1; exit}'
    )"

    attempt=$((attempt + 1))
    if [ "${attempt}" -ge 60 ]; then
        echo "Jupyter started, but its URL could not be detected automatically."
        echo "Run: docker compose -f \"${compose_file}\" logs auto"
        exit 1
    fi
    sleep 2
done

jupyter_url="$(
    printf '%s\n' "${jupyter_url}" |
        sed -E 's#http://[^/:]+:8888#http://127.0.0.1:8888#'
)"

echo
echo "Jupyter is ready:"
echo "${jupyter_url}"

if [ "$(uname -s)" = "Darwin" ]; then
    open "${jupyter_url}"
fi
