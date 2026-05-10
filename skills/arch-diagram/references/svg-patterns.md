# SVG Patterns Reference

Reusable SVG snippets for arch-diagram skill.

## Arrowhead Definition (always include in <defs>)

```svg
<defs>
  <marker id="arrow" markerWidth="10" markerHeight="7"
          refX="10" refY="3.5" orient="auto">
    <polygon points="0 0, 10 3.5, 0 7" fill="#6c7ae0"/>
  </marker>
  <marker id="arrow-async" markerWidth="10" markerHeight="7"
          refX="10" refY="3.5" orient="auto">
    <polygon points="0 0, 10 3.5, 0 7" fill="#4a5180"/>
  </marker>
</defs>
```

## Service Box Template

```svg
<!-- Service box: x,y = top-left corner, w=160, h=60 -->
<rect x="100" y="100" width="160" height="60"
      rx="8" fill="#1e2130" stroke="#3d4466" stroke-width="2"/>
<text x="180" y="126" text-anchor="middle"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="13" font-weight="600" fill="#e8eaf6">ServiceName</text>
<text x="180" y="144" text-anchor="middle"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="10" fill="#6c7ae0">Spring Boot / Kafka</text>
```

## Group / Layer Box Template

```svg
<!-- Group box: contains multiple services -->
<rect x="60" y="60" width="500" height="200"
      rx="12" fill="#161824" stroke="#2a2d3e" stroke-width="1.5"/>
<text x="80" y="84"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="11" fill="#4a5180"
      letter-spacing="1.5" text-transform="uppercase">BACKEND CORE</text>
```

## Arrow Templates

```svg
<!-- Sync REST call -->
<line x1="260" y1="130" x2="340" y2="130"
      stroke="#6c7ae0" stroke-width="1.5"
      marker-end="url(#arrow)"/>
<text x="300" y="122" text-anchor="middle"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="10" fill="#a0a8d0">REST POST</text>

<!-- Async Kafka call (dashed) -->
<line x1="260" y1="130" x2="340" y2="130"
      stroke="#4a5180" stroke-width="1.5" stroke-dasharray="6,3"
      marker-end="url(#arrow-async)"/>
<text x="300" y="122" text-anchor="middle"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="10" fill="#6c7ae0">kafka: topic.name</text>
```

## Annotation Badge

```svg
<!-- Small note badge -->
<rect x="350" y="90" width="140" height="24"
      rx="4" fill="#2d3250" stroke="#6c7ae0" stroke-width="1"/>
<text x="420" y="106" text-anchor="middle"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="10" fill="#6c7ae0">deadline: 06.06</text>
```

## Database / Queue Icons (text-based)

```svg
<!-- DB label -->
<text x="180" y="144" text-anchor="middle"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="10" fill="#6c7ae0">🗄 PostgreSQL</text>

<!-- Kafka label -->
<text x="180" y="144" text-anchor="middle"
      font-family="'Segoe UI', system-ui, sans-serif"
      font-size="10" fill="#6c7ae0">⚡ Kafka</text>
```

## Canvas Size Guidelines

| Services count | Recommended viewBox |
|---|---|
| 3–5 | `0 0 900 500` |
| 6–10 | `0 0 1200 700` |
| 11–20 | `0 0 1600 900` |
| 20+ | Split into 2 diagrams |

## Color Reference

| Element | Color |
|---|---|
| Background | `#0f1117` |
| Service box fill | `#1e2130` |
| Service box stroke | `#3d4466` |
| Group fill | `#161824` |
| Group stroke | `#2a2d3e` |
| Arrow (sync) | `#6c7ae0` |
| Arrow (async) | `#4a5180` |
| Service name text | `#e8eaf6` |
| Service subtitle | `#6c7ae0` |
| Arrow label | `#a0a8d0` |
| Group label | `#4a5180` |
| Annotation bg | `#2d3250` |
| Annotation text | `#6c7ae0` |
