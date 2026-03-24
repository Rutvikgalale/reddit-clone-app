cluster creation using eksctl:
1. 🛠 Steps to Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt install unzip -y
unzip awscliv2.zip

sudo ./aws/install
aws --version

OR
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"


aws configure

2. installation of kubectl:
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

3. installation of eksctl
curl -s https://api.github.com/repos/eksctl-io/eksctl/releases/latest \
| grep "browser_download_url.*linux_amd64.tar.gz" \
| cut -d '"' -f 4 \
| wget -qi -
tar -xzf eksctl_*_linux_amd64.tar.gz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

4. 🚀 Cluster Creation with eksctl
eksctl create cluster \
  --name my-cluster \
  --region ap-south-1 \
  --nodegroup-name linux-nodes \
  --node-type t3.small \


