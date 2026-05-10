---
name: arch-diagram
description: Generates architecture diagrams from natural language descriptions. Use when the user asks to "draw", "visualize", "diagram", "show architecture", "create a scheme", "нарисуй схему", "покажи архитектуру", "диаграмма микросервисов", "sequence diagram", or describes a system with services, components, flows, or interactions. Automatically selects SVG (for rich block diagrams with layers, colors, and annotations) or Mermaid (for sequence diagrams, flow-based interactions, GitHub/Confluence rendering). Works for microservice architectures, event-driven systems, API flows, data pipelines, and integration schemes.
metadata:
  author: baton2809
  version: 1.0.0
  category: architecture
  tags: [architecture, diagram, svg, mermaid, microservices, sequence]
---

# arch-diagram

Generates professional architecture diagrams from natural language. Supports two output modes and two diagram types — chosen automatically based on context.

## Format Selection Logic

**Choose SVG when:**
- User asks for a visual, presentable, or downloadable diagram
- The diagram has layers, groups, color coding, or rich annotations
- Output is for slides, docs, or an architecture review
- Multiple service blocks with connections and swimlanes

**Choose Mermaid when:**
- Output goes to GitHub, Confluence, or Markdown docs
- User says "mermaid", "md", "в confluence", "в readme"
- The diagram is primarily sequential (request → service → DB flow)
- Quick draft is needed

## Diagram Type Selection Logic

**Block/Layer diagram (architecture overview) when:**
- User describes components, services, modules, layers
- Keywords: "архитектура", "компоненты", "сервисы", "блок-схема", "система из N сервисов"

**Sequence diagram when:**
- User describes a flow, request lifecycle, or interaction between services
- Keywords: "последовательность", "flow", "запрос идёт через", "sequence", "кто вызывает кого"

---

## Step 1: Clarify (only if critically ambiguous)

If the description is too vague to draw, ask ONE question:
> «Это общая схема компонентов или последовательность вызовов между сервисами?»

Otherwise — draw immediately. Never ask for format (SVG/Mermaid) unless explicitly requested.

---

## Step 2: Extract Structure

From the user's description, identify:
- **Services / components** — named boxes (Router, Enricher, Kafka, PostgreSQL, etc.)
- **Groups / layers** — logical swim lanes or zones (Frontend, Backend, Infrastructure)
- **Connections** — directed arrows with optional labels (REST, Kafka topic, gRPC, async)
- **Annotations** — notes, deadlines, owners, status badges

---

## Step 3: Generate Diagram

### SVG Mode — Block Architecture

Rules:
- Canvas: `viewBox="0 0 1200 800"` (adjust for complexity)
- Color palette — dark professional theme:
  - Background: `#0f1117`
  - Service boxes: `#1e2130` fill, `#3d4466` stroke, `2px` stroke-width, `rx="8"`
  - Group/layer background: `#161824` with `#2a2d3e` border, `rx="12"`
  - Arrows: `#6c7ae0` stroke, `markerEnd` arrowhead
  - Labels on arrows: `#a0a8d0`, font-size 11
  - Service name: `#e8eaf6`, font-size 13, font-weight 600
  - Subtitle/type: `#6c7ae0`, font-size 10
  - Group label: `#4a5180`, font-size 11, uppercase, letter-spacing 1.5
- Layout:
  - Left-to-right or top-to-bottom depending on flow
  - Group boxes act as swim lanes with padding 20px inside
  - Services: min 160x60px, spaced 40px apart
  - Use `<defs><marker>` for arrowheads
  - Use `<line>` or `<path>` for connections, never `<foreignObject>`
- Annotations: small badge boxes `#2d3250` with `#6c7ae0` text for notes like "Kafka topic: enrichment.request"

CRITICAL: All SVG text must use `font-family="'Segoe UI', system-ui, sans-serif"`. Never embed HTML inside SVG.

### Mermaid Mode — Block Architecture

```
graph LR
  subgraph Layer["Layer Name"]
    ServiceA["Service A\nsubtitle"]
    ServiceB["Service B"]
  end
  ServiceA -->|"REST POST /enrich"| ServiceB
```

Rules:
- Use `LR` for horizontal flow, `TD` for vertical
- `subgraph` for logical groups
- Arrow labels in quotes for clarity
- Service names: short, no spaces (use underscores internally, display name in brackets)

### Mermaid Mode — Sequence Diagram

```
sequenceDiagram
  participant C as Client
  participant R as Router
  participant E as Enricher
  participant DB as PostgreSQL

  C->>R: POST /calculate
  R->>E: enrich(request)
  E->>DB: SELECT master_data
  DB-->>E: master_data
  E-->>R: enriched_payload
  R-->>C: 200 OK
```

Rules:
- Always add `participant` aliases for readability
- Use `->>` for sync calls, `-->>` for responses, `--)` for async/Kafka
- Add `Note over ServiceA,ServiceB: описание` for key steps
- Group with `rect rgb(30,33,50)` for critical paths

---

## Step 4: Output

**For SVG:** Output as a complete `.svg` file saved to `/mnt/user-data/outputs/arch-diagram.svg`. Then render inline.

**For Mermaid:** Output as a fenced code block ` ```mermaid ` ready to paste into Confluence/GitHub. Also save to `/mnt/user-data/outputs/arch-diagram.md`.

After generating, briefly list what was drawn:
> «Нарисовал: Router → Enricher → ResultService. Группы: Frontend, Backend Core, Infrastructure. Формат: SVG.»

---

## Common Patterns (Fintech / Backend)

These patterns appear often — apply automatically when recognized:

| Pattern | Services to include |
|---|---|
| Calculation engine | Router, ProductService, Enricher, RulesEngine, Kafka, PostgreSQL |
| Event-driven enrichment | Producer → Kafka Topic → Consumer → DB → Response |
| API gateway flow | Client → Gateway → Auth → Service → Cache → DB |
| Multi-system integration | IntegrationService → MasterSystem1, MasterSystem2 |
| Multi-agent system | Orchestrator → AnalyzerAgent → JiraAgent → ConfluenceAgent → BitbucketAgent |

---

## Error Handling

**«Слишком много сервисов, диаграмма нечитаема»**
→ Split into two diagrams: high-level overview + detail zoom for one subsystem. Ask user which to show first.

**«Не знаю точные названия сервисов»**
→ Use generic placeholders: `ServiceA`, `ServiceB` with a comment `# замени на реальные имена`. Still draw.

**«Нужно добавить сервис»**
→ Re-generate with the new service added. Don't ask for the full description again — infer from context.

---

## References

See `references/svg-patterns.md` for reusable SVG components (arrowhead defs, box templates, group templates).
