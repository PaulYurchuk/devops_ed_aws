# Example of aws-sdk v.1 usage
## Prepare steps

- Add your AWS API Keys to `Dockerfile`
- Build container:

```
docker build -t aws-sdk-ruby:v1 .
```

- You can change `example.rb` 

## Run example

```
docker run -it --rm aws-sdk-ruby:v1
```
