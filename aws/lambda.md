To be able to use lambda with external libraries not present in aws basic ones, w need to ship the package to lambda in a zip format, follow these steps: https://docs.aws.amazon.com/lambda/latest/dg/python-package.html

To be able to directly write pandas dataframes to s3, use the follwing: https://stackoverflow.com/questions/53416226/how-to-write-parquet-file-from-pandas-dataframe-in-s3-in-python

```python
s3_url = 's3://bucket/folder/bucket.parquet.gzip'
df.to_parquet(s3_url, compression='gzip')
```

Ofc we need to install `fastparquet` and `s3fs`