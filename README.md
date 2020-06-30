# k8s
Here, we will go through the steps of configuring our k8s environment, playing around with the necessary commands and such, then distributing some manifests to our cluster.

## Steps
- install local dependencies
- cloud setup
- enable k8s engine
- create service account
- git and configure
- test cluster connectivity

### install local dependencies
You need [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (cube-control) to manage and operate your k8s cluster from a local machine.
- Mac
```bash
brew install kubernetes-cli
```

You will need [helm](https://github.com/helm/helm) too
- Mac
```bash
brew install kubernetes-helm
```

You should have gcloud on your system as well. This way you can manipulate gcp from the local cli.
- [Mac](https://cloud.google.com/sdk/docs/quickstart-macos)
```bash
brew cask install google-cloud-sdk
```
- [Linux](https://cloud.google.com/sdk/docs/quickstart-linux)/[Ubuntu](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu)
- [Windows](https://cloud.google.com/sdk/docs/quickstart-windows)

### enable k8s engine
- Navigate to K8s Engine in GCP Console
- Enable the K8s API

### create service account
- Navigate to the IAM section
- Navigate to [Service Accounts](https://console.cloud.google.com/projectselector/iam-admin/serviceaccounts?supportedpurview=project&project=&folder=&organizationId=)
- Create a new service account
- Give it admin credentials
- Generate a .json key_file
- Store the .json key_file locally somewhere you can access later

### git and configure
- clone the [repo](https://github.com/kawsark/terraform-gke.git)
- if you don't have terraform, please [download it](https://www.terraform.io/downloads.html) or [build it from source](https://github.com/hashicorp/terraform)
- change into the k8s dir
```bash
cd k8s
```
- read the comments and make the necessary changes
- initialize
```bash
terraform init
```
- plan
```bash
terraform plan
```
- apply
```bash
terraform apply
```
- if you need references:
  - [k8s cluster on gcp](https://www.terraform.io/docs/providers/google/r/container_cluster.html)
  - [google provider](https://www.terraform.io/docs/providers/google/index.html)

### test cluster connectivity
Assuming all went well and we all have k8s clusters on GCP, we should be able to navigate to our cluster from the k8s engine tab from the GCP console. Click on the connect button and copy/paste the gcloud command into your local terminal. Now run
```bash
kubectl get nodes
```
... I bet you see your cluster. If you don't, just let me know.

If all is well then we can move on to the k8sWithIstio directory and dig into the tool.
