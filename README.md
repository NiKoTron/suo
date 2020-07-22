# Suo DB

Suo (suomi: swamp) is document oriented DB.

## Status

This package in heavly development process.
Currently you can plug this dependency via git link in pubspec.

- [] tested;
- [] well documented;
- [] published;

## Description

It's platform agnostic DB is developing with dart language.

Main concept of this storage it's provide possibility to store any structures and make easy search by them, therefore in the docstorage we use indexing. Index is a structure that made for icrease datata retrieval speed, a bit detailed below.

### Indexing

Current index implementation allows us to retrieve a document with indexed value in `O(1)` access time. Cuz index storing implemented by the hash set of keys and pointers.
Physicaly index files stores in `.idx` files inside `index` direcory and have a structure like this.

``` plain
entity_storage/
    index/
        index_name.idx
        index_name2.idx
        etc..
```

inside index file we have a following view:

``` plain
index_value:link_1,link2,link3
index_value2:link_4,link_6,
index_valueN:link_x,link_z

etc..
```

where `link_n` is pointer (id) on exact document;

`Index` and `IndexedEntity` are classes that helps us to create this shit.

`Index<V,I>` is functional-based index. that keep two field inside `name` and `indexFunction`.
`IndexEntity<V,I>` is wrapper around your primary DTO, that consist `value` list of `indicies` and computable field `id` its field something like primary key. as is a computable it could be composed key. but in generarall it have to be id of your DTO.

### DocStorage Usage

First of all we should create indexed wrapper for our DTO object.

``` dart
class SomeObj {
    String id;

    String foo;
    String bar;
    String baz;


    SomeObj.fromJson(String json) // create instance from json
    toJson() => // convert to json...
}

class IndexedObj extends IndexedEntity<SomeObj, String> {

  IndexedBike(value) : super(
      value, // dto value
      (v) => v.id, // id
      [
        Index('foo', (v) => '${v?.foo}'),
        Index('foobaz', (v) => '${v?.foo}_${v?.baz}')
      ]);
}
```

Initialisation of storage.

For each type of object, we have to create their own docstorage with a unique directory.

We should pass four parameters to create storage instance:

The directory where data files will managing.
Deserialiser and serialiser like in `DirStorage` above.
Indexed factory is a function that makes an `IndexedEntity` wrapper instance for our DTO.

## MonoRepo

This is a root repo that contains a two main repos inside:

- `suo` db implementation
- `suo_generator` - generator helper for declarative style DTOs

## License

Developing under MIT license

## Instalation

## Usage

## Credits
