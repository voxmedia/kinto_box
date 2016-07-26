# Kinto Box [![Gem Version](https://badge.fury.io/rb/kinto_box.svg)](https://badge.fury.io/rb/kinto_box)

Kinto Box is a ruby client for [Kinto](http://kinto.readthedocs.io)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kinto_box'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kinto_box

## Usage
To use kinto_box, add `require 'kinto_box'` to your file.


### Connection and Authentication


To connect to a kinto server, you can pass the username and password to the client

```
kinto_client = KintoBox::KintoClient.new('https://kinto.dev.mozaws.net', {:username => 'token', :password => 'my-secret'})
```

If no credentials are passed, the gem looks for `KINTO_API_TOKEN` environment variable. The environment variable should store the Base64 encoding of `username:password` string, for this to work.


### Buckets

#### Creating a new bucket

To create a new bucket named `TestBucket`

```
bucket = kinto_client.create_bucket('TestBucket')
```

#### Using a bucket

To connect to a bucket named `TestBucket`

```
bucket = kinto_client.bucket('TestBucket')
```

> Note: This does not create the bucket nor check if the bucket exists on the server.

To check if the bucket exists use

```
bucket.exists?
```

To get information about the bucket, use

```
bucket.info
```

#### Bucket permissions

To get permissions set on the bucket, use

```
bucket.permissions
```

To add permission to the bucket, use `add_permission(principal, permission)`

See `http://kinto.readthedocs.io/en/stable/api/1.x/permissions.html#api-permissions` to see valid principals and permissions

For convenience, the following are supported. `everyone` and `anonymous` is the same as `System.Everyone`. And `authenticated` is the same as `System.Authenticated`

#### Deleting bucket
To delete a bucket, use

```
bucket.delete
```

### Collections

#### Creating a collection

To create a collection named `TestCollection`, use

```
collection = bucket.create_collection('TestCollection')
```

#### Using a collection

To connect to a collection named `TestCollection`

```
collection = bucket.collection('TestCollection')
```

> Note: This does not create the collectiont nor check if the collection exists on the server.

To check if the collection exists use

```
collection.exists?
```

To get information about the bucket, use

```
collection.info
```

#### Collection permissions

To get permissions set on the collection, use

```
collection.permissions
```

To add permission to the bucket, use `collection.add_permission(principal, permission)`


#### Deleting a collection
To delete a bucket, use

```
collection.delete
```

To read from the collection

```
records = collection.list_records
```

To delete all records from the collection

```
records = collection.delete_records
```

### Records

To add an object to the collection

```
data = { 'foo' => 'value1' }
collection.create_record(data)
```

#### Deleting a record
```
record.delete
```

#### Update data in a record

```
record.update({'bar' => new_value})
```

This add a value bar to the record

To replace the data entirely, use

```
record.replace({'bar' => new_value})
```

This drops the property food taht existed before the update.


### Groups

#### Creatinga group

```
    group = bucket.create_group(group_name, member)
```

Member can be any valid principal


#### Deleting a group
```
    group.delete
```

#### Manging members

```
group.add_member(user)
group.remove_member(user)
```

To replace all members, use

```
group.update_members(users)
```

See `test/kinto_box_test` for more usages

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kavyasukumar/kinto_box.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

