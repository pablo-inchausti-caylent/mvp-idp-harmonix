##
# Start/Stop EC2 instances on schedule
# - Stops EC2 instances at 3 AM (cost savings)
#
# Event parameter: {"action": "stop"} or {"action": "start"}
# Default action: "stop" (backwards compatible)
#
# NOTE: RDS and Harmonix platform services are now handled by
#       a separate Lambda function (harmonix-platform-scheduler)
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


# RDS functions removed - now handled by harmonix-platform-scheduler Lambda


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




def lambda_handler(event, context):
    """
    Main handler - supports start/stop actions for EC2 instances only
    Event format: {"action": "stop"} or {"action": "start"}
    """
    try:
        # Get action from event, default to "stop" for backwards compatibility
        action = event.get('action', 'stop').lower()

        print(f"EC2 Scheduler Lambda invoked with action: {action}")
        print("NOTE: RDS and Harmonix platform are handled by harmonix-platform-scheduler")

        regions = ['us-east-1', 'us-east-2', 'us-west-2']

        total_ec2 = 0

        for region in regions:
            print(f"\n--- Processing Region: {region} ---")

            if action == 'stop':
                # Stop EC2 instances (3 AM schedule - cost savings)
                total_ec2 += stop_ec2_instances(region)

            elif action == 'start':
                # Start EC2 instances (if needed)
                total_ec2 += start_ec2_instances(region)

            else:
                return {
                    'statusCode': 400,
                    'body': json.dumps(f"Invalid action: {action}. Must be 'start' or 'stop'")
                }

        code = 200
        response = f"Action '{action}' completed: {total_ec2} EC2 instances processed"
        print(f"\n{response}")

    except Exception as exception:
        code = 500
        response = f"Encountered exception: {exception}"
        print(f"ERROR: {response}")

    return {
        'statusCode': code,
        'body': json.dumps(response)
    }
  