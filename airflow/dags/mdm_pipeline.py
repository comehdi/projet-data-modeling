from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# Default args
default_args = {
    "owner": "mdm-team",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

BASE_TALEND = "/opt/airflow/talend_jobs"
INIT_SCRIPT = "/opt/airflow/config/init-talend.sh"

JOB_PATIENT = f"{BASE_TALEND}/job_master_patient/job_master_patient/job_master_patient_run.sh"
JOB_PRATICIEN = f"{BASE_TALEND}/job_master_praticien/job_master_praticien/job_master_praticien_run.sh"
JOB_SERVICE = f"{BASE_TALEND}/job_master_service/job_master_service/job_master_service_run.sh"
JOB_LOCATION = f"{BASE_TALEND}/job_master_location/job_master_location/job_master_location_run.sh"

with DAG(
    dag_id="mdm_pipeline",
    default_args=default_args,
    description="MDM pipeline - exécute les 4 jobs Talend en parallèle",
    schedule_interval="0 2 * * *",
    start_date=datetime(2025, 11, 1),
    catchup=False,
    max_active_runs=1,
    tags=["mdm", "talend"],
) as dag:

    patient_task = BashOperator(
        task_id="job_master_patient",
        bash_command="bash -lc '{{ params.init_script }} {{ params.job_patient }}'",
        params={
            "init_script": INIT_SCRIPT,
            "job_patient": JOB_PATIENT,
        },
    )

    praticien_task = BashOperator(
        task_id="job_master_praticien",
        bash_command="bash -lc '{{ params.init_script }} {{ params.job_praticien }}'",
        params={
            "init_script": INIT_SCRIPT,
            "job_praticien": JOB_PRATICIEN,
        },
    )

    service_task = BashOperator(
        task_id="job_master_service",
        bash_command="bash -lc '{{ params.init_script }} {{ params.job_service }}'",
        params={
            "init_script": INIT_SCRIPT,
            "job_service": JOB_SERVICE,
        },
    )

    location_task = BashOperator(
        task_id="job_master_location",
        bash_command="bash -lc '{{ params.init_script }} {{ params.job_location }}'",
        params={
            "init_script": INIT_SCRIPT,
            "job_location": JOB_LOCATION,
        },
    )

    [patient_task, praticien_task, service_task, location_task]
