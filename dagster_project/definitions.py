from pathlib import Path
from dagster import job, op, In, Out
import subprocess

@op
def run_dbt_models():
    """Run dbt models"""
    dbt_path = Path(__file__).parent.parent / "ecommerce_analytics"
    result = subprocess.run(
        ["dbt", "run", "--project-dir", str(dbt_path)],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        raise Exception(f"dbt run failed: {result.stderr}")
    return result.stdout

@op
def run_dbt_tests(context, dbt_output):
    """Run dbt tests after models succeed"""
    dbt_path = Path(__file__).parent.parent / "ecommerce_analytics"
    result = subprocess.run(
        ["dbt", "test", "--project-dir", str(dbt_path)],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        raise Exception(f"dbt test failed: {result.stderr}")
    context.log.info(result.stdout)
    return result.stdout

@job
def ecommerce_daily():
    """Daily orchestration: run models, then tests"""
    dbt_output = run_dbt_models()
    run_dbt_tests(dbt_output)