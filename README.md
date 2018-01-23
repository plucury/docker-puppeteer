Docker Puppeteer
===

Combined https://github.com/zenato/puppeteer-renderer and https://github.com/cheeaun/docker-puppeteer


## Getting Started

`docker build -t docker-puppeteer .`

`docker run -it -p 8080:3000 -v {your src html file dir}:/input docker-puppeteer`

`http://127.0.0.1:8080/?url=file:///input/test.html&outputType=pdf`