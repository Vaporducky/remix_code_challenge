import subprocess
import sys


def execute_script(script_path, common_path, log_file):
    try:
        # Log the command execution
        print(f"[INFO] Starting execution of {script_path}...")

        result = subprocess.run(
            ['bash', 'code/common/bash/execute_python.sh', '--script', script_path, '--common', common_path],
            stdout=open(log_file, 'a'),
            stderr=subprocess.STDOUT
        )

        # Check if the process was successful
        if result.returncode != 0:
            print(f"[ERROR] Python script execution failed. Check the log file: {log_file}")
            sys.exit(1)

        print(f"[INFO] Python script executed successfully. Log file: {log_file}")

    except Exception as e:
        print(f"[ERROR] An error occurred: {str(e)}")
        sys.exit(1)


if __name__ == '__main__':
    # Parameters (could be passed as arguments)
    script_path = "code/pipelines/source_to_seed/source_to_seed_entrypoint.py"
    common_path = "code/common"
    log_file = "logs/execution.log"

    execute_script(script_path, common_path, log_file)
