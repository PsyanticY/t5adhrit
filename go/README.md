# resources


- Command line tutorial: https://itnext.io/how-to-create-your-own-cli-with-golang-3c50727ac608

# quick tips and tricks

- get list of keys of a map

	keys := reflect.ValueOf(subnetList).MapKeys()
	
- randomly pick an element from a list

	elem := keys[rand.Intn(len(keys))]

- cast value from a reflect list

	elem.Interface().(string)


