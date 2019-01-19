
To install a specific package for python2.7 please use pip as follow:

	pip install --install-option="--prefix=/opt2/python27/" package_name 


### Autogtenerate requirements.nix

1- Install `pipreqs`: `pip install pipreqs`
2- Run: `pipreqs path/to/project`


### check if a key is is a dict: 

```python
if 'key' in dict:
   print bdm['key']
else:
   print "the key does not exist"
```
