##
# Start/Stop EC2 instances and RDS databases on schedule
# - Stops EC2 instances at 4 AM (cost savings)
# - Starts RDS at 9 AM, Stops RDS at 10 PM (13 hrs/day)
#
# Event parameter: {"action": "stop"} or {"action": "start"}
# Default action: "stop" (backwards compatible)
#
import json
import boto3

def get_ec2_instances(region, state_filter):
    """Get EC2 instances by state"""
    try:
        ec2_client = boto3.client('ec2', region_name=region)
        response = ec2_client.describe_instances()

        instance_ids = []

        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                instance_id = instance['InstanceId']
                state_name = instance['State']['Name']

                print(f"Region: {region:10} - EC2 Instance [{instance_id}, {state_name}]")

                if state_name in state_filter:
                    instance_ids.append(instance_id)

        return instance_ids

    except Exception as exception:
        print(f"Error in Region {region} get_ec2_instances: {exception}")
        return []


def get_rds_instances(region, state_filter):
    """Get RDS instances by state"""
    try:
        rds_client = boto3.client('rds', region_name=region)
        response = rds_client.describe_db_instances()

        db_instances = []

        for db in response['DBInstances']:
            db_id = db['DBInstanceIdentifier']
            db_status = db['DBInstanceStatus']

            print(f"Region: {region:10} - RDS Instance [{db_id}, {db_status}]")

            if db_status in state_filter:
                db_instances.append(db_id)

        return db_instances

    except Exception as exception:
        print(f"Error in Region {region} get_rds_instances: {exception}")
        return []


def stop_ec2_instances(region):
    """Stop all running EC2 instances"""
    try:
        ec2_client = boto3.client('ec2', region_name=region)
        instance_ids = get_ec2_instances(region, ['running', 'pending'])

        if instance_ids:
            ec2_client.stop_instances(InstanceIds=instance_ids)
            print(f"Region {region} ::: Stopped EC2 instances {instance_ids}")
            return len(instance_ids)
        else:
            print(f"Region {region} ::: No EC2 instances to stop")
            return 0

    except Exception as exception:
        print(f"Error stopping EC2 in region {region}: {exception}")
        return 0


def start_ec2_instances(region):
    """Start all stopped EC2 instances"""
    try:
        ec2_client = boto3.client('ec2', region_name=region)
        instance_ids = get_ec2_instances(region, ['stopped'])

        if instance_ids:
            ec2_client.start_instances(InstanceIds=instance_ids)
            print(f"Region {region} ::: Started EC2 instances {instance_ids}")
            return len(instance_ids)
        else:
            print(f"Region {region} ::: No EC2 instances to start")
            return 0

    except Exception as exception:
        print(f"Error starting EC2 in region {region}: {exception}")
        return 0


def stop_rds_instances(region):
    """Stop all available RDS instances"""
    try:
        rds_client = boto3.client('rds', region_name=region)
        db_instances = get_rds_instances(region, ['available'])

        stopped_count = 0
        for db_id in db_instances:
            try:
                rds_client.stop_db_instance(DBInstanceIdentifier=db_id)
                print(f"Region {region} ::: Stopped RDS instance {db_id}")
                stopped_count += 1
            except Exception as e:
                print(f"Error stopping RDS {db_id}: {e}")

        if stopped_count == 0:
            print(f"Region {region} ::: No RDS instances to stop")

        return stopped_count

    except Exception as exception:
        print(f"Error stopping RDS in region {region}: {exception}")
        return 0


def start_rds_instances(region):
    """Start all stopped RDS instances"""
    try:
        rds_client = boto3.client('rds', region_name=region)
        db_instances = get_rds_instances(region, ['stopped'])

        started_count = 0
        for db_id in db_instances:
            try:
                rds_client.start_db_instance(DBInstanceIdentifier=db_id)
                print(f"Region {region} ::: Started RDS instance {db_id}")
                started_count += 1
            except Exception as e:
                print(f"Error starting RDS {db_id}: {e}")

        if started_count == 0:
            print(f"Region {region} ::: No RDS instances to start")

        return started_count

    except Exception as exception:
        print(f"Error starting RDS in region {region}: {exception}")
        return 0


def lambda_handler(event, context):
    """
    Main handler - supports start/stop actions
    Event format: {"action": "stop"} or {"action": "start"}
    """
    try:
        # Get action from event, default to "stop" for backwards compatibility
        action = event.get('action', 'stop').lower()

        print(f"Lambda invoked with action: {action}")

        regions = ['us-east-1', 'us-east-2', 'us-west-2']

        total_ec2 = 0
        total_rds = 0

        for region in regions:
            print(f"\n--- Processing Region: {region} ---")

            if action == 'stop':
                # Stop EC2 instances (4 AM schedule - cost savings)
                total_ec2 += stop_ec2_instances(region)
                # Stop RDS instances (10 PM schedule - cost savings)
                total_rds += stop_rds_instances(region)

            elif action == 'start':
                # Start RDS instances (9 AM schedule)
                total_rds += start_rds_instances(region)
                # Note: EC2 instances stay stopped (no auto-start)

            else:
                return {
                    'statusCode': 400,
                    'body': json.dumps(f"Invalid action: {action}. Must be 'start' or 'stop'")
                }

        code = 200
        response = f"Action '{action}' completed: {total_ec2} EC2, {total_rds} RDS instances processed"
        print(f"\n{response}")

    except Exception as exception:
        code = 500
        response = f"Encountered exception: {exception}"
        print(f"ERROR: {response}")

    return {
        'statusCode': code,
        'body': json.dumps(response)
    }
  