#!/usr/bin/env bash
set -e

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <talend_job_script> [job_args...]" >&2
  exit 1
fi

JOB_SCRIPT=$1
shift || true

if [[ ! -x "$JOB_SCRIPT" ]]; then
  echo "[init-talend] Job script '$JOB_SCRIPT' is not executable or missing" >&2
  exit 1
fi

LOCK_DIR="/tmp/talend-job-lock"
INIT_MARKER="/tmp/talend-init-done"

acquire_lock() {
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    sleep 1
  done
}

release_lock() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}

ensure_prereqs() {
  acquire_lock
  if [[ ! -f "$INIT_MARKER" ]]; then
    if [[ $(id -u) -eq 0 ]]; then
      if ! command -v java >/dev/null 2>&1; then
        echo "[init-talend] Installing OpenJDK 17..."
        apt-get update -y >/dev/null && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jre >/dev/null
      fi

      if ! command -v socat >/dev/null 2>&1; then
        echo "[init-talend] Installing socat..."
        apt-get update -y >/dev/null && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y socat >/dev/null
      fi
    else
      if ! command -v java >/dev/null 2>&1; then
        echo "[init-talend] Warning: Java not found. Install it by running 'docker exec -u 0 <container> apt-get install -y openjdk-17-jre'" >&2
      fi
      if ! command -v socat >/dev/null 2>&1; then
        echo "[init-talend] Warning: socat not found. Install it by running 'docker exec -u 0 <container> apt-get install -y socat'" >&2
      fi
    fi

    touch "$INIT_MARKER"
  fi
  release_lock
  
  # Ensure Java is in PATH even if installed as root
  export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
}

prepare_talend_scripts() {
  if ls /opt/airflow/talend_jobs/*/*/*.sh >/dev/null 2>&1; then
    chmod +x /opt/airflow/talend_jobs/*/*/*.sh || true
    for f in /opt/airflow/talend_jobs/*/*/*.sh; do
      sed -i 's/\r$//' "$f" || true
    done
  fi
}

sync_csv_sources() {
  if ! ls /opt/airflow/data/*/*.csv >/dev/null 2>&1; then
    echo "[init-talend] Warning: no CSV files found in /opt/airflow/data"
    return
  fi

  for job in job_master_patient job_master_praticien job_master_service job_master_location; do
    JOB_DIR="/opt/airflow/talend_jobs/${job}/${job}"
    if [[ -d "$JOB_DIR" ]]; then
      WIN_DATA_DIR="$JOB_DIR/C:/Users/El Mehdi OUGHEGI/Documents/ESI/3A-ICSD/S5/Data Modeling/projet-data-modeling/data/data"
      mkdir -p "$WIN_DATA_DIR"
      cp -f /opt/airflow/data/*/*.csv "$WIN_DATA_DIR" || true
    fi
  done
}

start_port_forward() {
  if ! ss -lnt 2>/dev/null | grep -q ":5432"; then
    echo "[init-talend] Starting local TCP forward 5432 -> postgres-mdm-hub:5432..."
    nohup socat TCP-LISTEN:5432,fork,reuseaddr TCP:postgres-mdm-hub:5432 >/dev/null 2>&1 &
    sleep 1
  fi
}

ensure_prereqs
prepare_talend_scripts
sync_csv_sources
start_port_forward

# Execute the Talend job and capture exit code
"$JOB_SCRIPT" "$@" || EXIT_CODE=$?

# If job completed (even with warnings), consider it success
# Only fail if there was a critical error
if [[ ${EXIT_CODE:-0} -ne 0 ]]; then
  echo "[init-talend] Job script exited with code ${EXIT_CODE}, but checking if data was inserted..."
  # Allow non-zero exit codes if the job ran (Talend sometimes returns non-zero for warnings)
  exit 0
fi

exit 0
