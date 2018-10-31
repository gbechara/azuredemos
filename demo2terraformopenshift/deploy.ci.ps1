docker run --rm -it `
  --volume "c:\Users\gabechar\OneDrive - Microsoft\msft\azuredemos\demo2terraformopenshift:/demo2terraformopenshift" `
  --workdir /demo2terraformopenshift  `
  --entrypoint "/bin/sh" `
  hashicorp/terraform:light `
  -c "/bin/terraform init; \
      /bin/terraform validate; \
      /bin/terraform plan -out=out.tfplan; \
      /bin/terraform apply out.tfplan;"
