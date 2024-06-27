#
- Initialiser devcontainers
- Initialiser scaleway cli : `scw init`

## 1 - Terraform backend in Postgres
- `cd 01-tf-backend`
- `tf init`
- `tf plan`
- `tf apply`

- `tf output -raw backend_conn_str`
- Then, in terraform block using
```hcl
backend "pg" {
  schema_name = "backend_state"    
}
```
use `terraform init -backend-config="conn_str=YOUR_CONN_STR"` equals to `backend_conn_str` output (yes, it's not a good idea to store tfstates in db deployed by this terraform module...)

## 2 - K8S Cluster deployment
- `cd 02-tf-kubernetes`
- `tf init -backend-config="conn_str=YOUR_CONN_STR"`
- `tf plan`
- `tf workspace show`
- `tf workspace new staging`
- `tf output -json kubeconfig | jq '.[].config_file' -r > ~/.kube/config`

## 3
- Replace $REGISTRY
  ```
  docker buildx build \
    --push \
    --platform=linux/amd64 \
    --tag=$REGISTRY \
  ```

## 4
- Utilisation de kube-ctx et kube-ns (`k ctx` et `k ns` pour sélectionner les contextes et namespaces par défaut)
- `k get po` pour voir les pods
- `k api-resources` pour voir les ressources disponibles (noms, abréviations, api versions, kind).
- `k create namespace myapp` pour créer un namespace
- Création d'un déployment (deployment.yml):
  ```
  # NAME                                SHORTNAMES                          APIVERSION                             NAMESPACED   KIND
  # deployments                         deploy                              apps/v1                                true         Deployment
  ```
- `k scale deploy --replicas=0` pour redémarrer les pods
- `k get replicaset` pour voir les replicaset
- `kubectl create secret docker-registry registry-secret --docker-server=rg.fr-par.scw.cloud --docker-username=learn_k8s_rrullo_staging --docker-password=$API_TOKEN`
- `k get secret registry-secret -o json | jq '.data.".dockerconfigjson"' -r | base64 -d | jq '.'`
- `k get po`
- `k logs mypod`

- Création d'un service
- `k apply -f service.yml`
- `k get svc`
- `k get ep` (endpoints)
- Remplacement de myapp par myapp2 dans le fichier deployement puis redéploiement (`k apply -f deployment.yml`)
- `k exec -it myapp2-... -- bash`
- S'il n'y a pas curl ni wget => `printf '' >> /dev/tcp/myapp/8080` puis `echo $?`. Si 0 => connexion établie, sinon => erreur.

# 6 - Ingress / Helm
- k create namespace ingress-nginx
- k ns nginx-ingress
```
# helm upgrade --install Release Nom_du_chart
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
```
- `k get pods`
- cd ../04-deploy-app
- `k apply -f ingress.yml`
- `k get ingress`
- `curl -k https://ADDRESS/`

# RBAC
- `cd 04-deploy-app`
- `k apply -f serviceaccount.yml`
- `k apply -f role.yml`
- `k apply -f rolebindings.yml`

# 05 secrets
- `helm repo add external-secrets https://charts.external-secrets.io`
- `helm upgrade --install external-secrets --namespace=external-secrets --create-namespace external-secrets/external-secrets`
- `k ns external-secrets`

Création de l'application dans scaleway :
- tf init -backend-config="conn_str=YOUR_CONN_STR"
- tf plan
- tf apply
Ajout du secret dans k8s :
- k create secret generic external-secrets --from-literal=accessKey=$SCW_ACCESS_KEY --from-literal=secretKey=$SCW_SECRET_KEY -n external-secrets
- k apply -f secretstore.yml
- k get ss
- k apply -f externalsecret.yml
- k get secrets -o json test | jq '.data'

# 7 Observabilité
- `cd 07-observability`
- Création d'un utilisateur grafana. https://console.scaleway.com/cockpit/users
- Création de 2 datasources externes : 1 type metrics 1 type logs. https://console.scaleway.com/cockpit/dataSource
- `Création d'un token avec les permissions push metrics et push logs`
- `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
- `helm upgrade --install prometheus prometheus-community/prometheus --values prometheus.values.yaml --namespace prometheus --create-namespace`
- `cd 03-image-build`
- modification de l'index.js pour exposer les metrics prometheus
  ```
  const client = require('prom-client');
  const collectDefaultMetrics = client.collectDefaultMetrics;
  const Registry = client.Registry;
  const register = new Registry();
  collectDefaultMetrics({ register });
  
  // Endpoint to expose the metrics
  app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  });
  ```
- `docker buildx build --push --platform=linux/amd64 --tag=$REGISTRY .`
- `modification du tag de l'image dans deployment.yml`
- `k ns myapp`
- `k apply -f deployment`
- Pour les logs:
- `cd 07-observability`
- `helm repo add grafana https://grafana.github.io/helm-charts`
- `helm upgrade --install promtail grafana/promtail --values promtail.values.yaml --namespace promtail --create-namespace`