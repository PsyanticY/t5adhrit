__Notes from : https://dbader.org/blog/python-dunder-methods .__
## Python With Dunder methods

In Python, special methods are a set of predefined methods you can use to enrich your classes. They are easy to recognize because they start and end with double underscores, for example `__init__` or `__str__`.

Dunder methods let you emulate the behavior of built-in types. For example, to get the length of a string you can call `len('string')`. But an empty class definition doesn’t support this behavior out of the box:

Examples:
```python
class NoLenSupport:
    pass

>>> obj = NoLenSupport()
>>> len(obj)
TypeError: "object of type 'NoLenSupport' has no len()"
```
->
```Python
class LenSupport:
    def __len__(self):
        return 42

>>> obj = LenSupport()
>>> len(obj)
42
```

=> This elegant design is known as the Python data model and lets developers tap into rich language features like sequences, iteration, operator overloading, attribute access, etc.

Use case example:

## Enriching a Simple Account Class

### Object Initialization: `__init__`:

To construct account objects from the Account class I need a constructor (the `__init__` function).

```Python
class Account:
    """A simple account class"""

    def __init__(self, owner, amount=0):
        """
        This is the constructor that lets us create
        objects from this class
        """
        self.owner = owner
        self.amount = amount
        self._transactions = []
```

The constructor create the object. To initialize a new account : `acc = Account('bob', 10)`

### Object Representation: `__str__`, `__repr__`:

 We usually provide a string representation of our object for the consumer of our class:
 - `__repr__`: The “official” string representation of an object. This is how you would make an object of the class. The goal of __repr__ is to be unambiguous.
- `__str__`: The “informal” or nicely printable string representation of an object. This is for the enduser.

-> If we need to implement just one of these to-string methods on a Python class, make sure it’s `__repr__`.

```python
def __repr__(self):
       return 'Account({!r}, {!r})'.format(self.owner, self.amount)

   def __str__(self):
       return 'Account of {} with starting amount: {}'.format(
           self.owner, self.amount)
```
If we don’t want to hardcode "Account" as the name for the class we can also use `self.__class__.__name__` to access it programmatically.

->
```python
>>> str(acc)
'Account of bob with starting amount: 10'

>>> print(acc)
"Account of bob with starting amount: 10"

>>> repr(acc)
"Account('bob', 10)"
```

### Iteration: `__len__`

In order to iterate over our account object I need to add some transactions. So first, I’ll define a simple method to add transactions.

->
```Python
def add_transaction(self, amount):
    if not isinstance(amount, int):
        raise ValueError('please use int for amount')
    self._transactions.append(amount)
```

We also need to define a property to calculate the balance on the account so I can conveniently access it with account.balance. This method takes the start amount and adds a sum of all the transactions:

```Python
@property
def balance(self):
    return self.amount + sum(self._transactions)
```

Dunder methods allows the class to be iterable:

```Python
def __len__(self):
    return len(self._transactions)

def __getitem__(self, position):
    return self._transactions[position]
```
now we can run these commands :
```python
>>> len(acc)
5

>>> for t in acc:
...    print(t)
20
-10
50
-20
30

>>> acc[1]
-10
```
Also to be able to iterate over the transaction in reverse mode we need to implement `__reversed__`.

## Others

Many other Dender methods can be implemented to ease the use of the classes:
- Operator Overloading for Comparing Accounts:  `__eq__`, `__lt__`.
- Operator Overloading for Merging Accounts:  `__add__`.
- Callable Python Objects: `__call__`.
- Context Manager Support and the With Statement:  `__enter__`, `__exit__`.

