# prefab-predicate-compat
(Racket) Backwards compatible prefab predicate function

In May 2018 the Typed Racket team made some important fixes to support for
prefab structs in Typed Racket (see the [RFC](https://github.com/racket/typed-racket/blob/master/rfcs/text/0001-prefab-structs.md)).

There were a few programs that relied on the previous, unsound behavior
of prefab predicates.

This package provides a function (`define-backwards-compatible-prefab-predicate`) 
which should work for old programs (in the same unsound way prefab predicates have worked) 
and should fix the soundness issues related to prefab predicates for new programs.

In other words, in Racket versions <= 6.90.0.28,

```
(define-backwards-compatible-prefab-predicate Foo? foo)
```

expands to:

```(define Foo? foo?)```

which relies on `foo?` having the old (unsound) predicate behavior (i.e. it doesn't
actually check what is in the fields of the struct, but tells the type system it
has more-or-less)

This is obviously not sound... but it's not any worse than the previous behavior
and it won't break programs relying on older versions of Racket/Typed Racket.


In Racket versions > 6.90.0.28,

```
(define-backwards-compatible-prefab-predicate Foo? foo)
```

expands to:

```(define-predicate Foo? foo)```


Which _is sound_, i.e. it generates a predicate for the type described by `foo`
if possible (i.e. it will work for any immutable prefab type `foo` that has
first-order data in its fields) and binds that predicate to `Foo?`.
