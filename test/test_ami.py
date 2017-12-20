"""
Script to test an ami.

We use Boto3 for provisioning and managing EC2 instances.
See Boto3 EC2 docs here:
http://boto3.readthedocs.io/en/latest/reference/services/ec2.html?highlight=create_instances#EC2.ServiceResource.create_instances

We use Fabric for simulating sshing into a remote machine and executing comands.
See Fabric docs here:
http://docs.fabfile.org/en/1.12.1/index.html#usage-docs
"""

import boto3
from fabric.api import cd
from fabric.api import env
from fabric.api import run
from fabric.api import settings
from fabric.contrib import files


INSTANCE_TYPES_TO_TEST = {
    'm4.2xlarge': {
        'is_gpu': False
    },
    'p3.2xlarge': {
        'is_gpu': True
    },
}

AUTO_RESPONSE_PROMPTS_DICT = {
    'Are you sure you want to continue connecting (yes/no)? ': 'yes'
}

ec2_connection = boto3.resource('ec2')


def create_instance(ami_id, instance_type):
    """Creates an instance with specified ami id and type.

    Uses boto3.
    """
    ec2_client = boto3.client('ec2')

    created_instances = ec2_connection.create_instances(
        ImageId=ami_id,
        InstanceType=instance_type,
        KeyName='mlpe-common',
        MinCount=1,
        MaxCount=1,
        SubnetId='subnet-7c882925',
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

    # Build and run docker.
    with cd('/home/ubuntu/notebooks/mlpe-gfp-pilot'):
        if is_gpu:
            run('docker build -f docker/Dockerfile.gpu.test -t mlpe-gfp-pilot-gpu-test .')
            run('nvidia-docker run -it -v ~/notebooks:/notebooks mlpe-gfp-pilot-gpu-test')
        else:
            run('docker build -f docker/Dockerfile.cpu.test -t mlpe-gfp-pilot-cpu-test .')
            run('docker run -it -v ~/notebooks:/notebooks mlpe-gfp-pilot-cpu-test')
        assert files.exists('src/python/scripts/TEST_SUCCESS')


if __name__ == '__main__':

    # TODO: Put this under commandline args.
    ami_to_test = 'ami-91146aeb'

    for instance_type, instance_properties in INSTANCE_TYPES_TO_TEST.items():
        print('Testing {ami} with instance type {it}'.format(
                ami=ami_to_test, it=instance_type))
        print('Creating instance ...')
        test_instance = create_instance(ami_to_test, instance_type)

        # Refresh the instance handle so that the public dns is available.
        test_instance = list(ec2_connection.instances.filter(
                InstanceIds=[test_instance.id]))[0]

        print('Testing TensorFlow ...')
        test_tensorflow(
                test_instance.public_dns_name,
                is_gpu=instance_properties['is_gpu'])
        print('...Success. Terminating')
        test_instance.terminate()

        print('Testing {ami} with instance type {it} succeeded.'.format(
                ami=ami_to_test, it=instance_type))


    print('Successfully tested {ami} with instance types {it_list}'.format(
            ami=ami_to_test,
            it_list=INSTANCE_TYPES_TO_TEST.keys()))
