#!/usr/bin/env python3
import json
import sys
import os
import glob

config_dir = "/opt/airflow/dag_generated_configs"
if len(sys.argv) > 1:
    config_dir = sys.argv[1]

for config_file in glob.glob(os.path.join(config_dir, "*.json")):
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        source_type = config.get("sourceConfig", {}).get("config", {}).get("type", "unknown")
        
        if "Postgres" in source_type or source_type == "Postgres":
            print(f"POSTGRES_CONFIG={config_file}")
            print(f"TYPE={source_type}")
            sys.exit(0)
    except Exception as e:
        continue

print("NOT_FOUND")
sys.exit(1)

