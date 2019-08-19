
In Order
========

Overview
--------

This is a (small simple single-purpose) Rails engine that,
in technical terms,
provides a uni-directional persistent linked list (presently SQL-based).

It's to establish one-to-many relationships between a composite *key*
and an ordered collection of *ActiveRecord* models.

The *key* is a combination of a single *ActiveRecord* model and a
free-text string, one of which is mandatory.

It allows you to introduce ad hoc relationships between arbitrary records
without changing anything in the participating records themselves.

Uses
----

Its potential uses are manifold, in fact, there are too many to mention.
In some guise or other, the basic functionality is used everywhere,
and it's a foundation of many patterns.

In everyday web development, the API will mainly be used to
store particular users' preferences, selections and actions.
Especially if preserving the order of the related elements is important.

Some Use-Cases
--------------

The API could be used to support the development of the following:

- Listing a user's favoured or recently accessed records.
  So that they may, for example,
  appear at the top of various lists used in HTML elements,
  such as *select options* or *table* rows or menu links.

- For session storage of things like search terms, bookmarked links,
  current records and notifications.

- Displaying user-specific recommendations, linking users to groups,
  intermediate storage for multi-page wizards, tagging, contextual lists,
  queuing jobs, auditing, tracking changes, etc..

- To log things like page clicks, form submissions, login attempts,
  API calls, record edits &amp; IP addresses by user, etc..

- Recording messages or conversations.

- Drag'n'drop lists, for which a rudementary *Stimumlus* module is included.
  This is for things like to-do lists,
  task or page ordering,
  allowing users to specify menu items, 
  and so on.

Actually, the API can be used for all sorts of aggregation, notably,
if the underlying associations need to be kept in a particular sequence
and/or are volatile or temporary or experimental.

Benefits and Shortcomings
-------------------------

Although this facility carries an inherent inefficiency -
it creates a new *join table* row for each linkage -
it has the advantage of unobtrusiveness, that is,
of not affecting, in any way, the records it links.
They remain fully intact.

Note that there are plenty of other ways
to keep a discrete group of models in a specific order,
for example *ActiveRecord scopes* and third-party
facilities like *acts\_as\_list*.
In the majority of cases,
one of these will be more suitable than this facility,
which requires that each sequence be explicitly set up,
element by element.

An installation of this engine requires only one major change to your
existing environment, namely, the addition of an SQL migration
to create a table, *in\_order\_elements*.
The API is accessible from within its own engine,
which has no external dependencies apart from Rails.
This means that you can give it a try with
minimal setup and an easy rollback.

By far, the thorniest issue in using this facility
is getting rid of redundant associations.
A few ways to avert and rectify this are explained below.

Contents
--------

This engine consists of the following:

1. A single SQL table, *in\_order\_elements*.
2. An extensive API, which is composed of around two dozen Ruby classes.
3. Two REST controllers providing limited API access.
4. A prototype *Stimulus* module for a drag'n'drop list.

The last two items are quite specialised,
so are less likely to satisfy any specific requirements you have.

It was developed with *Ruby 2.6.0* and *Rails 5.2.3*.

API Introduction
----------------

The public API comprises of a dozen Ruby classes that provide
a full gamut of ways to manipulate the elements of a list.

Most of these classes perform a simple atomic operation,
and have only a few input parameters and options.

Sometimes, you may only need to call two of the supplied classes -
one to update and one to retrieve - *both short one-line calls*.

In more complicated cases,
you may need to make a few calls to these classes in succession.

> The *minitest* unit tests cover the API usage comprehensively,
> but these tests go into more detail than you'll need!

API Calls
---------

Although the API has lots of classes,
for the most part, they work in similar ways,
i.e. in the parameters they accept,
and in the tasks they perform (there is a fair degree of overlap).

Nearly all of the calls can be made in isolation
with a single (Ruby) statement,
and for most requirements,
you'll only need to use a small subset of the available classes.

They fall into three main categories:

1. To retrieve the elements of an existing list, by supplying a composite *key*.

2. To create or update a list as a whole, by supplying a composite *key*.

3. To change a list by dealing with individual elements.

Identifying Lists
-----------------

As said, many of the API calls require a special unique *key*,
which is used to access individual lists.

This *key* has two components:

1. An instance of an *ActiveRecord* model,
   or else a reference to one by some sort of pairing of
   a *type* name and an (SQL) *id*.

2. A string, which, in practice, will be a general classifier,
   such as the name of a section, group, branch, label, tag, etc..

You must give either one or both.

> Internally, the composite *key* is represented by the class,
> *InOrder::Aux::Keys* (aka *InOrder::Key*),
> but you shouldn't have to refer to this directly.
> Instead, you specify the actual *key* values as one or two parameters,
> which are passed to the constructor of the aforesaid class internally.

The Element Class
-----------------

This is an *ActiveRecord* model, which links the *key*
to an associated record.

#### Fields

Its name is *InOrder::Element*, and it has the fields:

1. *owner* which is the initial key component,
   it's a polymorphically referenced model.

2. *scope* which is the final key component,
   it's a string designating some kind of category.

3. *subject* which is a related record (usually one of many),
   it's also a polymorphically referenced model.

4. *element\_id* which points to the next Element of the list.

#### Scopes

For these four fields, there are corresponding
*(ActiveRecord) scope* definitions,
which are prefixed with **by_**.
So, for example, you can find elements that have a certain linked record with:

- `InOrder::Element.by_subject(subject)`

#### Class methods

Also, there are a number of class methods that
that return details about a list,
and others, with wider usefulness,
that delete an entire list in one go.

_What you're allowed to give as the **key** is explained below._

- To see a list's length, use something like:

  - `InOrder::Element.find_by_key(key).count`

- To retrieve a list's first or last item:

  - `InOrder::Element.first_element(key)`
  - `InOrder::Element.last_element(key)`

- To check if a list includes a particular model:

  - `InOrder::Element.has_subject?(key) { a_model_to_check }`

    You specify the model to look for in a block,
    this is because the *key* can be given as varied arguments.
    You can also specify a reference to a model with a *type &amp; id*
    partnership, these formats are shown below.

- Finally, to delete a complete list, you have a few choices:

  - `InOrder::Element.delete_elements(key)`
  - `InOrder::Element.delete_list(key)`
  - `InOrder::Element.by_keys(key).delete_all`

    The first deletes the elements one at a time,
    the last two are equivalent.

#### Iterator

Additionally, there is another class, `InOrder::Iterator.new(key)`,
that behaves like a regular Ruby *Enumerable*,
that is, the method *each* yields an *Element* in turn.
You could use this for random access with, say, an integer index (offset).
_Be restrained in using this, though, because it hits the database hard._

Retrieve List Items
-------------------

The principal API class to access a list is *InOrder::Fetch*,
which returns an Array of models, obviously, in the stated order.

_This does eager fetching of the linked models,
so reducing the request to a couple of SQL queries._

This API call takes just a *key* as input,
the following examples show the differing ways of specifying this.

**These different formats also apply to the other
API calls requiring a *key* as an input parameter.**

These invocations are all valid,
and, except for the last four, would all produce the same results:

- `InOrder::Fetch.new(User.find(999), 'friends').call`
- `InOrder::Fetch.new([ 'User', 999 ], 'friends').call`
- `InOrder::Fetch.new('User-999', 'friends').call`
- `InOrder::Fetch.new({ type: 'User', id: '999' }, 'friends').call`
- `InOrder::Fetch.new(owner: User.find(999), scope: 'friends').call`
- `InOrder::Fetch.new(InOrder::Key.new(User.find(999), 'friends')).elements`
- `InOrder::Fetch.new('User 999').call`
- `InOrder::Fetch.new(owner: 'User:999').call`
- `InOrder::Fetch.new(owner: { type: 'User', id: '999' }).call`
- `InOrder::Fetch.new(scope: 'friends').call`

The method *call* returns the linked records themselves.

If you want the linking Element records instead,
you use the method, *elements*, in place of *call*.

As said, the Element class has an instance method, *subject*,
which returns the linked record.

Create a List
-------------

When adding records to a list, you can give actual instances,
or give references like:

- `[ 'Type', 999 ]`
- `{ type: 'Type', id: 999 }`
- `"Type-999"`

### Adding multiple records at once

There are two classes for creating a list
with more than one associated record.
These are *InOrder::Create* and *InOrder::Update*,
the latter performs other tasks as well, and is explained later on.

- `InOrder::Create.new(User.find(999), 'friends').call(a_prepared_list_of_friends)`

If you make either of these API calls (*Create* or *Update*)
when a list (with an identical key) pre-exists,
then the new records will, by default, be appended to the original items,
that is, docked onto the end.
If the option, *append*, is set to *false*,
then the new items will be prepended instead, as in:

- `InOrder::Create.new(User.find(999), 'friends').call(a_prepared_list_of_friends, append: false)`

These methods return the linking Element records,
not the records that are actually linked.

And, importantly, for *Create* (but not *Update*) the returned list will not
include any of the items from a previous list - only the ones you just added.

> Be aware that you can only add *ActiveRecord* models as list item subjects.

### Adding a single record to a list

To add one new record to either the top or bottom of a list:

- `InOrder::Add.new(User.find(999), 'friends').call(a_friend)`

This will append *a\_friend* to an existing list.
If there's no list present already,
it'll become the first (and last) element.

To prepend the record, i.e. put it at the beginning:

- `InOrder::Add.new(User.find(999), 'friends').call(a_friend, at: top)`

You can also use the methods: *prepend* and *append*, in place of *call*.
The *at* option is omitted when invoking *prepend*, e.g.

- `InOrder::Add.new(User.find(999), 'friends').prepend(a_friend)`

These *Add* calls return the new *Element*, which wraps the added record,
but, by itself, this won't normally be useful.

Although you can add just one item in the *Create* call, mentioned above,
using *Add* is a bit more efficient,
and it has the following extra feature.

#### Adding a record in the middle

Also, but with less efficiency and more difficulty,
you can put a new item at any position by adding a block of custom code,
in which you step through the list to find a particular place to go.
Here's a rough contrived example:

```
  InOrder::Add.new(a_key).insert(a_record) do |iterator, a_record|
    # This returns the element that a_record will be put after
    iterator.find(iterator.first) do |element|
      element.subject == a_record
    end
  end
```
_As you can see, this is convoluted, so in nearly all cases
it'll be simpler to position a new item using *Insert*, shown below._

### *Singing and dancing* record addition

If you want, for instance,
to add one or more models to an existing list at the beginning,
to ensure that the list has a length no bigger than *6*,
and that no items re-occur, use:

- `InOrder::Update.new(User.find(999), 'friends').call(an_array_of_some_fiends, append: false, max: 6, uniq: true)`

This *Update* call will return the whole new list, as elements.
If you want the linked records instead, use *subjects* in place of *call*.

If *uniq* is given as *false* then any re-occurrences (in the original list)
of the added models will remain in place, (i.e. not be removed from the list).
The default setting is *true*, so be sure to specify (*uniq: false*) if
you want to keep repetitions.

Remove List Items
-----------------

As you'd expect, all of the following deletion operations only remove
the linking (wrapper) records, **never** the (underlying) records
that are linked together.

Likewise, if you delete a model that had been previously linked,
the (surviving) list *Element* will be left with a *dangling reference*,
i.e. it'll be an orphan, and be worse than useless,
as it may give rise to malfunctions or even fatal errors.

There are a number of straight-forward ways of preventing this,
(e.g. with *dependent: :destroy*, or inside of an *after\_destroy* callback),
but they do involve changing code of the model that's being linked.

In emergencies, you can search for and destroy these erroneous records, with:

- `InOrder::Repair.new.call`

If you wish to root them out without deleting, try:

- `InOrder::Repair.ic`

For ultra-caution, you can bolster your fetch requests
by sticking an integrity fix into the mix.
It'd go like something like this:

 - `InOrder::Fetch.new(User.find(999)).repair.call`

But this (*repair*) invocation is slow and only
really suggested as a stop-gap measure.

> A *subscribe and publish* mechanism, (activated on a model's destruction)
> would resolve this issue. *This may be added in future.*

### Deleting elements

Take note that removing an Element is not so simple as just deleting a
single row from the (elements) table.
Since there'll be a reference to the deleted Element
if a previous Element exists, and conversely,
the deleted Element might have a reference to a further element.

#### Delete by subject(s)

To drop elements from a *keyed* list that have an existing link
to one or more given models, (in this example, *enemies*):

- `InOrder::Purge.new(User.find(999), 'friends').remove(some_enemies)`

#### Mass destruction of elements

For the reason given directly above - on orphan eradication
*(Please don't presume I advocate this as social policy!)* -
when you delete the subject of a link,
you may want to make the following call alongside:

- `InOrder::Purge.delete_by_subject(a_deleted_model)`

This will unlink (and remove) all Elements that wrap *a\_deleted\_model*,
regardless of the lists the (deleted model's) Elements belong to.

### Discarding duplicates

To ensure that there are no two (linked) models the same in a given list:

- `InOrder::Purge.new(User.find(999), 'friends').uniq(keep_last: true)`

If the *keep_last* option is left out, or is *false*,
it'll retain the first occurrence of a repeated model in a given list.
The method *call* is an alias for *uniq*.

### Cutting a list down to size

Ensures that a list does not exceed a given maximum size (ceiling).

In this example, the maximum's *12*, the unwanted items are removed towards
the start, and not permanently dropped from the list:

- `InOrder::Trim.new(12, destroy: false, take_from: top).call(a_list_of_elements)`

Note that this call does not take an identifying *key* as input,
rather, it takes a list of *Elements*,
obtained by calling *InOrder::Fetch.new(a_key).elements*.

And also that the default is to remove the excess elements for good,
so you must add **destroy: false** to avoid this.

This call returns a new (duplicated and abridged) list of Elements.

#### Cutting down on the number of calls

To fetch and trim a list (temporarily), returning the linked records,
you may be tempted to try something like this:

```
  MAX = 12

  key = InOrder::Key.new(current_user, 'friends')

  elements = InOrder::Fetch.new(key).elements

  InOrder::Trim.new(MAX).call(elements, destroy: false).map(&:subject)
```

But you can achieve the same, with less verbosity *(sidestepping RSI)*,
using the shortcuts:

- `InOrder::Trim.set_max(12).call(current_user, 'friends')`

Whereupon the maximum will be temporarily stored,
obviating the need to call *set_max* again,
if you, soon afterwards, make a similar call, as in:

- `InOrder::Trim.(current_user, 'best-friends')`

Alternatively, to trim from the beginning
and with permanent element removal, you may use:

- `InOrder::Trim.call(current_user, 'friends') { [ 12, take_from: :top, destroy: true ] }`

Here, the default for *destroy* is flipped
(in the longer form it's *true*),
and the block returns the argument list given to Trim's constructor.

> These (Trim) calls raise an exception if you attempt to 'destroy',
> and you also give a list of items that aren't *Element* types.

Stacks and Queues
-----------------

These are typically data structures with a short lifespan.

In both of them, there is also a *peek* method that shows the next
item without making a removal.

### First in, first out

To add an item:

- `InOrder::Stack.new(User.find(999), 'friends').push(a_model)`

To retrieve an item:

- `InOrder::Stack.new(User.find(999), 'friends').pop

### First in, last out

To add an item:

- `InOrder::Queue.new(User.find(999), 'friends').join(Club.find(999))`

The method *join* has an alias of *add*.

To retrieve an item:

- `InOrder::Queue.new(User.find(999), 'friends').call

The method *call* has an alias of *leave* and *pull*.

### Fixed size

When you put a new item onto these lists,
you may specify, as a second argument,
a length that the list will not go beyond.
For example, `InOrder::Stack.new(key).push(model, 7)`.

> The behaviour of these two classes can be replicated
> using other API calls. They are for convenience.

Operations on List Elements
---------------------------

The following calls do not take a *key* as input to the constructor.
Here, you supply references to the individual Elements that make up a list.

Unlike the preceding, these calls give you full control over
the positioning of Elements in an existing list.

There are three parameters used to add or move a certain item:

1. *target* which is an actual Element that'll be moved or added.

2. *marker* is an Element that indicates the new position.

3. *adjacency* has a value of 'after' (default) or 'before',
   and says whether the *target* will go ahead of,
   or behind, the *marker* Element.

Both *target* and *marker* need to be instances of *InOrder::Element*,
or else be (SQL) *id's* of such.

### Moving an existing item

- `InOrder::Move.new(target, marker, adjacency).call`

### Positioning a new item

- `InOrder::Insert.new(target, marker, adjacency).call`

If you don't have the new record already wrapped in an Element,
which will be the most common case, use:

- `InOrder::Insert.call(a_model_to_be_linked, marker, adjacency)`

### Deleting an item

- `InOrder::Remove.new(target).call`

Controllers
-----------

There are two REST controllers included as well.
You can can use them for JSON output,
or to alter a list from an *Ajax* request.

However, at present the views they have,
in the engine's *dummy* Rails app,
are inaccessible from your own app, and besides they're crude,
but they may potentially be used as rough starter templates.

- *InOrder::ListsController* this accepts the said composite *key*
  as parameters, and will fetch a list and add &amp; delete items.

- *InOrder::ElementsController* this accepts Element id's as parameters
  and allows more control over the placement of Elements.
  The *drag'n'drop* list, outlined just below, uses this controller.

Generally, these controllers won't be need to be used as much as the,
already described, Ruby API, which is more direct, concise and flexible.

A Drag'n'Drop List
------------------

The engine has, hidden away,
a little *Stimulus* module that implements a *drag'n'drop* list.

This consists of three new files:

1. *test/dummy/app/javascript/controllers/drag\_drop\_controller.js*
2. *test/dummy/app/javascript/controllers/list\_controller.js*
3. *app/views/in\_order/lists/\_list.html.erb*

This code is minimal and will need changing.
The third probably a lot.
The second a bit as it shows debugging info.
The first probably won't need altering at all.

This list works in the engine's *dummy* testing Rails app,
which, for now, is where you'll have to go to extract these files.
If you decide to do this, get the source from:
[github.com/srycyk/in_order](https://github.com/srycyk/in_order)

> It's hard to package this up at present,
> since Rails is in flux over the way that JS assets are prepared,
> that is, whether they be handled by Sprockets or Webpacker.
> Also, it needs *Stimulus* installed - but not *jQuery*.

General Remarks
---------------

#### What's a linked list?

A broad definition of a *linked list* may go thus:
it's is a chain of elements,
each of which contain both a reference to an opaque data item,
and also a pointer to the next element in the sequence.
The final element typically has its pointer valued as null.

However, in this particular implementation,
the element also contains a *key*.

#### Polymorphic reliance

Purists may demur at the unabashed use of *polymorphic* types.

But since these (associative) records are, in this case,
the leaves of a tree, (never part of a branch),
there is next to no chance of untoward issues surfacing.
And the alternative of crafting every particular relationship with
literal *table* names is too long-winded,
and much more bother to develop and maintain.

#### Demonstration

Inside of the engine, in the sub-directory *test/dummy/*,
there's a Raila app.
Apart from supporting the tests, this app has some scaffolding code
added that allows you to link records together manually in web pages.
To have a go, `cd test/dummy/`, run migrations &amp; seed, `rails s`, etc..

#### Multiple databases

The table behind this model, *in\_order\_elements*,
could be put on a separate database,
but it'd make the eager fetching tricky.

But if you're going to use this facility just to gather statistics,
doing this would certainly boost the overall performance.

Getting Started
---------------

Add a *Gemfile* entry, with one of these:

```ruby
gem 'in_order'

gem 'in_order', git: 'https://github.com/srycyk/in_order'
```

And then execute:

```bash
$ bundle
```

Mount the engine in *config/routes.rb* with:

```ruby
  mount InOrder::Engine, at: "/in_order"
```

Copy the migration, from the engine, over into your own app:

```bash
$ rake in_order:install:migrations
```

And create the table, *in\_order\_elements*:

```bash
$ rake db:migrate
```

Getting Finished
----------------

Rollback migration (just for the engine):

```bash
$ rails db:migrate SCOPE=in_order VERSION=0
```

Delete the engine's migration file:

```bash
$ git rm db/migrate/*elements.in_order.rb
```

Remove the *Gemfile* entry.

Remove the *config/routes.rb* entry.

Then, to get back to where you started:

```bash
$ bundle
```

Licence
-------

The gem is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT).


Contributing
------------

Since this facility provides just one basic function,
(frankly, *it's a one-trick pony, flogged for all it's worth*),
it's unlikely that it will need extending or forking.
It's more a utility component to be used a building-block.


If you spot any bugs,
or if you have any issues, queries or suggestions,
please mail me at stephen.rycyk@googlemail.com

