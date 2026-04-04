# Профессиональная настройка AI-разработки: Claude Code + Ollama

## Полный гайд для команд и организаций

> **Цель**: Настроить рабочее окружение AI-разработчика так, чтобы каждый проект получал максимум от Claude Code — с правильной структурой, экономией токенов и предсказуемым результатом.

---

## Часть 1. Архитектура конфигурации Claude Code

Claude Code читает настройки из нескольких уровней. Понимание этой иерархии — основа всего.

### 1.1. Иерархия файлов (от общего к частному)

```
~/.claude/settings.json          ← Глобальные настройки (хуки, пермишены, модель)
~/.claude/CLAUDE.md              ← Глобальные правила (работают во всех проектах)
~/.claude/agents/*.md            ← Глобальные субагенты
~/.claude/skills/*/SKILL.md      ← Глобальные скиллы

<project>/.claude/settings.json       ← Проектные хуки и пермишены
<project>/.claude/settings.local.json ← Личные проектные настройки (git-ignored)
<project>/CLAUDE.md                   ← Проектные правила (коммитится в git)
<project>/.claude/agents/*.md         ← Проектные субагенты
<project>/.claude/skills/*/SKILL.md   ← Проектные скиллы
<project>/.claude/commands/*.md       ← Слеш-команды (legacy, теперь = skills)
```

**Правило**: Более специфичный уровень перекрывает общий. Проектный `settings.json` дополняет глобальный. `CLAUDE.md` в подпапке проекта дополняет корневой.

### 1.2. Что куда класть — шпаргалка

| Что | Куда | Почему |
|-----|------|--------|
| "Читай большие файлы чанками" | `~/.claude/CLAUDE.md` | Универсальный паттерн для всех проектов |
| "Используй Bun, не npm" | `<project>/CLAUDE.md` | Специфично для проекта |
| Хук автоформатирования | `<project>/.claude/settings.json` | Зависит от стека проекта |
| Хук уведомлений | `~/.claude/settings.json` | Личное предпочтение |
| "Коммить как Artsiom" | `<project>/CLAUDE.md` | Конвенция проекта |
| Защита `.env` файлов | `~/.claude/settings.json` | Безопасность везде |

---

## Часть 2. Глобальный CLAUDE.md — ваш AI-мозг

Создайте файл `~/.claude/CLAUDE.md` с правилами, которые будут работать в каждом проекте:

```bash
mkdir -p ~/.claude
cat > ~/.claude/CLAUDE.md << 'GLOBAL'
## Работа с файлами

Перед чтением любого файла — сначала узнать размер:
  wc -l <file>

Если файл >500 строк — читать структуру, не весь файл:
  # Python
  grep -n "^def \|^class \|^@" <file>
  # JS/TS
  grep -n "^function \|^const \|^class \|^export" <file>
  # Java
  grep -n "^public \|^private \|^protected \|^class \|^interface" <file>

Затем читать только нужные секции через offset + limit.
Никогда не читать файл целиком если он >800 строк.

## Перед переписыванием файла

1. Выписать ВСЕ единицы из старого файла (функции / классы / роуты)
2. Разбить на три колонки: СОХРАНИТЬ / УДАЛИТЬ / ДОБАВИТЬ
3. Только после этого писать новую версию

Нарушение этого правила приводит к потере кода из оригинала.

## Контекстное бюджетирование

При задаче "переписать большой файл":
1. Фаза АУДИТА: только чтение, никаких правок
   - Извлечь структуру всех файлов (grep)
   - Прочитать все нужные секции
   - Составить список "сохранить / убрать / добавить"
2. Фаза ЗАПИСИ: только после завершения аудита

## Git-workflow

- Делай атомарные коммиты (одна логическая единица на коммит)
- Используй Conventional Commits: feat:, fix:, refactor:, docs:, chore:
- Перед коммитом — всегда проверь что не ломается: run tests / lint
- Никогда не коммить с --no-verify

## Безопасность

- Никогда не выводи содержимое .env, *_KEY, *_SECRET, *_TOKEN в stdout
- Никогда не добавляй секреты в git
- Перед выполнением деструктивных команд (rm -rf, DROP, TRUNCATE) — всегда спрашивай подтверждение

## При компактификации контекста

Всегда сохраняй:
- Список изменённых файлов
- Текущий статус тестов
- Архитектурные решения, принятые в сессии
- Незавершённые задачи
GLOBAL
```

---

## Часть 3. Проектный CLAUDE.md — контекст без чтения кода

Для каждого проекта создайте `CLAUDE.md` в корне. Это самый ценный файл — он заменяет Клоду чтение тысяч строк кода.

### 3.1. Шаблон проектного CLAUDE.md

```markdown
# Project: <Название>

## Обзор
<1-2 предложения что делает проект>

## Стек
- Backend: FastAPI / Python 3.12
- Frontend: Next.js 14 / TypeScript  
- DB: PostgreSQL 16
- Infra: Docker Compose

## Ключевые команды
- `make dev` — запуск в dev-режиме
- `make test` — прогон тестов
- `make lint` — линтинг
- `make migrate` — применить миграции

## Структура проекта
```
src/
  api/          — FastAPI роутеры
  services/     — Бизнес-логика
  models/       — SQLAlchemy модели
  schemas/      — Pydantic схемы
tests/          — Pytest тесты
```

## Конвенции
- Коммиты от имени: Artsiom Butomau <email>
- Ветки: feature/<name> от dev
- Все API-ответы через стандартный envelope: {data, error, meta}
- Логирование: structlog, JSON-формат

## Архитектурные решения
- Парсинг: запуск через parser.py:scrape_by_metro_stations
- Скоринг: analyzer.py:calc_personal_score (5 критериев)
- Фоновые задачи: threading, не celery (пока достаточно)

## Известные проблемы
- WebSocket disconnects при >100 листингах (TODO: пагинация)
```

### 3.2. Schema-файлы — single source of truth

Создайте дополнительные файлы для быстрого понимания системы:

```
docs/
  API.md        — все эндпоинты, параметры, ответы (10-20 строк на роут)
  SCHEMA.md     — таблицы БД с типами и смыслом полей  
  CODE_MAP.md   — фича → файлы → ключевые функции
```

**Пример `docs/CODE_MAP.md`:**

```markdown
## Парсинг
- Запуск: web.py:run_parsing_thread → parser.py:scrape_by_metro_stations
- Прогресс: progress_callback → parsing_state dict
- Сохранение: database.py:bulk_upsert_listings

## Скоринг  
- Триггер: после парсинга → _rescore_listings_background()
- Логика: analyzer.py:calc_personal_score (5 критериев)
```

Клод читает 50 строк CODE_MAP.md вместо 3000 строк кода.

---

## Часть 4. Инвариантные комментарии в коде

Метки для AI прямо в коде — они не удаляются и экономят огромное количество контекста:

```python
# AI-STRUCTURE: entry points are run_parsing_thread() and run_quick_parse_thread()
# AI-SKIP: boilerplate below, not relevant for feature work
# AI-CONTRACT: always call _start_geocoding_background() in finally block
# AI-IMPORTANT: this function is called from 3 places, see CODE_MAP.md
```

Клод может за 5 строк grep-а понять что важно в файле без полного чтения:

```bash
grep -rn "AI-" src/
```

---

## Часть 5. Hooks — детерминистский контроль

Хуки гарантируют поведение, в отличие от инструкций в CLAUDE.md (которые модель может проигнорировать).

### 5.1. Глобальные хуки (`~/.claude/settings.json`)

```json
{
  "model": "sonnet",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm run *)",
      "Bash(make *)",
      "Bash(python -m pytest *)",
      "Bash(grep *)",
      "Bash(wc *)",
      "Bash(find *)",
      "Bash(cat *)",
      "Bash(head *)",
      "Bash(tail *)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(curl * | sh)",
      "Bash(wget * | sh)"
    ]
  },
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude ждёт ввода\" with title \"Claude Code\"'"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/check-file-size.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/security-gate.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/auto-format.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: после компактификации — проверь что помнишь список измененных файлов и текущий статус задачи.'"
          }
        ]
      }
    ]
  }
}
```

### 5.2. Скрипты хуков

**`~/.claude/hooks/check-file-size.sh`** — предупреждение о больших файлах:

```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

LINES=$(wc -l < "$FILE" 2>/dev/null || echo 0)

if [ "$LINES" -gt 500 ]; then
  echo "⚠️ WARNING: $FILE has $LINES lines. Consider using grep to find structure first, then read specific sections with offset/limit." >&2
fi

exit 0
```

**`~/.claude/hooks/security-gate.sh`** — блокировка опасных команд:

```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Блокировать вывод секретов
if echo "$COMMAND" | grep -qiE '(cat|echo|print).*\.(env|pem|key)'; then
  echo "🔒 BLOCKED: потенциальный вывод секретов. Используй grep для проверки наличия ключа, не выводи значение." >&2
  exit 2
fi

# Блокировать деструктивные SQL
if echo "$COMMAND" | grep -qiE '(DROP|TRUNCATE|DELETE FROM) '; then
  echo "🔒 BLOCKED: деструктивная SQL-операция. Подтверди необходимость." >&2
  exit 2
fi

exit 0
```

**`~/.claude/hooks/auto-format.sh`** — автоформатирование после записи:

```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

case "$FILE" in
  *.py)
    command -v black >/dev/null 2>&1 && black -q "$FILE" 2>/dev/null
    command -v ruff >/dev/null 2>&1 && ruff check --fix -q "$FILE" 2>/dev/null
    ;;
  *.ts|*.tsx|*.js|*.jsx)
    command -v prettier >/dev/null 2>&1 && prettier --write "$FILE" 2>/dev/null
    ;;
  *.java)
    command -v google-java-format >/dev/null 2>&1 && google-java-format -i "$FILE" 2>/dev/null
    ;;
esac

exit 0
```

Сделайте скрипты исполняемыми:

```bash
mkdir -p ~/.claude/hooks
chmod +x ~/.claude/hooks/*.sh
```

### 5.3. Хук с локальной Ollama — суммаризация логов

Ключевая фишка: Claude получает компактное summary вместо 10K строк логов.

**`~/.claude/hooks/log-summarizer.sh`:**

```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE" == *.log ]] && [ -f "$FILE" ]; then
  LINES=$(wc -l < "$FILE")
  if [ "$LINES" -gt 500 ]; then
    echo "=== LOG SUMMARY (local model, $LINES lines) ==="
    tail -n 500 "$FILE" | ollama run mistral \
      "Summarize these logs concisely: errors, warnings, key events. JSON format." 2>/dev/null
    echo "=== END SUMMARY, original file too large ==="
    exit 2  # блокируем чтение оригинала — Claude получит summary
  fi
fi

exit 0
```

Добавьте в `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/log-summarizer.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Часть 6. Skills — переиспользуемые воркфлоу

Skills — это инструкции, которые загружаются по запросу (в отличие от CLAUDE.md, который всегда в контексте).

### 6.1. Когда что использовать

| CLAUDE.md | Skills | Субагенты |
|-----------|--------|-----------|
| Всегда в контексте | Загружается по необходимости | Отдельное контекстное окно |
| Конвенции и правила | Специализированные воркфлоу | Тяжёлые задачи (исследование, review) |
| "Всегда делай X" | "Когда нужно Y — делай так" | "Исследуй Z и верни summary" |
| Маленький (экономит токены) | Средний (загружается когда нужен) | Изолированный (не загрязняет основной контекст) |

### 6.2. Создание скилла

```bash
mkdir -p .claude/skills/code-review
```

**`.claude/skills/code-review/SKILL.md`:**

```markdown
---
name: code-review
description: Провести code review текущих изменений с фокусом на безопасность и производительность
allowed-tools: Read Grep Glob Bash
---

## Code Review Workflow

1. Получить diff текущих изменений:
   git diff --cached --stat
   git diff --cached

2. Для каждого изменённого файла проверить:
   - Безопасность: нет ли хардкод секретов, SQL-инъекций, XSS
   - Производительность: N+1 запросы, отсутствие индексов, unbounded queries
   - Стиль: соответствие конвенциям проекта (см. CLAUDE.md)
   - Тесты: покрыты ли новые функции тестами

3. Вывести structured report:
   ## Code Review Report
   ### Critical Issues
   ### Warnings  
   ### Suggestions
   ### Summary: APPROVE / REQUEST CHANGES
```

Теперь можно вызвать: `/code-review` или Claude сам вызовет его при задаче ревью.

### 6.3. Скилл с форком в субагент

```markdown
---
name: deep-research
description: Глубокое исследование кодовой базы с минимальным влиянием на основной контекст
context: fork
agent: Explore
---

Исследуй $ARGUMENTS в кодовой базе:
1. Найди все связанные файлы через grep/glob
2. Прочти ключевые секции
3. Составь карту зависимостей
4. Верни краткий отчёт: что, где, как связано
```

---

## Часть 7. Субагенты — изоляция контекста

Субагенты — отдельные экземпляры Claude с собственным контекстным окном. Основной агент получает только результат, не сырые данные.

### 7.1. Создание субагента

```bash
mkdir -p ~/.claude/agents
```

**`~/.claude/agents/planner.md`:**

```markdown
---
name: planner
description: Архитектурное планирование задач
model: opus
allowed-tools: Read Grep Glob Bash
permissionMode: plan
---

Ты — старший архитектор. При получении задачи:

1. Проанализируй текущую кодовую базу (grep структуру, прочти CLAUDE.md и docs/)
2. Составь план реализации:
   - Какие файлы нужно создать/изменить
   - В каком порядке
   - Какие зависимости между изменениями
   - Какие риски
3. Выведи план в формате numbered steps
4. НЕ пиши код — только планируй
```

**`~/.claude/agents/reviewer.md`:**

```markdown
---
name: reviewer
description: Code review с фокусом на качество и безопасность
model: sonnet
allowed-tools: Read Grep Glob Bash
permissionMode: plan
---

Ты — security-focused code reviewer. При ревью:

1. Прочти diff (git diff или указанные файлы)
2. Проверь:
   - Нет ли утечки секретов
   - Нет ли SQL-инъекций / XSS / SSRF
   - Корректна ли обработка ошибок
   - Есть ли тесты для новой логики
3. Выведи отчёт: Critical / Warning / Info
```

### 7.2. Паттерн "Plan → Code → Review"

Трёхагентный подход, который снижает количество переделок:

```
Вы: "Используй planner агент чтобы спланировать: добавить пагинацию в API"
     ↓
Planner: возвращает план из 8 шагов
     ↓
Вы: "Реализуй этот план" (основной агент пишет код)
     ↓  
Вы: "Используй reviewer агент для ревью изменений"
     ↓
Reviewer: возвращает отчёт
```

### 7.3. Ad-hoc субагенты

Не обязательно заводить файл — можно делегировать на лету:

```
"Используй субагенты чтобы параллельно исследовать:
1. Как работает аутентификация в src/auth/
2. Какие эндпоинты не покрыты тестами
3. Какие TODO остались в коде"
```

Claude запустит три отдельных контекста и вернёт summary.

---

## Часть 8. Ollama — локальная модель как помощник

### 8.1. Запуск Claude Code через Ollama (полностью локально)

Для чувствительных проектов (банки, медицина) — весь код остаётся на вашей машине:

```bash
# Установить Ollama (если нет)
curl -fsSL https://ollama.com/install.sh | sh

# Скачать модель с поддержкой tool-calling
ollama pull glm-4.7-flash    # 30B MoE, 3B активных, 128K контекст

# Запустить Claude Code через Ollama
ollama launch claude --model glm-4.7-flash
```

Или через переменные окружения:

```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=http://localhost:11434

claude --model glm-4.7-flash
```

**Рекомендация по моделям** (Mac M3 Max Pro, 36GB RAM):

| Модель | Размер | Для чего |
|--------|--------|----------|
| `glm-4.7-flash` | 30B MoE (3B active) | Основная работа через Claude Code, tool-calling |
| `deepseek-r1:32b` | 32B | Сложное рассуждение |
| `qwen2.5-coder:14b` | 14B | Быстрые задачи кодирования |
| `mistral` | 7B | Суммаризация логов в хуках (быстро, мало ресурсов) |

### 8.2. Гибридный режим: Claude API + Ollama для хуков

Самый практичный подход — Claude Code работает через API Anthropic (качество), а Ollama используется в хуках для вспомогательных задач:

```
Claude Code (Anthropic API)
  ├── Пишет код
  ├── Планирует
  └── Хуки вызывают Ollama:
        ├── Суммаризация логов (mistral)
        ├── Pre-commit message generation
        └── Анализ diff перед коммитом
```

**`~/.claude/hooks/generate-commit-msg.sh`** — генерация commit message:

```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Срабатывает только на git commit
if echo "$COMMAND" | grep -q "git commit"; then
  DIFF=$(git diff --cached --stat 2>/dev/null)
  if [ -n "$DIFF" ]; then
    SUGGESTED=$(echo "$DIFF" | ollama run mistral \
      "Generate a conventional commit message (feat/fix/refactor/docs/chore) for this diff. One line, max 72 chars. Only the message, nothing else." 2>/dev/null)
    echo "💡 Suggested commit message: $SUGGESTED"
  fi
fi

exit 0
```

---

## Часть 9. Управление контекстом — ключ к продуктивности

### 9.1. Правило 50% компактификации

```json
{
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  }
}
```

Компактификация начинается при 50% заполнении контекста, а не при 95%. Это предотвращает ситуацию когда Claude забывает ранние инструкции.

### 9.2. Стратегическая компактификация

Вместо автоматической — ручная в ключевые моменты:

```
/compact сохрани: список изменённых файлов, текущий план, статус тестов
```

### 9.3. StatusLine — мониторинг контекста

```
/statusline
```

Показывает текущее использование контекстного окна. Когда видите >70% — пора делать `/compact` или `/clear`.

### 9.4. Принцип "front-load reads, back-load writes"

**Плохо** (как часто получается):
```
Read(web.py, 1-120) → Read(web.py, 320-460) → Write(web.py) 
→ Понял что потерял → Read(old_web.py chunks)...
```

**Правильно** — читать ВСЁ нужное ДО начала записи:
```
1. grep — структура всех файлов
2. Read — все нужные секции
3. Составить список: сохранить / убрать / добавить
4. Только потом Write
```

---

## Часть 10. Безопасность переменных окружения

### 10.1. Файл .env никогда не должен попадать в контекст

Добавьте в глобальный `CLAUDE.md`:

```
Никогда не читай и не выводи содержимое файлов:
- .env, .env.local, .env.production
- *.pem, *.key
- *credentials*, *secrets*

Для проверки наличия переменной используй:
  grep -c "VARIABLE_NAME" .env
НЕ используй cat или echo для этих файлов.
```

### 10.2. Хук-блокировка вывода секретов

Уже описан выше в `security-gate.sh`. Хук перехватит любую попытку вывести содержимое .env даже если модель проигнорирует инструкцию в CLAUDE.md.

### 10.3. CLAUDE_ENV_FILE для передачи переменных

Для проектов, где Claude Code нужен доступ к API-ключам (например, для запуска тестов):

```bash
# .claude/.env (git-ignored!)
DATABASE_URL=postgres://localhost:5432/mydb
REDIS_URL=redis://localhost:6379
# НЕ кладите сюда API-ключи от третьих сервисов
```

Claude Code подхватит эти переменные автоматически для Bash-команд.

---

## Часть 11. Плагины и Everything Claude Code

### 11.1. Установка ECC (Everything Claude Code)

```bash
# В Claude Code:
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code
```

Это даёт доступ к 28 агентам, 60 командам, 34 правилам.

**Важно**: не включайте всё сразу. Каждое описание MCP/скилла/агента потребляет токены. Контекстное окно 200K может сжаться до 70K.

Правило: до 10 MCP-серверов, до 80 активных tools на проект.

### 11.2. Ручная установка (выборочно)

```bash
git clone https://github.com/affaan-m/everything-claude-code.git

# Скопировать только нужные правила
cp -r everything-claude-code/rules/common/* ~/.claude/rules/
cp -r everything-claude-code/rules/python/* ~/.claude/rules/   # ваш стек

# Скопировать нужные скиллы
cp -r everything-claude-code/skills/strategic-compact ~/.claude/skills/
```

### 11.3. Community Skills

```bash
# Установка отдельных скиллов
npx skills add anthropics/claude-code --skill frontend-design

# Или коллекция скиллов
npx antigravity-awesome-skills --claude
```

---

## Часть 12. Микросервисы — масштабирование подхода

### 12.1. Контракты сервисов в одном месте

```yaml
# contracts/parser-service.yaml
name: parser-service
inputs: [metro_stations, deal_types, max_pages]
outputs: [sale_listings, stats, stopped_flag]
side_effects: [writes to data/*.json, calls progress_callback]
dependencies: [database-service, geocoding-service]
```

Клод читает контракт вместо реализации — понимает интерфейс за 5 строк.

### 12.2. Shared types

```python
# shared/types.py — один файл, маленький, не меняется часто
from pydantic import BaseModel

class Listing(BaseModel):
    id: int
    price: float
    area: float
    metro_station: str
    score: float | None = None
```

Клод читает его один раз и понимает структуру данных по всему проекту.

### 12.3. Субагенты для каждого сервиса

```
# Вместо одного агента на весь монорепо:
Agent(task="проанализируй логи parser-service за последний час")
Agent(task="найди все вызовы bulk_upsert_listings в codebase")
Agent(task="проверь контракты между parser и scorer")

# Главный агент получает summary, не сырые данные
```

---

## Часть 13. Чеклист внедрения

### Шаг за шагом для нового проекта:

- [ ] 1. Создать `~/.claude/CLAUDE.md` с глобальными правилами
- [ ] 2. Создать `~/.claude/settings.json` с хуками безопасности и уведомлений
- [ ] 3. Создать `~/.claude/hooks/` со скриптами (chmod +x)
- [ ] 4. В проекте: создать `CLAUDE.md` с описанием стека и конвенций
- [ ] 5. В проекте: создать `docs/CODE_MAP.md` для быстрой навигации
- [ ] 6. В проекте: создать `.claude/settings.json` с проектными хуками (форматирование)
- [ ] 7. Добавить AI-комментарии в ключевые файлы кода
- [ ] 8. Создать 2-3 ключевых субагента (planner, reviewer)
- [ ] 9. Создать скиллы для повторяющихся задач (/deploy, /code-review)
- [ ] 10. Настроить Ollama для хуков (суммаризация логов, commit messages)

### Для организации / команды:

- [ ] Единый шаблон проектного `CLAUDE.md` — в wiki/confluence
- [ ] Общие хуки безопасности — через managed settings
- [ ] Общие субагенты — в shared repo
- [ ] Code review checklist — как скилл
- [ ] Правила именования веток/коммитов — в глобальном `CLAUDE.md`
- [ ] Обучение: 1-часовой воркшоп по настройке

---

## Часть 14. Метрики эффекта

### Что измерять до и после внедрения:

| Метрика | До | После (ожидание) |
|---------|----|--------------------|
| Токены на задачу | ~150K | ~50-80K (экономия 40-60%) |
| Потери кода при переписывании | ~30% задач | ~5% задач |
| Время на понимание кодовой базы | Читает весь файл | Читает CODE_MAP + секции |
| Утечки секретов | Возможны | Блокируются хуками |
| Повторные чтения файлов | Частые | Минимальные (front-load reads) |
| Вовлечённость в CI/CD | Ручная | Автоматизирована через хуки |

---

## Часть 15. Полезные ссылки

- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) — 130K+ stars, плагины, скиллы, хуки
- [Claude Code Best Practice](https://github.com/shanraisshan/claude-code-best-practice) — паттерны и антипаттерны
- [Claude Code Hooks Mastery](https://github.com/disler/claude-code-hooks-mastery) — продвинутые хуки
- [Obsidian Skills](https://github.com/kepano/obsidian-skills) — агентные скиллы для Obsidian
- [Ollama + Claude Code](https://docs.ollama.com/integrations/claude-code) — официальная документация
- [Claude Code Docs: Skills](https://code.claude.com/docs/en/skills) — официальная документация скиллов
- [Claude Code Docs: Hooks](https://code.claude.com/docs/en/hooks-guide) — официальная документация хуков

---

*Автор: Artsiom Butomau | Principal Software Engineer | AI/ML @ ITMO*
*Telegram: [@devdeaf](https://t.me/devdeaf)*
