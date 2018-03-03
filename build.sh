---
# Copyright 2018, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in witing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euvo

source bootstrap.sh

ansible deploy_hosts \
        -i ${DEPLOY_INVENTORY:-"playbooks/inventory"} \
        -m pip \
        -a "name=netaddr"

ansible-playbook -vv \
                 -i ${DEPLOY_INVENTORY:-"playbooks/inventory"} \
                 -e setup_host=${SETUP_HOST:-"true"} \
                 -e setup_pxeboot=${SETUP_PXEBOOT:-"true"} \
                 -e setup_dhcpd=${SETUP_DHCPD:-"true"} \
                 -e default_ubuntu_mirror_hostname=${DEFAULT_MIRROR_HOSTNAME:-"archive.ubuntu.com"} \
                 -e default_ubuntu_mirror_directory=${DEFAULT_MIRROR_DIR:-"/ubuntu"} \
                 -e @configs/deployment.yml \
                 -e provision_environment=${PROVISION_ENVIRONMENT:-"false"} \
                 -e configure_raid=${CONFIGURE_RAID:-"false"} \
                 -e update_firmware=${UPDATE_FIRMWARE:-"false"} \
                 --force-handlers \
                 playbooks/site.yml
