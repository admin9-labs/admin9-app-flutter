# Page Patterns

<a id="ds-pat-001"></a>

Page patterns describe information and behavior. They are not configurable page widgets, business schemas, or a DSL.

| Pattern | Task and hierarchy | State/back/layout | Platform difference | Business substitution and proof |
| --- | --- | --- | --- | --- |
| App Shell / primary navigation | 2-5 durable top-level tasks; one selected | tabs retain state; root back exits app hierarchy; body protected by bottom bar | Material NavigationBar vs CupertinoTabBar | Business supplies destinations/pages; Gallery shell plus device tab/back test |
| standard secondary page | one title, content, optional actions | back returns once; scroll and safe areas explicit | AppBar vs CupertinoNavigationBar with parent label | Business supplies content/actions; gesture device gate |
| personal center | identity + primary auth/action, account, settings, legal/about, danger in that order | guest/signed-in/missing-field; final danger reachable; no repeated auth | Material rows/groups vs inset-grouped iOS lists | identity, capabilities and session are Business; three reference states |
| authentication form | one credential task, persistent labels, local errors, one primary submit | keyboard, first error, unavailable result, route-local draft, back | Material field/feedback vs Cupertino field/top notice | fields, validation, service and session are Business; register/login references only |
| settings list | current values and controlled App preferences | choice subpage, immediate update, persistence; system OR App effective states | radio list + Switch vs checkmark list + CupertinoSwitch | actual preferences/data owner are Business/Foundation host; settings reference |
| ordinary list/detail | scan/select then inspect one item | loading/empty/error/pagination belong to feature; selection survives return when required | platform rows, page bars and disclosure | item model, query, filters, actions are Business |
| privacy gate | understand consent before entering host | accept/reject/legal round trip, durable decision, accessible long text | platform dialog/page actions and back conventions | legal text/decision owner is Foundation/Business; not a reusable dialog DSL |
| state presentation | empty, loading, error, success, unavailable are mutually meaningful | user sees what happened and next action; state survives/retries by feature contract | platform loading/feedback containers | Core supplies Notice/Feedback presentation only; Business decides state/copy |
| long text/legal | read and return | scroll endpoint, selection/readability, no fixed bottom action obscuring text | native page bar/back | Business supplies verified content/version |

## 1. Shared rules

- A screen has at most one primary-action region. Secondary commands never visually compete with it.
- Dangerous actions are separated from daily tasks and require consequence-specific confirmation.
- High-frequency tasks precede explanation and legal links; danger is last.
- Guest users never see daily entries that necessarily fail; signed-in users never see duplicate login/register entries.
- Loading describes ongoing work, success confirms a completed result, error explains a failed attempt and recovery, unavailable truthfully states a missing capability, and empty describes valid zero data. They are not interchangeable.
- Scroll order, focus order, and expected screen-reader order match. Large text may change geometry but not information order.
- 320/360/390 use one column; 600 centers content; phone landscape remains a reachable scroll task, not a compressed desktop layout.

## 2. Reference scope

The account, auth, and settings visual references calibrate shared color, type, spacing, platform mapping, hit bounds, and state treatment. Derived apps MAY replace content and page-specific composition while respecting the pattern. They MUST NOT copy sample identity data, validation rules, legal content, routes, or unavailable results as product truth.

## 3. Gallery and device evidence

Gallery later contains component states and pattern fixtures with synthetic, explicitly labelled data. It is registered only in debug/profile and is unreachable in release. Reference-task acceptance covers:

1. Home -> Account -> Settings -> Appearance change -> back -> restart persistence.
2. Guest Account -> Register -> error -> focus first error -> correction -> unavailable -> Login -> Account.

Static designs prove intent only. Runtime scroll, IME, persistence, semantics, platform navigation, and gestures require Widget/integration/device evidence.
