# Домашнее задание к занятию "`Введение в виртуализацию. Типы и функции гипервизоров. Обзор рынка вендоров и областей применения`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

Опишите кратко, в чём основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС.

</details>

### Решение:

**Полная (аппаратная) виртуализация.**  
Самый популярный способ виртуализации предполагает использование программного обеспечения, получившего название «гипервизор», суть которого заключается в создании уровня абстракции между виртуальными серверами и базовым аппаратным обеспечением.  
Гипервизор перехватывает команды центрального процессора и служит посредником для доступа к аппаратным контроллерам и периферии. В результате полная виртуализация позволяет установить на виртуальный сервер практически любую операционную систему без каких-либо изменений, причем сама ОС ничего не будет знать о том, что она работает в виртуализованной среде. Основной недостаток данного подхода связан с накладными расходами, которые несет процессор в связи с работой гипервизора. Эти накладные расходы невелики, но ощутимы.  
В полностью виртуализованной среде гипервизор взаимодействует непосредственно с аппаратным обеспечением и серверами в качестве хостовой операционной системы.

**Паравиртуализация.**  
Полная виртуализация предполагает серьезное использование ресурсов процессора, обусловленное наличием гипервизора, управляющего различными виртуальными серверами и обеспечивающего независимость этих серверов друг от друга. Уменьшить эту нагрузку можно, например, модифицировав каждую операционную систему таким образом, чтобы она «знала» о том, что она работает в виртуализованной среде, и могла взаимодействовать с гипервизором.  
Прежде чем операционная система сможет работать в качестве виртуального сервера в гипервизоре, в нее необходимо внести определенные изменения на уровне ядра.  
Преимуществом паравиртуализации является более высокая производительность. Паравиртуализованные серверы, работающие вместе с гипервизором, обеспечивают почти такую же скорость, как невиртуализованные серверы.

**Виртуализации на основе ОС.**  
Существует еще один способ виртуализации — встроенная поддержка виртуальных серверов на уровне операционной системы.  
При виртуализации на уровне операционной системы не существует отдельного слоя гипервизора. Вместо этого сама хостовая операционная система отвечает за разделение аппаратных ресурсов между несколькими виртуальными серверами и поддержку их независимости друг от друга. Отличие этого подхода от других проявляется, прежде всего, в том, что в этом случае все виртуальные серверы должны работать в одной и той же операционной системе (хотя каждый экземпляр имеет свои собственные приложения и регистрационные записи пользователей).  
То, что виртуализация на уровне операционной системы теряет в гибкости, она восполняет за счет производительности, которая близка к производительности невиртуализованных серверов. Кроме того, архитектурой, которая использует одну стандартную ОС для всех виртуальных серверов, намного проще управлять, чем в более гетерогенной средой.


В итоге, основная разница состоит в необходимости модифицировать гостевые ОС:
- При аппаратной виртуализации она не требуется;
- Для паравиртуализации нужна модификация ядра и драйверов;
- При виртуализации средствами ОС, гостевая ОС не имеет собственного ядра, использует ядро хоста.

---

## Задание 2.
<details>
	<summary></summary>
      <br>

Выберите один из вариантов использования организации физических серверов в зависимости от условий использования.

Организация серверов:

- физические сервера,
- паравиртуализация,
- виртуализация уровня ОС.

Условия использования:

- высоконагруженная база данных, чувствительная к отказу;
- различные web-приложения;
- Windows-системы для использования бухгалтерским отделом;
- системы, выполняющие высокопроизводительные расчёты на GPU.

Опишите, почему вы выбрали к каждому целевому использованию такую организацию.

</details>

### Решение:

Для **высоконагруженной базы данных, чувствительной к отказу** лучше использовать физические сервера. От сервера требуется максимум производительности и максимально быстрый отклик СУБД на все запросы. Отказоустойчивость обеспечивается за счет дублирования серверов.

Для **различных web-приложений** лучше использовать виртуализацию на уровне ОС. Виртуализация ОС подходит лучше всего, так свернуть приложение в контейнер и развернуть из него быстрей, чем делать это с виртуальными машинами с полноценной ОС и отдельным ядром.

Для **Windows-систем, которые используются бухгалтерским отделом** можно использовать физические сервера или паравиртуализацию. В первом случае будет выше производительность, а во втором - будет легче поддерживать, копировать, восстанавливать, мигрировать.

Для **систем, выполняющих высокопроизводительные расчёты на GPU** лучше использовать физические сервера. Физические сервера подойдут лучше всего, так как в этом случае удастся получить максимальную производительность.

---

## Задание 3.
<details>
	<summary></summary>
      <br>

Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.

Сценарии:

1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based-инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.
2. Требуется наиболее производительное бесплатное open source-решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.
3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows-инфраструктуры.
4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.

</details>

### Решение:

1. Подойдут Hyper-V, vSphere: они оба хорошо поддерживают виртуальные машины с Windows и Linux, имеют встроенные перечисленные возможности (балансировка, репликация, бекапы) и могут работать в кластере гипервизоров, что необходимо для работы 100 виртуальных машин.

2. Лучше всего подойдёт KVM: open source решение, хорошо поддерживает Windows гостей, имеет возможности по управлению сравнимые с платными гипервизорами.

3. Hyper-V Server, максимально совместим c Windows гостевыми ОС.

4. Docker - можно запустить на подавляющем большинстве дистрибутивов Linux. Сборку и развёртывание контейнеров можно автоматизировать, например, через docker-compose.

---

## Задание 4.
<details>
	<summary></summary>
      <br>

Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.

</details>

### Решение:

- сложность администрирования;
- большой штат инженеров, которые смогут обслуживать обе системы управления виртуализацией;
- сложности с мониторингом;
- повышенный риск отказа и недоступности;
- большая стоимость обслуживания;
- сложности с аппаратным обеспечением (одни фирмы поддерживаю одно, другие - другое. Нужно больше тратиться на резерв, сложно взаимнозаменять аппаратные компоненты).

Для минимизации рисков и проблем:

- в идеале перейти на одну платформу;
- перейти на сервисы облачных провайдеров полностью или частично;
- максимальное автоматизировать развертывание и тестирование инфраструктуры, чтобы она была единая.

Если бы у меня был выбор, то я бы пытался сделать как можно единую среду, для повышения отказоустойчивости и упрощения администрирования. Другой вопрос, что так сделать не всегда возможно, так как в современных реалиях очень часто требуется использовать, например, не только виртуальные машины, но и контейнеры. Таким образом, применение либо гетеродинной, либо гомогенной среды - зависит от ситуации, в каждом случае у каждого подхода будут свои плюсы и минусы.

---