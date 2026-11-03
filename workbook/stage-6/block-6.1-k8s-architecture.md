# Блок 6.1 — Архітектура Kubernetes

**Час:** ~6 год · **Передумови:** Етап 5

## Навіщо це зараз
Спочатку треба довести в ADR-019, що кластер узагалі потрібен. Потім розібратися, як він влаштований, інакше кожна проблема виглядатиме магією.

## Теорія
- Control plane (API server, etcd, scheduler, controller manager) і worker nodes (kubelet, kube-proxy, containerd).
- Reconciliation loop: та сама ідея, що в Terraform і Ansible.
- Pods: sidecar і init-контейнери; Deployment і ReplicaSet, rolling update (`maxSurge`, `maxUnavailable`); StatefulSet, Job, CronJob.
- Services: ClusterIP, NodePort, LoadBalancer; DNS у кластері; Ingress і Gateway API.
- Namespaces як межа команд; RBAC у кластері з інтеграцією Entra ID.
- Три релізи на рік і приблизно 14 місяців підтримки: оновлення — регулярна робота.

## Завдання
1. Підніми `kind` локально; розгорни в ньому застосунок Deployment + Service.
2. Подивись, що відбувається при `kubectl apply`: знайди в логах control plane свій обʼєкт.
3. Зміни образ у Deployment і простеж rolling update покроково; поясни роль `maxSurge` і `maxUnavailable`.
4. Видали под руками і покажи, хто саме його відновив.
5. Розгорни воркер як окремий Deployment, а періодичну задачу — як CronJob.
6. Налаштуй namespace під кожну команду і RBAC: розробник бачить свій namespace і не може чіпати чужий. Перевір негативно.
7. Заверши ADR-019 з цифрами: скільки коштує кластер проти поточного рішення і що він дає натомість.

## Критерії прийому
- [ ] Застосунок працює в `kind`; rolling update пройдений усвідомлено
- [ ] RBAC перевірений негативним тестом
- [ ] ADR-019 спирається на цифри, а не на «K8s — стандарт»

## Пастки
- `kubectl apply` без ресурсних запитів дає под, який планувальник ставить наосліп.
- Service без відповідних label selectors мовчки не має ендпоінтів.
- CronJob із `concurrencyPolicy: Allow` накопичує паралельні запуски при повільній задачі.

## Підказки
<details><summary>Підказка 1</summary>
`kubectl get events --sort-by=.lastTimestamp` — перше місце, куди дивитись, коли «нічого не відбувається».
</details>
<details><summary>Підказка 2</summary>
Негативний тест RBAC: `kubectl auth can-i delete pods -n other --as=dev@…`.
</details>

## Тест
`prompts/04-quiz.md`, тема: «архітектура кластера, контролери, Services, RBAC», 8 питань.
