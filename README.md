# IA AWS Instance

AI APIs are great. You can experiment with them, integrate them into your apps, and probably do a bunch of other things I haven’t even started to think about. But there’s a catch: all the ones I found are either paid or have an incredibly low usage limit. So, if you have some AWS credits to burn, this might help you out. And if you don’t, [ask for them!](https://pages.awscloud.com/GLOBAL_NCA_LN_ARRC-program-A300-2023.html)  

This Terraform script deploys an EC2 instance with Ollama and all the necessary infrastructure to use the Ollama API from the internet with a basic level of authentication. This is not a production-ready script, but it can be a good starting point.  

## Pre-requisites
- An AWS account with some funds to burn
- An AWS user with an appropriate permission policy to manage EC2s instances, VPCs and DNS records
- [The AWS cli installed and set up](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [The Terraform cli installed and set up](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [An SSH key generated WITHOUT A PASSPHRASE](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- (Comming soon!) A domain

## Before deployment
1. Create your `terraform.tfvars` file from the example:
  ```bash
  cp terraform.tfvars.example terraform.tfvars
  ```
2. Update the AWS profile, instance names, and both SSH key paths to match yours.
3. Create your secret.tfvars file from the example:
  ```bash
  cp secret.tfvars.example secret.tfvars
  ```
4. Generate your API token and append it to secret.tfvars. The key must be enclosed in double quotes:
  ```bash
   openssl rand -base64 32
  ```
5. Initialize Terraform:
  ```bash
    terraform init
  ```

## How to deploy
From here, it’s all pretty straightforward. The only difference from other Terraform projects is that we’re adding the API key secret manually.

1. List all elements to be deployed:
  ```bash
  terraform plan -var-file="secret.tfvars"
  ```
2. Then deploy them:
  ```bash
  terraform apply -var-file="secret.tfvars"
  ```
The deployment will output your instance public ip. Save it for later.

3. And at some point, destroy them:
  ```bash
  terraform destroy -var-file="secret.tfvars"
  ```

## Testing the deployment
If everything went well, you should be able to hit the Ollama API using your API key. Here’s a simple script to test connectivity and functionality from the terminal:
  ```bash
  curl http://<instance_public_ip>/api/chat \
    -H "Authorization: Bearer <api_key>" -d '{
      "model": "tinyllama",
      "messages": [
        {
          "role": "user",
          "content": "why is the sky blue?"
        }
      ],
      "stream": false
    }'
  ```

## Debugging
If your requests aren’t working, you can log into the instance via SSH and check the Ollama and Nginx process statuses and configurations:
  ```bash
  ssh -i <ssh_private_key_path> ec2-user@<instance_public_ip>
  ```

## How to use
I'm using the [OpenAI Node](https://github.com/openai/openai-node) package to interact with the API because the configuration is quite simple:

```js
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'http://<public_ip>/api',
  apiKey: '<api_key>',
});

async function main() {
  const chatCompletion = await client.chat.completions.create({
    messages: [{ role: 'user', content: 'Say this is a test' }],
    model: 'tinyllama',
  });
}

main();
```

Enjoy!

## What's comming
- Domain and SSL support
- User configuration
- Some proper key management would be nice
