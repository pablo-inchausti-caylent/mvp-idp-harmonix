// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as rds from "aws-cdk-lib/aws-rds";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ssm from "aws-cdk-lib/aws-ssm";
import { OPAEnvironmentParams } from "./opa-environment-params";
import { NagSuppressions } from "cdk-nag";

/* eslint-disable @typescript-eslint/no-empty-interface */
export interface RdsConstructProps extends cdk.StackProps {
  readonly opaEnv: OPAEnvironmentParams;
  readonly vpc: cdk.aws_ec2.IVpc;
  readonly kmsKey: cdk.aws_kms.IKey;
  readonly instanceType: ec2.InstanceType;
}

const defaultProps: Partial<RdsConstructProps> = {};

/**
 * Deploys the Rds construct
 * Supports both Aurora (cluster) and regular RDS (single instance)
 */
export class RdsConstruct extends Construct {
  public readonly cluster: rds.DatabaseCluster | rds.DatabaseInstance;

  constructor(parent: Construct, name: string, props: RdsConstructProps) {
    super(parent, name);

    /* eslint-disable @typescript-eslint/no-unused-vars */
    props = { ...defaultProps, ...props };

    const envIdentifier = `${props.opaEnv.prefix.toLowerCase()}${props.opaEnv.envName}`;
    const envPathIdentifier = `/${props.opaEnv.prefix.toLowerCase()}/${props.opaEnv.envName.toLowerCase()}`;

    // Check if we should use Aurora or regular RDS
    const useAurora = process.env.USE_AURORA?.toLowerCase() === 'true';

    if (useAurora) {
      // Aurora PostgreSQL Cluster (more expensive, multi-instance)
      const cluster = new rds.DatabaseCluster(this, `${envIdentifier}db`, {
        engine: rds.DatabaseClusterEngine.auroraPostgres({
          version: rds.AuroraPostgresEngineVersion.VER_16_6,
        }),
        defaultDatabaseName: `${envIdentifier}db`,
        credentials: rds.Credentials.fromGeneratedSecret("postgres", {
          secretName: `${props.opaEnv.prefix.toLowerCase()}-${props.opaEnv.envName}-db-secrets`,
          encryptionKey: props.kmsKey,
        }),
        storageEncryptionKey: props.kmsKey,
        storageEncrypted: true,
        removalPolicy: cdk.RemovalPolicy.DESTROY,
        deletionProtection: false,
        writer: rds.ClusterInstance.provisioned('writer', {
          instanceType: props.instanceType
        }),
        readers: [
          rds.ClusterInstance.provisioned('reader', {
            instanceType: props.instanceType
          }),
        ],
        vpc: props.vpc,
        vpcSubnets: {
          subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
        },
      });

      NagSuppressions.addResourceSuppressions(cluster, [
        { id: "AwsSolutions-SMG4", reason: "RDS credentials changes will need to be coordinated with a restart of the Backstage application and should not be auto-rotated" },
        { id: "AwsSolutions-RDS6", reason: "Backstage application supports username/password and does not need to support IAM authentication for the prototype" },
        { id: "AwsSolutions-RDS10", reason: "Deletion protection intentionally disabled for prototyping so that RDS CFN can be created/destroyed during rapid development" },
      ], true);

      this.cluster = cluster;

      // Save DB endpoint in SSM Param
      const dbParam = new ssm.StringParameter(this, `${envIdentifier}-db-param`, {
        allowedPattern: ".*",
        description: `The DB for OPA Solution: ${props.opaEnv.envName} Environment`,
        parameterName: `${envPathIdentifier}/db`,
        stringValue: cluster.clusterEndpoint.hostname + ":" + cluster.clusterEndpoint.port,
      });

      const secretParam = new ssm.StringParameter(this, `${envIdentifier}-db-secret-param`, {
        allowedPattern: ".*",
        description: `The DB Secret for OPA Solution: ${props.opaEnv.envName} Environment`,
        parameterName: `${envPathIdentifier}/db-secret`,
        stringValue: cluster.secret?.secretName || "",
      });

      new cdk.CfnOutput(this, "DB Param", {
        value: dbParam.parameterName,
      });

      new cdk.CfnOutput(this, "DB Secret Param", {
        value: secretParam.parameterName,
      });

    } else {
      // Regular RDS PostgreSQL Instance (cheaper, single instance)
      const instance = new rds.DatabaseInstance(this, `${envIdentifier}db`, {
        engine: rds.DatabaseInstanceEngine.postgres({
          version: rds.PostgresEngineVersion.VER_16_6,
        }),
        databaseName: `${envIdentifier}db`,
        credentials: rds.Credentials.fromGeneratedSecret("postgres", {
          secretName: `${props.opaEnv.prefix.toLowerCase()}-${props.opaEnv.envName}-db-secrets`,
          encryptionKey: props.kmsKey,
        }),
        storageEncryptionKey: props.kmsKey,
        storageEncrypted: true,
        removalPolicy: cdk.RemovalPolicy.DESTROY,
        deletionProtection: false,
        instanceType: props.instanceType,
        vpc: props.vpc,
        vpcSubnets: {
          subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
        },
        allocatedStorage: 20, // 20 GB minimum for RDS
        maxAllocatedStorage: 100, // Enable storage autoscaling up to 100 GB
        backupRetention: cdk.Duration.days(7),
        multiAz: false, // Single AZ for cost savings
      });

      NagSuppressions.addResourceSuppressions(instance, [
        { id: "AwsSolutions-SMG4", reason: "RDS credentials changes will need to be coordinated with a restart of the Backstage application and should not be auto-rotated" },
        { id: "AwsSolutions-RDS2", reason: "Multi-AZ intentionally disabled for cost savings in dev/test environments" },
        { id: "AwsSolutions-RDS3", reason: "Multi-AZ intentionally disabled for cost savings in dev/test environments" },
        { id: "AwsSolutions-RDS6", reason: "Backstage application supports username/password and does not need to support IAM authentication for the prototype" },
        { id: "AwsSolutions-RDS10", reason: "Deletion protection intentionally disabled for prototyping so that RDS CFN can be created/destroyed during rapid development" },
        { id: "AwsSolutions-RDS11", reason: "Default port 5432 used for PostgreSQL compatibility with Backstage" },
      ], true);

      this.cluster = instance;

      // Save DB endpoint in SSM Param
      const dbParam = new ssm.StringParameter(this, `${envIdentifier}-db-param`, {
        allowedPattern: ".*",
        description: `The DB for OPA Solution: ${props.opaEnv.envName} Environment`,
        parameterName: `${envPathIdentifier}/db`,
        stringValue: instance.instanceEndpoint.hostname + ":" + instance.instanceEndpoint.port,
      });

      const secretParam = new ssm.StringParameter(this, `${envIdentifier}-db-secret-param`, {
        allowedPattern: ".*",
        description: `The DB Secret for OPA Solution: ${props.opaEnv.envName} Environment`,
        parameterName: `${envPathIdentifier}/db-secret`,
        stringValue: instance.secret?.secretName || "",
      });

      new cdk.CfnOutput(this, "DB Param", {
        value: dbParam.parameterName,
      });

      new cdk.CfnOutput(this, "DB Secret Param", {
        value: secretParam.parameterName,
      });
    }
  }
}
