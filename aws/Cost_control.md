# Steps and plans to aws cost control

### Tagging

1- Defining tags and enforcing applyin gthem to all resources
2- Report on missing tags and making sure to tag untagged resources
3- report on underutilized instances resources
    - EC2 Instance cpu compared to a threshold, memory , disk usage
    - Volumes, 
4- Report on unused Volumes ( tag the needed one  nad delete the others)
5- Report on snapshots and their age
6- Automatically remove unneeded volumes and too old snapshots
7- Report on on demand vs spot instances
8- Report on unused instances durin gthe night
9- Report on stopped instances and how long where they stopped

### Spot on demand and saving plans

1- Categorize workloads into spot tolerant and on demand required
2- if there is some non critical workloads that are not time sensitives, we try using spot for that with a clear and easy recovery method
3- Push the use of Spot for all workloads in the dev category
4- Make sure to use savings plan as needed

### S3

1- Make sure to put data into different storage types based on use
2- data in Galcier must be of a certain size ( if they are less then a certain threshold keepin gthem in standard would be cheaper)
3- Archive data in S3 as needed
4- put data in deep archive if needed

### Budget control

Make sure Accounts have thresholds they should not exceed ( not a fan of this though )


### Others 

The idea behind tagging is that people are aware of the resources they provision and are responsible for them
