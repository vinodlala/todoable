# todoable

# Things to do:

Add VCR to mock responses.  I tried in vain but cassettes wouldn't record.

Test all endpoints.

Test authentication (missing/invalid username/password, expired token).

Figure out how todoable ended up in a todoable folder.

Refactor one long file into multiple files.

# Basic manual run through to make sure everything works:

```
irb
require 'todoable'
client = Todoable::Client.new(username: "vinod_lala@usa.net", password: "todoable")
```
```
# test GET /lists
client.get_lists
#  => {"lists"=>[]}
```
```
# test POST /lists - give it a name
client.post_list("WE WILL EDIT THIS LIST NAME NEXT")
#  => {"name"=>"WE WILL EDIT THIS LIST NAME NEXT", "src"=>"http://todoable.teachable.tech/api/lists/6a19c573-d02b-4d1d-9d3f-244e96a7403a", "id"=>"6a19c573-d02b-4d1d-9d3f-244e96a7403a"}
# copy the id of the list and paste it here
```

```
id = "6a19c573-d02b-4d1d-9d3f-244e96a7403a"
```

```
# Check that the list with that name and id gets returned in the lists
client.get_lists
#  => {"lists"=>[{"name"=>"WE WILL EDIT THIS LIST NAME NEXT", "src"=>"http://todoable.teachable.tech/api/lists/6a19c573-d02b-4d1d-9d3f-244e96a7403a", "id"=>"6a19c573-d02b-4d1d-9d3f-244e96a7403a"}]}
```

```
# test GET /lists/:list_id
client.get_list(id)
#  => {"name"=>"WE WILL EDIT THIS LIST NAME NEXT", "items"=>[]}
```

```
# test PATCH /lists/:list_id
client.patch_list(id, "WE WILL DELETE THIS LIST NEXT")
#  => "WE WILL DELETE THIS LIST NEXT updated"
```
```
# test DELETE /lists/:list_id
client.delete_list(id)
#  => ""
```
```
client.get_lists
#  => {"lists"=>[]}
# lists should be empty
```
```
# make a new list
client.post_list("WE WILL ADD ITEMS TO THIS LIST")
#  => {"name"=>"WE WILL ADD ITEMS TO THIS LIST", "src"=>"http://todoable.teachable.tech/api/lists/2576a332-c1c3-4e0e-b8fa-5e7c0655a175", "id"=>"2576a332-c1c3-4e0e-b8fa-5e7c0655a175"}
# copy the id of the list
```
```
id = "2576a332-c1c3-4e0e-b8fa-5e7c0655a175"
```
```
# test POST /lists/:list_id/items
name = "Feed the dog"
client.post_list_items(id, name)
#  => {"name"=>"Feed the dog", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/2576a332-c1c3-4e0e-b8fa-5e7c0655a175/items/c77c2753-df5d-439f-a678-e68e23541250", "id"=>"c77c2753-df5d-439f-a678-e68e23541250"}
```
```
# copy the id of the item and paste it below
item_id = "c77c2753-df5d-439f-a678-e68e23541250"
```
```
# check that the item is on the list
client.get_list(id)
#  => {"name"=>"WE WILL ADD ITEMS TO THIS LIST", "items"=>[{"name"=>"Feed the dog", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/2576a332-c1c3-4e0e-b8fa-5e7c0655a175/items/c77c2753-df5d-439f-a678-e68e23541250", "id"=>"c77c2753-df5d-439f-a678-e68e23541250"}]}
```
```
# test PUT /lists/:list_id/items/:item_id/finish
client.finish_list_item(id, item_id)
#  => "Feed the dog finished"
```
```
# DELETE /lists/:list_id/items/:item_id
client.delete_list_item(id, item_id)
#  => ""
```
```
# check that the item is no longer on the list
client.get_list(id)
#  => {"name"=>"WE WILL ADD ITEMS TO THIS LIST", "items"=>[]}
```