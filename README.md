## Description

Have created one "table" for each of the object types.

- Each one has the original hash saved which is used for arbitrary queries which need to scan the whole table.
- All have a primary in-memory-index which is the `'_id' => object` so each hash is actually stored twice.
  - This doubles the memory requirements but makes lookups much easier. We could remove the original hash but the orgiinal hash is nicer for doing full scans on and 2x memory won't be the bottleneck for performance.
- An additional in-memory-index is also created for each foreign key.
  - As opposed to the primary index the values here are the primary keys of the object eg. on the users table there is an index `{[org_key] => [array of user _ids]}`. This allows for multiple additional indexes while limiting the extra memory.
