##
# Harmonix Platform Scheduler Lambda
# Start/Stop Harmonix platform services for cost savings
# - RDS database (Backstage catalog)
# - ECS Backstage service tasks
#
# Event parameter: {"action": "stop"} or {"action": "start"}
#
import json
import boto3
import os

# Configuration - can be overridden via environment variables
PLATFORM_PREFIX = os.environ.get('PLATFORM_PREFIX', 'opa-platform')
REGION = os.environ.get('AWS_REGION', 'us-east-1')


def get_harmonix_rds_instances():
    """Get Harmonix platform RDS instances"""
    try:
        rds_client = boto3.client('rds', region_name=REGION)
        response = rds_client.describe_db_instances()

        db_instances = []

        for db in response['DBInstances']:
            db_id = db['DBInstanceIdentifier']
            db_status = db['DBInstanceStatus']

            # Filter for Harmonix platform RDS instances
            if PLATFORM_PREFIX in db_id or 'backstage' in db_id.lower() or 'harmonix' in db_id.lower():
                print(f"Found Harmonix RDS: {db_id} (Status: {db_status})")
                db_instances.append({
                    'id': db_id,
                    'status': db_status
                })

        return db_instances

    except Exception as e:
        print(f"Error getting RDS instances: {e}")
        return []


def get_harmonix_ecs_cluster():
    """Get Harmonix platform ECS cluster and service"""
    try:
        ecs_client = boto3.client('ecs', region_name=REGION)

        # List clusters
        clusters_response = ecs_client.list_clusters()

        for cluster_arn in clusters_response['clusterArns']:
            # Filter for Harmonix platform cluster
            if PLATFORM_PREFIX in cluster_arn or 'backstage' in cluster_arn.lower():
                print(f"Found Harmonix ECS Cluster: {cluster_arn}")

                # List services in this cluster
                services_response = ecs_client.list_services(cluster=cluster_arn)

                for service_arn in services_response['serviceArns']:
                    if 'backstage' in service_arn.lower():
                        print(f"Found Backstage Service: {service_arn}")

                        # Get service details
                        service_details = ecs_client.describe_services(
                            cluster=cluster_arn,
                            services=[service_arn]
                        )

                        if service_details['services']:
                            service = service_details['services'][0]
                            return {
                                'cluster_arn': cluster_arn,
                                'service_arn': service_arn,
                                'service_name': service['serviceName'],
                                'desired_count': service['desiredCount'],
                                'running_count': service['runningCount']
                            }

        return None

    except Exception as e:
        print(f"Error getting ECS cluster/service: {e}")
        return None


def stop_harmonix_rds():
    """Stop Harmonix RDS instances"""
    try:
        rds_client = boto3.client('rds', region_name=REGION)
        db_instances = get_harmonix_rds_instances()

        stopped_count = 0
        for db in db_instances:
            if db['status'] == 'available':
                try:
                    rds_client.stop_db_instance(DBInstanceIdentifier=db['id'])
                    print(f"✓ Stopped RDS: {db['id']}")
                    stopped_count += 1
                except Exception as e:
                    print(f"✗ Error stopping RDS {db['id']}: {e}")
            else:
                print(f"⊘ Skipped RDS {db['id']} (status: {db['status']})")

        if stopped_count == 0:
            print("No RDS instances to stop")

        return stopped_count

    except Exception as e:
        print(f"Error in stop_harmonix_rds: {e}")
        return 0


def start_harmonix_rds():
    """Start Harmonix RDS instances"""
    try:
        rds_client = boto3.client('rds', region_name=REGION)
        db_instances = get_harmonix_rds_instances()

        started_count = 0
        for db in db_instances:
            if db['status'] == 'stopped':
                try:
                    rds_client.start_db_instance(DBInstanceIdentifier=db['id'])
                    print(f"✓ Started RDS: {db['id']}")
                    started_count += 1
                except Exception as e:
                    print(f"✗ Error starting RDS {db['id']}: {e}")
            else:
                print(f"⊘ Skipped RDS {db['id']} (status: {db['status']})")

        if started_count == 0:
            print("No RDS instances to start")

        return started_count

    except Exception as e:
        print(f"Error in start_harmonix_rds: {e}")
        return 0


def stop_harmonix_ecs():
    """Stop Harmonix ECS Backstage service (scale to 0)"""
    try:
        ecs_client = boto3.client('ecs', region_name=REGION)
        service_info = get_harmonix_ecs_cluster()

        if not service_info:
            print("No Harmonix ECS service found")
            return 0

        current_desired = service_info['desired_count']

        if current_desired == 0:
            print(f"⊘ ECS service already stopped (desired: 0)")
            return 0

        # Scale service to 0
        try:
            ecs_client.update_service(
                cluster=service_info['cluster_arn'],
                service=service_info['service_name'],
                desiredCount=0
            )
            print(f"✓ Stopped ECS service (scaled from {current_desired} to 0 tasks)")
            return 1
        except Exception as e:
            print(f"✗ Error stopping ECS service: {e}")
            return 0

    except Exception as e:
        print(f"Error in stop_harmonix_ecs: {e}")
        return 0


def start_harmonix_ecs():
    """Start Harmonix ECS Backstage service (scale to 2)"""
    try:
        ecs_client = boto3.client('ecs', region_name=REGION)
        service_info = get_harmonix_ecs_cluster()

        if not service_info:
            print("No Harmonix ECS service found")
            return 0

        current_desired = service_info['desired_count']
        target_count = 2  # Default to 2 tasks

        if current_desired >= target_count:
            print(f"⊘ ECS service already running (desired: {current_desired})")
            return 0

        # Scale service to 2
        try:
            ecs_client.update_service(
                cluster=service_info['cluster_arn'],
                service=service_info['service_name'],
                desiredCount=target_count
            )
            print(f"✓ Started ECS service (scaled from {current_desired} to {target_count} tasks)")
            return 1
        except Exception as e:
            print(f"✗ Error starting ECS service: {e}")
            return 0

    except Exception as e:
        print(f"Error in start_harmonix_ecs: {e}")
        return 0


def lambda_handler(event, context):
    """
    Main handler for Harmonix platform scheduler
    Event format: {"action": "stop"} or {"action": "start"}
    """
    try:
        action = event.get('action', 'stop').lower()

        print(f"╔══════════════════════════════════════════════╗")
        print(f"║ Harmonix Platform Scheduler                 ║")
        print(f"║ Action: {action.upper():36} ║")
        print(f"║ Region: {REGION:36} ║")
        print(f"╚══════════════════════════════════════════════╝")

        rds_count = 0
        ecs_count = 0

        if action == 'stop':
            print("\n🛑 STOPPING Harmonix Platform Services...")
            # Stop in order: ECS first (to close DB connections), then RDS
            ecs_count = stop_harmonix_ecs()
            # Wait a moment for connections to close
            import time
            time.sleep(5)
            rds_count = stop_harmonix_rds()

        elif action == 'start':
            print("\n▶️  STARTING Harmonix Platform Services...")
            # Start in order: RDS first (database must be available), then ECS
            rds_count = start_harmonix_rds()
            # Wait for RDS to be available (it takes ~2-3 minutes to start)
            # ECS will retry connections automatically
            ecs_count = start_harmonix_ecs()

        else:
            return {
                'statusCode': 400,
                'body': json.dumps(f"Invalid action: {action}. Must be 'start' or 'stop'")
            }

        response = {
            'action': action,
            'rds_instances_processed': rds_count,
            'ecs_services_processed': ecs_count,
            'status': 'success'
        }

        print(f"\n✅ Action '{action}' completed successfully")
        print(f"   - RDS instances: {rds_count}")
        print(f"   - ECS services: {ecs_count}")

        return {
            'statusCode': 200,
            'body': json.dumps(response)
        }

    except Exception as e:
        error_msg = f"Encountered exception: {e}"
        print(f"\n❌ ERROR: {error_msg}")

        return {
            'statusCode': 500,
            'body': json.dumps({
                'status': 'error',
                'message': error_msg
            })
        }
