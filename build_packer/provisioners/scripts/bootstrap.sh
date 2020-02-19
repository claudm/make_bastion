#!/bin/bash
set -ex

# Add EPEL repository
sudo yum -y install  epel-release
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo tee /etc/yum.repos.d/vscode.repo  << 'eof' > /dev/null 2>&1
[vscode]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
eof
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo yum -y  groupinstall xfce 
sudo yum -y install xrdp tigervnc-server vim docker-ce xorgxrdp socat epel-release code dnsmasq lsof jq
#sudo sed -i 's/port=3389/port=8080/g' /etc/xrdp/xrdp.ini
sudo sed -i -e '/\[Xorg\]/,+7 s/#//' -e '/\[Xvnc\]/,+10 s/^/#/' /etc/xrdp/xrdp.ini
sudo bash -c 'echo PREFERRED=/usr/bin/xfce4-session > /etc/sysconfig/desktop'
sudo mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml 
sudo tee /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml  << 'eof' > /dev/null 2>&1 
<?xml version="1.0" encoding="UTF-8"?>
<channel name="keyboard-layout" version="1.0">
  <property name="Default" type="empty">
    <property name="XkbDisable" type="bool" value="false"/>
    <property name="XkbLayout" type="string" value="br"/>
  </property>
</channel>
eof

sudo yum -y install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /sbin/kubectl
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.3.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /sbin/ && rm minikube

sudo systemctl enable xrdp.service
sudo systemctl enable docker.service

cd  /etc/skel/
sudo tee install.sh  << 'EOF' > /dev/null 2>&1

sudo minikube start --vm-driver=none
kubectl -n kube-system get configmap coredns -o yaml | grep -v loop | kubectl apply -f -
kubectl -n kube-system delete pod -l k8s-app=kube-dns

sudo rm -rf /$USER/.minikube $HOME/.kube && sudo cp -r  /root/.kube $HOME/ && \

sudo chown $USER $HOME/.kube -R && sudo cp -r  /root/.minikube $HOME/ && \

sudo chown $USER $HOME/.minikube -R && sed -i 's@/root@'"$HOME"'@' ~/.kube/config

kubectl create clusterrolebinding kube-system-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

kubectl --namespace kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller --clusterrole=cluster-admin  --serviceaccount=kube-system:tiller

helm init --wait --service-account tiller

helm repo update

DOMAIN=tst.example.com.br

helm install stable/traefik --name traefik --set dashboard.enabled=true,serviceType=NodePort,dashboard.domain=dashboard.traefik.$DOMAIN,rbac.enabled=true  --namespace kube-system

kubectl apply -f - << eof
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name:  kubernetes-dashboard
  namespace: kube-system
spec:
  rules:
  - host: dashboard.$DOMAIN
    http:
      paths:
      - backend:
          serviceName: kubernetes-dashboard
          servicePort: 80
        path: /
eof

TRAEFIK_IP=$(kubectl get services -n kube-system traefik -o json | jq .spec.clusterIP -r)
echo "address=/$DOMAIN/$TRAEFIK_IP" |sudo  tee  /etc/dnsmasq.d/k8s.local
sudo  sed -i  '/search/a nameserver 127.0.0.1' /etc/resolv.conf 
sudo systemctl restart dnsmasq
sudo minikube addons enable metrics-server
sudo minikube addons enable registry
sudo minikube dashboard
#execute o comando abaixo minikube addons configure registry-creds
# minikube addons configure registry-creds
# sudo minikube addons enable registry-creds
EOF

