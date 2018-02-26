"""
Script to test an ami.

We use Boto3 for provisioning and managing EC2 instances.
See Boto3 EC2 docs here:
http://boto3.readthedocs.io/en/latest/reference/services/ec2.html?highlight=create_instances#EC2.ServiceResource.create_instances

We use Fabric for simulating sshing into a remote machine and executing comands.
See Fabric docs here:
http://docs.fabfile.org/en/1.12.1/index.html#usage-docs
"""

import multiprocessing

import boto3
from fabric.api import cd
from fabric.api import env
from fabric.api import run
from fabric.api import settings
from fabric.contrib import files


INSTANCE_TYPES_TO_TEST = {
    ### cpu-only

    'c5.xlarge': {
        'is_gpu': False
    },

    'm4.2xlarge': {
        'is_gpu': False
    },

    ### GPUs

    # older
    'g3.4xlarge': {
        'is_gpu': True
    },

    # latest
    'p3.2xlarge': {
        'is_gpu': True
    },

    'p3.8xlarge': {
        'is_gpu': True
    },
}

AUTO_RESPONSE_PROMPTS_DICT = {
    'Are you sure you want to continue connecting (yes/no)? ': 'yes'
}

TEST_DOCKER_IMAGE_NAME = 'mlpe-gfp-pilot-test-docker-image'


def create_instance(ami_id, instance_type):
    """Creates an instance with specified ami id and type.

    Uses boto3.
    """
    ec2_connection = boto3.resource('ec2')
    ec2_client = boto3.client('ec2')

    created_instances = ec2_connection.create_instances(
        ImageId=ami_id,
        InstanceType=instance_type,
        KeyName='mlpe-common',
        MinCount=1,
        MaxCount=1,
        SubnetId='subnet-7c882925',  # default vpc + us-east-1c
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': 'testing-gpu-packer'
                    }
                ],
            },
        ]
    )

    # Grab handle to created instance.
    test_instance = created_instances[0]

    # Need to block until the instance is initialized.
    # This is a guess at the right signals in the right order to wait for.
    for signal_to_wait_for in [
            'instance_exists', 'instance_running', 'instance_status_ok', 'system_status_ok']:
        waiter = ec2_client.get_waiter(signal_to_wait_for)
        print('Waiting for signal %s ...' % signal_to_wait_for)
        waiter.wait(InstanceIds=[test_instance.id])
        print('...Done.')

    return test_instance


def test_tensorflow(instance_host, is_gpu=True):
    """Tests Tensorflow works on the instance.

    This is the primary test that confirms installation worked.

    Uses Fabric.

    Returns boolean indicating whether test passed.
    """
    # Fab config.
    env.user = 'ubuntu'
    env.host_string = instance_host
    env.use_ssh_config = True
    env.key_filename = '~/.ssh/mlpe-common.pem'

    # Clone mlpe-gfp-pilot repo.
    if not files.exists('~/notebooks'):
        run('mkdir ~/notebooks')
    with cd('~/notebooks'):
        if not files.exists('mlpe-gfp-pilot'):
            with settings(prompts=AUTO_RESPONSE_PROMPTS_DICT):
                run('git clone git@github.com:churchlab/mlpe-gfp-pilot.git')

    # Here we build the docker image and run the test script.
    # The build and run depends on whether we're GPU-enabled or not.

    if is_gpu:
        docker_bin = 'nvidia-docker'
        docker_file = 'docker/Dockerfile.gpu'
        test_script = 'test_gpu.py'
    else:
        docker_bin = 'docker'
        docker_file = 'docker/Dockerfile'
        test_script = 'test_cpu.py'

    with cd('/home/ubuntu/notebooks/mlpe-gfp-pilot'):
        # Update submodules. Required for mlpe lib dep.
        run('git submodule update --init --recursive')

        # The test scripts create this file.
        # Make sure it doesn't exist before we start.
        if files.exists('src/python/scripts/TEST_SUCCESS'):
            run('rm src/python/scripts/TEST_SUCCESS')
        assert not files.exists('src/python/scripts/TEST_SUCCESS')

        # Build the docker
        run(
                'docker build '
                '-f {docker_file} '
                '-t {docker_image} '
                '--build-arg PIP_INSTALL_MLPE_AT_BUILD=1 '
                '.'.format(
                        docker_file=docker_file,
                        docker_image=TEST_DOCKER_IMAGE_NAME))

        # Run it, calling the script.
        run(
                '{docker_bin} run -it -v ~/notebooks:/notebooks '
                '--workdir /notebooks/mlpe-gfp-pilot/src/python/scripts '
                '--entrypoint python '
                '{docker_image_name} '
                '{test_script}'.format(
                        docker_bin=docker_bin,
                        docker_image_name=TEST_DOCKER_IMAGE_NAME,
                        test_script=test_script))

        # This file gets created by the script.
        return files.exists('src/python/scripts/TEST_SUCCESS')


def test_ami_with_instance(ami_to_test, instance_type, instance_properties):
    """Builds and test AMI for the instance type.

    Returns boolean indicating whether test passed.
    """
    ec2_connection = boto3.resource('ec2')

    print('Testing {ami} with instance type {it}'.format(
            ami=ami_to_test, it=instance_type))
    print('Creating instance ...')
    test_instance = create_instance(ami_to_test, instance_type)

    # Refresh the instance handle so that the public dns is available.
    test_instance = list(ec2_connection.instances.filter(
            InstanceIds=[test_instance.id]))[0]

    print('Testing TensorFlow ...')
    did_test_succeed = test_tensorflow(
            test_instance.public_dns_name,
            is_gpu=instance_properties['is_gpu'])
    print('...Success.')

    print('Terminating.')
    test_instance.terminate()

    print('Testing {ami_id} with instance type {it} succeeded.'.format(
            ami_id=ami_to_test, it=instance_type))

    return did_test_succeed


if __name__ == '__main__':
    import sys
    if len(sys.argv) == 2:
        ami_to_test = sys.argv[1]
        print("Running test on {ami_id}".format(ami_id=ami_to_test))
    elif len(sys.argv) > 2:
        print("Too many arguments {}, use only one".format(len(sys.arv) - 1))
        sys.exit(1)
    else:
        print("No ami id provided")
        sys.exit(1)

    # Start test jobs for each intance type in parallel.
    pool = multiprocessing.Pool(processes=len(INSTANCE_TYPES_TO_TEST))
    async_result_list = []
    for instance_type, instance_properties in INSTANCE_TYPES_TO_TEST.items():
        async_result_list.append(pool.apply_async(
                test_ami_with_instance,
                args=(ami_to_test, instance_type, instance_properties)))

    # Block thread until all results complete.
    result_list = [p.get() for p in async_result_list]

    # Print results.
    print('Results for testing {ami_id}:'.format(ami_id=ami_to_test))
    for i, instance_type in enumerate(INSTANCE_TYPES_TO_TEST.keys()):
        result = 'PASS' if result_list[i] else 'FAIL'
        print(instance_type, result)
