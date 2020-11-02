# Overview

This repository contains scripts helpful for the deployment of Tetration-V on VMware vCenter. It is very important that you put properly formatted values into the `settings.json` file. Do not alter any of the JSON keys and do not add any additional keys.

Tetration 3.X contains three additional settings not used by Tetration 2.X. Be sure to use the right version of the settings file.

# Steps for deploying
1. Start with a clean cluster. Be careful if using a script to delete an older deployment.
2. Rename `tet2.json` (for Tetration 2.X) or `tet3.json` (for Tetration 3.X) to `settings.json` and make sure the values in that file reflect your environment. You will run two different scripts that pull their variables from this file.
2. Run `Deploy-OrchestratorOva.ps1` keeping in mind that it pulls settings from two locations (from the body of the script itself and from `settings.json`).
3. Browse to `http://[ORCHESTRATOR_IP]:9000/upload` to upload the adhoc and mother RPMs manually. This is a slow process. Your browser will redirect automatically to the site survey.
4. When you are redirected to the site survey, run `Fill-TetVWebForm.ps1` instead of completing the form manually. You should see a status code of `200`.
5. Because you completed the form with PowerShell, your browser will not automatically redirect to the next step (site check). Go to `http://[ORCHESTRATOR_IP]:9000/site/check`
5. When site check completes, enter your validation token received via email.
6. Browse to `http://[ORCHESTRATOR_IP]:9000/run` to view the deployment status.

# Details of each script

## Deploy-OrchestratorOva.ps1

`Deploy-OrchestratorOva.ps1` does not take any command-line arguments. Most of the variables used by this script are pulled from `settings.json` and the rest are defined at the top of the file in the `GLOBALS` section.

This script will:
1) Deploy the OVA with the specified settings
2) Power on the orchestrator-1 OVA

## Fill-TetVWebForm.ps1

The Tetration-V deployment requires completing a web form with many site specific values that should be placed into the `settings.json` file. `Fill-TetVWebForm.ps1` will submit every value in `settings.json` as a POST operation. A few moments after running this script, you should be able to browse to the following URL to watch your deployment status:
```
http://[ORCHESTRATOR_IP]:9000/site/run
```

## Anti-affinity rules

Any time after all the Tetration-V VMs have deployed, you can configure the required anti-affinity rules:

```
ansible-playbook anti-affinity.yml
```

You will have to supply the following variables to ansible either as command-line variables or in a variables file:
* vm_vsphere_host
* vm_vsphere_user
* vm_vsphere_password
* vm_vsphere_datacenter
* vm_vsphere_cluster
