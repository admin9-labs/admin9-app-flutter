# Design System Owners

| Responsibility | Required approver | Record location |
| --- | --- | --- |
| Core contract, API, tokens and platform mapping | 冯齐跃 (`qiyue2015`), Admin9 Foundation maintainer | Design System change review |
| Brand Theme | derived-app brand owner plus 冯齐跃 (`qiyue2015`) as Core maintainer | `admin9-foundation.yaml` and theme review |
| Business behavior/content | derived-app product/feature owner | feature change review |
| accessibility hard gates | 冯齐跃 (`qiyue2015`), accessibility/test reviewer | acceptance report |
| release compatibility/deprecation | 冯齐跃 (`qiyue2015`), Foundation release maintainer | changelog and compatibility row |

The canonical Foundation repository is
`https://github.com/admin9-labs/admin9-app-flutter.git`. Repository
`CODEOWNERS`, this ownership record and the governance validator bind Core,
accessibility/test and release approval to the named maintainer above. A derived
project still records its own Brand and Business owners in
`admin9-foundation.yaml`; those customer-project roles are not silently assigned
to the Foundation maintainer.
