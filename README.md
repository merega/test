Протестировано на ОС Debian 12 bookworm \
minikube version: v1.37.0

Установка minikube:
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
```

Запуск от root чтобы не тратить время на доступы пользователя:
```minikube start --driver=docker --force```

Запуск ingress для тестирования веб:

minikube addons enable ingress

Добавляем репозиторий kubectl для применения манифестов:
```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
tee /etc/apt/sources.list.d/kubernetes.list
```

Устанавливаем kubectl:
apt-get update\
apt-get install -y kubectl

Переключаем на локальные образы, так как нет времени регистрироваться в реестре:

eval $(minikube docker-env)

Собираем локальный образ:

docker build -t nestjs-redis:test -f Dockerfile .

Создаем namrspace:

kubectl create ns dev-nest

Применяем манифесты:
Секрет
```
kubectl -n dev-nest create secret generic redis-secret --from-literal=REDIS_PASSWORD=N32upgen

kubectl -n dev-nest apply -f k8s/01-configmap.yaml
kubectl -n dev-nest apply -f k8s/03-redis.yaml
kubectl -n dev-nest apply -f k8s/04-app.yaml
kubectl -n dev-nest apply -f k8s/05-hpa.yaml
kubectl -n dev-nest apply -f k8s/06-networkpolicy.yaml
```

Проверяем все ли запущено и смотрим адрес ingress:
```kubectl -n dev-nest get pods,svc,ingress```

Добавляем адрес ingress в /etc/hosts
```echo "ip_ingress nest-redis.local" | tee -a /etc/hosts```

Проверяем сервис:
```curl http://nest-redis.local/redis```

Для пуша образа нужно добавить секреты в github Repository secrets:

REGISTRY
REGISTRY_PASSWORD
REGISTRY_USERNAME



