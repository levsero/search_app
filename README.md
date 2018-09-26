## Running application

- To run the application you need to have ruby installed and run `ruby lib/search_app.rb` when in this directory.
- To run the specs need to `bundle` and then run `rspec`
- The response is a pretty formated json string, where the associations have been merged in to the base items.
  eg.

```
[
  {
    "_id": 32,
    "url": "http://initech.zendesk.com/api/v2/users/32.json",
    "external_id": "b8ef8d96-4d64-49a3-b2c6-b04bdc23ba01",
    "name": "Lee Dotson",
    "alias": "Mr Eve",
    "created_at": "2016-07-17T02:09:22 -10:00",
    "active": true,
    "verified": true,
    "shared": false,
    "locale": "zh-CN",
    "timezone": "France",
    "last_login_at": "2016-08-21T09:09:09 -10:00",
    "email": "evedotson@flotonic.com",
    "phone": "8485-142-308",
    "signature": "Don't Worry Be Happy!",
    "organization_id": 105,
    "tags": [
      "Tetherow",
      "Hailesboro",
      "Barstow",
      "Fruitdale"
    ],
    "suspended": false,
    "role": "agent",
    "organization": {
      "_id": 105,
      "url": "http://initech.zendesk.com/api/v2/organizations/105.json",
      "external_id": "52f12203-6112-4fb9-aadc-70a6c816d605",
      ...
    },
    "tickets": [
      {
        "_id": "cb3b726e-9ba0-4e35-b4d6-ee41c29a7185",
        "url": "http://initech.zendesk.com/api/v2/tickets/cb3b726e-9ba0-4e35-b4d6-ee41c29a7185.json",
        "external_id": "19376875-49a7-4540-847b-b25f093b1635",
        ...
      },
      {
        ...
      }
    ]
  },
  ...other users
}
```

## Assumptions

- `id`'s are unique
- This will work more easily if the data is not changed. Can easily add more data and keep things indexed, but if had to update or delete would be a bit trickier to implement (though definitely doable).

## Description and reasoning

- There is one `Database` class that contains one "table" for each of the object types.
  - The database is created from json strings of the data, with a helper function that allows file paths to be used instead.
  - All external search calls come through this class and if we would add update, or delete functions this class would handle those as well.
- Each table has the original hash saved which is used for arbitrary queries which need to scan the whole table.
- #add_data is a separate method outside of the `initialize` because all the tables have to be init'ed before they can be stored.
  - It returns `self` so it can be chained with other methods in the future if need be (eg. `.add_data(data).add_association(associations).create_indexes`)
- Have added a primary in-memory-index to every table which is the `'_id' => object` so each hash is actually stored twice.
  - This doubles the memory requirements but makes lookups much easier. We could remove the original hash but the orgiinal hash is nicer for doing full scans on and 2x memory won't be the bottleneck for storage.
- An additional in-memory-index is also created for each foreign key as they are the most commonly referenced fields.
  - As opposed to the primary index the values here are the primary keys of the object eg. on the users table there is an index `{[org_key] => [array of user _ids]}`. This allows for multiple additional indexes while limiting the extra memory.
  - The foreign key indexes could be combined into a single hash that would have all indexed fields as keys, but prefer having them as seperate hashes to provide more flexibility. For example if it's decided it's no longer necessary to keep one specific one it's easy to remove, or if they are very large having multiple will make it easier to store them on separate machines or in separate files.
- Could add indexes on every field but don't think the space-performance ratio would be worthwhile, so unless there are specific performance issues is not needed.
- Currently these indexes won't actually necessarily provide a large perforance boost as all the find_by queries still require a full table scan, but this logic can be extended to any field that is found to be frequently queried. If we decide to write indexes to files we could also then easily index all columns as the memory usage would no longer be a concern (though could depend on the memory-to-disk availability ratio if this would make sense).

## Scalability and perforance

- Currently the main bottleneck to scalability is the memory usage, since it stores everything in memory. Though have tested it locally with up to 100,000 users and 100,000 tickets and have had no issues. If you would want it to scale then would have to either start writing portions to disk or could keep it all in memory and start splitting it across machines.
- Being that it is all in memory the performance is really fast and even full scans of 100,000 items are near instantaneous.
