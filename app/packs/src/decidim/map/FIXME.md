# Map overrides due to problems with the map API

The following PR fixes some problems with the map APIs in Decidim:
https://github.com/decidim/decidim/pull/11105/files

These overrides are needed as long as these changes get migrated back to the
core.

Also the `src/decidim/map.js` is currently overridden due to the factory
utilization changes in this PR:
https://github.com/decidim/decidim/pull/9425
