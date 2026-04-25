# Component Reference

All UI primitives live in `app/javascript/components/ui/`.
Import from the barrel: `import { Button, Card, Table } from "../ui"`.

> **Rule:** Always use these components instead of writing raw CSS class strings.
> Raw `.btn`, `.card`, `.status-badge` HTML is only acceptable inside the `ui/` components themselves.

---

## Button

Renders a `<button>`, `<a>`, or React Router `<Link>` styled as a button.

```jsx
import { Button } from "../ui";

// Primary action
<Button onClick={handleSave}>Save</Button>

// Navigate to a route
<Button as="link" to="/projects/new">New Project</Button>

// External link
<Button as="a" href="/auth/logout" variant="ghost">Sign Out</Button>

// Danger with small size
<Button variant="danger" size="sm" onClick={handleDelete}>Delete</Button>
```

| Prop | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | `"primary"` | `primary` `secondary` `ghost` `danger` |
| `size` | string | — | `sm` |
| `as` | string | `"button"` | `button` `a` `link` |
| `className` | string | — | extra classes |
| ...rest | — | — | passed through (`onClick`, `disabled`, `type`, `href`, `to`, etc.) |

---

## StatusBadge

Pill badge for `BidSubmission` status values.

```jsx
import { StatusBadge } from "../ui";

<StatusBadge status="awarded" />
<StatusBadge status="lost" />
<StatusBadge status={bid.status} />
```

| Prop | Type | Default | Values |
|------|------|---------|--------|
| `status` | string | required | `drafting` `submitted` `awarded` `lost` `withdrawn` `declined` |
| `label` | string | — | overrides display text |

---

## Card

Surface container with optional title and header actions.

```jsx
import { Card } from "../ui";

// Simple card
<Card>
  <p>Content here</p>
</Card>

// Card with title and action button
<Card title="Recent Bids" actions={<Button size="sm" as="link" to="/bids">View all</Button>}>
  <BidSubmissionsTable bids={bids} />
</Card>

// Collapsible card
<Card title="Bid Details" collapsible defaultOpen={false}>
  ...
</Card>

// Card containing a full-bleed table (no padding)
<Card title="Projects" noPadding actions={<Button as="link" to="/projects/new">New</Button>}>
  <table className="table">...</table>
</Card>
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | string | — | Renders `.card__title` in header |
| `actions` | node | — | Right-aligned header content |
| `collapsible` | bool | `false` | Makes card toggle open/closed |
| `defaultOpen` | bool | `true` | Initial state when collapsible |
| `noPadding` | bool | `false` | Removes padding (for full-bleed tables) |
| `className` | string | — | Extra classes on the card |

---

## Table

Compound component wrapping `.table`. Use sub-components for correct structure.

```jsx
import { Table } from "../ui";

<Table>
  <Table.Head>
    <Table.Row>
      <Table.Th>Name</Table.Th>
      <Table.Th>Status</Table.Th>
      <Table.Th right>Value</Table.Th>
      <Table.Th />
    </Table.Row>
  </Table.Head>
  <Table.Body>
    {items.map(item => (
      <Table.Row key={item.id}>
        <Table.Td>{item.name}</Table.Td>
        <Table.Td><StatusBadge status={item.status} /></Table.Td>
        <Table.Td right>{formatCurrency(item.value)}</Table.Td>
        <Table.Td actions>
          <Button variant="ghost" size="sm" as="link" to={`/items/${item.id}/edit`}>Edit</Button>
        </Table.Td>
      </Table.Row>
    ))}
  </Table.Body>
</Table>
```

| Sub-component | Props | Notes |
|---------------|-------|-------|
| `Table` | `className` | wrapper `<table>` |
| `Table.Head` | — | `<thead>` |
| `Table.Body` | — | `<tbody>` |
| `Table.Row` | `className`, ...rest | `<tr>` — add `.project-row--awarded` etc. via className |
| `Table.Th` | `right`, `className` | `<th>` |
| `Table.Td` | `right`, `actions`, `className` | `<td>` — `actions` adds `.table__actions` |

---

## EmptyState

Centered empty-state message, used inside a card or table when there is no data.

```jsx
import { Button, EmptyState } from "../ui";

<EmptyState
  message="No contractors yet."
  action={<Button as="link" to="/contractors/new">Add Contractor</Button>}
/>

// Without an action
<EmptyState message="No bids match your current filters." />
```

| Prop | Type | Description |
|------|------|-------------|
| `message` | string | Primary message |
| `action` | node | Optional call-to-action |

---

## StatCard

Dashboard summary metric tile. Use inside a `.stats-grid` container.

```jsx
import { StatCard } from "../ui";

<div className="stats-grid">
  <StatCard label="Total Bids YTD" value="142" />
  <StatCard label="Win Rate" value="68%" sub="vs 62% last year" />
  <StatCard label="Awarded Revenue" value="$4.2M" />
  <StatCard label="Dollar Win Rate" value="71%" />
</div>
```

| Prop | Type | Description |
|------|------|-------------|
| `label` | string | Uppercase label |
| `value` | string \| number | The metric |
| `sub` | string | Optional secondary line below value |

---

## FormField

Labeled form control supporting all input types used in this app.

```jsx
import { FormField } from "../ui";

// Text input
<FormField label="Project Name" name="project[name]" value={name} onChange={e => setName(e.target.value)} />

// Date
<FormField type="date" label="Bid Due" name="bid_due_at" value={bidDue} onChange={...} />

// Select
<FormField
  type="select"
  label="Status"
  name="status"
  value={status}
  onChange={e => setStatus(e.target.value)}
  options={[
    { value: "drafting", label: "Drafting" },
    { value: "submitted", label: "Submitted" },
    { value: "awarded", label: "Awarded" },
  ]}
  placeholder="Select status..."
/>

// Textarea
<FormField type="textarea" label="Notes" name="notes" value={notes} onChange={...} rows={4} />

// Checkbox
<FormField type="checkbox" label="Include Fire Alarm" name="included_fire_alarm" value={fa} onChange={...} />

// Escape hatch — custom control with matching label styling
<FormField label="Contractor">
  <SearchableDropDown ... />
</FormField>
```

| Prop | Type | Default | Notes |
|------|------|---------|-------|
| `type` | string | `"text"` | `text` `email` `tel` `number` `date` `textarea` `select` `checkbox` |
| `label` | string | — | Label text |
| `name` | string | — | input name/id |
| `value` | string \| bool | — | Controlled value |
| `onChange` | function | — | Change handler |
| `required` | bool | `false` | |
| `showLabel` | bool | `true` | |
| `options` | array | `[]` | `{ value, label }` — required for `type="select"` |
| `placeholder` | string | — | Input placeholder or empty select option |
| `rows` | number | `3` | Textarea rows |
| `small` | bool | `false` | Renders at `--sm` size |
| `children` | node | — | Replaces the input with a custom control |

---

## SearchableDropDown

Single-select dropdown with live search. Used for selecting a single item from a large list (e.g. contractor on a bid form).

```jsx
import { SearchableDropDown } from "../ui";

<SearchableDropDown
  label="Contractor"
  items={contractors}
  searchableColumns={["name"]}
  value={selectedContractor}
  onChange={c => setSelectedContractor(c)}
  placeholder="Select contractor..."
/>

// Custom display (e.g. show name + company)
<SearchableDropDown
  label="Contact"
  items={contacts}
  searchableColumns={["name", "company"]}
  displayFn={c => `${c.name} — ${c.company}`}
  value={selectedContact}
  onChange={setSelectedContact}
/>
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `items` | array | `[]` | Full list of selectable items |
| `searchableColumns` | string[] | `[]` | Object keys to search and display |
| `displayFn` | function | — | `(item) => string` overrides searchableColumns for display |
| `value` | object | — | Currently selected item |
| `onChange` | function | — | `(item) => void` |
| `label` | string | — | Field label |
| `placeholder` | string | `"Select..."` | |
| `required` | bool | `false` | |
| `disabled` | bool | `false` | |
| `showLabel` | bool | `true` | |

---

## MultiSelectDropDown

Multi-select dropdown with live search and chip display for selected items.

```jsx
import { MultiSelectDropDown } from "../ui";

<MultiSelectDropDown
  label="Classifications"
  items={classifications}
  searchableColumns={["name"]}
  value={selectedClassifications}
  onChange={vals => setSelectedClassifications(vals)}
/>
```

Same props as `SearchableDropDown`, except:
- `value` is an array of selected items (default `[]`)
- `onChange` receives the full updated array

---

## MetaList / MetaItem

Key/value detail display for show pages. Renders a horizontal row of labeled fields.

```jsx
import { MetaList, MetaItem } from "../ui";

<MetaList>
  <MetaItem label="Location">{project.city}, {project.state}</MetaItem>
  <MetaItem label="Project Type">{project.type || "—"}</MetaItem>
  <MetaItem label="Estimated Start">{formatDate(project.estimated_start_date)}</MetaItem>
</MetaList>

// Multi-line value (each child becomes its own <dd>)
<MetaItem label="Address">
  <span>{project.street}</span>
  <span>{project.city} {project.state} {project.zip_code}</span>
</MetaItem>
```

| Prop | Type | Description |
|------|------|-------------|
| `MetaList` `className` | string | Extra classes on the `<dl>` |
| `MetaItem` `label` | string | Field label (renders as `<dt>`) |
| `MetaItem` `children` | node | Value(s) — each child becomes a `<dd>` |

---

## Tag

Small inline accent pill for categorization labels. Use for things like project types, scope flags, or "Rebid" indicators.

For bid **status** indicators, use `StatusBadge` instead.

```jsx
import { Tag } from "../ui";

// Static
<Tag>Fire Alarm</Tag>
<Tag>Low Voltage</Tag>

// Inline next to a heading
<h2>Riverside Elementary <Tag>Rebid</Tag></h2>

// Dismissible
<Tag onRemove={() => removeClassification(id)}>Commercial</Tag>

// Multiple tags
{project.classifications.map(c => (
  <Tag key={c.id}>{c.name}</Tag>
))}
```

| Prop | Type | Description |
|------|------|-------------|
| `children` | string \| node | Tag text |
| `onRemove` | function | If provided, renders an × dismiss button |
| `className` | string | Extra classes |

---

## PageHeader

Sticky top header bar with page title and optional actions.

```jsx
import { Button, PageHeader } from "../ui";

<PageHeader
  title="Projects"
  actions={
    <>
      <Button variant="secondary" size="sm" as="link" to="/projects?filter=active">Active</Button>
      <Button as="link" to="/projects/new">New Project</Button>
    </>
  }
/>

// No actions
<PageHeader title="Dashboard" />
```

| Prop | Type | Description |
|------|------|-------------|
| `title` | string | Page title |
| `actions` | node | Right-aligned header content |

---

## Layout Classes (not components)

These CSS classes are used directly — no component wrapper needed.

| Class | Use |
|-------|-----|
| `.app-body` | Root flex container |
| `.app-main` / `.app-main--with-sidebar` | Main content area |
| `.page-content` | Inner content padding wrapper |
| `.stats-grid` | 4-column dashboard stat cards grid |
| `.charts-grid` | 2-column chart layout |
| `.form__row--cols-2` / `--cols-3` | Horizontal form field rows |
| `.form__section` | Vertical form section spacing |
| `.form__section-header` | Section title + separator |
| `.form__actions` | Submit/cancel button row |
| `.filter-bar` | Horizontal filter controls row |
| `.link` | Inline anchor styled as accent |
