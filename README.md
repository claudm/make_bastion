# **Ferramenta para criar servidor bastion pelo packer e terraform**

* **Instalar Dependencias**
  
```
pip install ansible

wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip

unzip terraform*

mv terraform /usr/local/bin/


wget https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip

unzip packer_1.5.1_linux_amd64.zip

mv packer /usr/local/bin/

rm -f *.zip

```

* **Criar nova imagem ami com o packer(produto da empresa HashiCorp, feito exclusivamente para gerar imagens de forma automatizada)**

```
make build
```

* **Criar um servidor a partir do terraform**

```
make create user_name=admin
```

* **Criar usuário

```
make user

```

* **Verificar ip**

```
make ip
```

* **entrar no servidor por ssh e executar no home do usuario**

```
bash install.sh

```

o script irá solicitar access key ,secret key, reguion e account id da ecr , os registro para os os outros registry podem ser ignorados  

```
export ISTIO_VERSION="1.3.5"

curl -L https://git.io/getLatestIstio | sh – 

sudo cp istio-$ISTIO_VERSION/bin/istioctl /bin/

helm repo add istio.io https://storage.googleapis.com/istio-release/releases/$ISTIO_VERSION/charts/

helm install --name istio-init --wait  --namespace istio-system istio.io/istio-init

kubectl config set-context --current --namespace=istio-system

```


* **verificar dependencias(o comando abaixo tem que retornar 23)**


```
kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l

```

* **Instalação basica do Istio**
 
```
helm install --name istio istio.io/istio  --namespace istio-system
```

* **Adicionar repositorio example**

```
helm repo add example-hmg --username admin  --password "'?X/xz.mg3,>nE-5" https://harbor.example.com.br/chartrepo/example-hmg
```

* **criar namespace web**

```
kubectl create ns web
kubectl config set-context --current --namespace=web
```

* **instalar pacote**
```
helm install --name example-hmg example/example-hmg
```




