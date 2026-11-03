# Блок 4.5 — Мережа в хмарі

**Час:** ~6 год · **Передумови:** 4.3

## Навіщо це зараз
Private-by-default — це вимога етапу. Заразом тут ти вперше зустрінеш зміну 2026 року: нові VNet більше не мають виходу в інтернет за замовчуванням.

## Теорія
- VNet, підмережі, route tables, peering; NSG: пріоритети, напрямок, привʼязка до subnet чи NIC, service tags.
- Private endpoints і Private DNS zones — найчастіше ламається саме DNS.
- VNet integration для App Service.
- Azure Load Balancer (L4) проти Application Gateway (L7 і WAF) проти Front Door.
- Default outbound access: з 31 березня 2026 нові VNet приватні, потрібен явний NAT Gateway чи публічний IP.
- Azure DNS: зони, записи, делегування домену з Етапу 1.

## Завдання
1. Опиши VNet із підмережами під застосунок, БД і майбутній кластер; адресний простір з запасом (ADR-015).
2. Налаштуй NSG за принципом deny-by-default; дозволь лише потрібне, пріоритети опиши в коментарях.
3. Створи private endpoint для БД і Key Vault; перевір `nslookup` зсередини і ззовні.
4. Зроби так, щоб VM без публічного IP мала вихід в інтернет через NAT Gateway; перевір `apt update`.
5. Відтвори ситуацію без NAT: покажи, як саме виглядає помилка, і запиши в нотатки.
6. Постав Application Gateway або Front Door перед застосунком; поясни в ADR, навіщо він тобі і скільки коштує.
7. Делегуй домен в Azure DNS або лиши в зовнішнього реєстратора; аргументуй вибір.

## Критерії прийому
- [ ] Приватні endpoints працюють; ззовні БД недоступна
- [ ] NAT Gateway налаштований; VM оновлює пакети
- [ ] NSG-правила прокоментовані, deny-by-default
- [ ] Адресний простір задокументований із запасом під Етап 6

## Пастки
- Private endpoint без Private DNS zone дає резолв у публічну адресу — і трафік іде повз.
- Підмережа під AKS з Azure CNI без overlay зʼїдає IP на кожен под.
- NSG на NIC і на subnet перекриваються; ефективні правила дивись через `az network nic list-effective-nsg`.
- Front Door і Application Gateway разом без потреби подвоюють ціну і затримку.

## Підказки
<details><summary>Підказка 1</summary>
Перевіряй DNS саме з тієї машини, яка ходить у сервіс, а не з ноутбука: приватна зона видима лише всередині VNet.
</details>
<details><summary>Підказка 2</summary>
`az network watcher test-ip-flow` швидко каже, яке правило NSG блокує конкретний потік.
</details>

## Тест
`prompts/04-quiz.md`, тема: «VNet, NSG, private endpoints, egress», 8 питань.
