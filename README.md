# MWCrawler

Crawler do [Matricula Web - UnB](https://matriculaweb.unb.br/). 

Esse crawler expõe um endpoint GET `/course/:code`
onde o parametro `code` é o código do curso. Com esse código o crawler captura algumas informações como o currículo do curso desejado e os créditos necessários para formar.

Para usar esse sistema é necessário instalar elixir e então executar os comandos:

- `mix deps.get`
- `iex -S mix`

Depois é só acessar o endpoint em `localhost:4000/`
