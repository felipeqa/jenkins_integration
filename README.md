<h1>Arquitetura do projeto</h1>

Executando seus Testes dentro de um container Docker
-------------------------

  Hj iremos aprender como executar seus testes em um container Docker!


<h3>1.Instalando o Docker</h3>
------------------------------------------------------------

Primeiramente, esse ambiente eu só montei em Windows 10 Pro 64-bits, de acordo com as minhas pesquisas existe outros meios de instalar o Docker em outras versões.
Os requisitos para a instalação são:

Arquitetura 64 bits

Versão Pro

Virtualização habilitada => Que vc consegue visualizar dentro de Gerenciador de Tarefas

![Passo 1](readme_images/Picture1.jpg?raw=true)

Aqui está o link para download do docker.

[Docker Download](https://store.docker.com/editions/community/docker-ce-desktop-windows)

Após a instalação reinicie seu computador.

Após reiniciar o seu  computador verifique se o Docker está rodando:

![Passo 2](readme_images/Picture2.jpg?raw=true)

Ou utilizando o seu cmd:

```bash
docker version
```

![Passo 3](readme_images/Picture3.jpg?raw=true)

<h3>2.Instalando o Docker em outras versões de Windows</h3>

<h4>Instalando com Docker Toolbox</h4>

Baixar o Docker Toolbox [Aqui!](https://download.docker.com/win/stable/DockerToolbox.exe)

Seu Windows deve ser 64-bits e ter a virtualização ativada.

O Docker Toolbox vai instalar tudo que é necessário para que você possa trabalhar com o Docker em seu computador, pois ele irá instalar também a Oracle VirtualBox, a máquina virtual da Oracle que vai permitir executar o Docker sem maiores problemas.

A diferença é que, quando você trabalha com o Docker for Windows, você pode utilizar o terminal nativo do Windows, já no Docker Toolbox, ele instalará o Docker Machine, que deverá ser utilizado no lugar do terminal nativo do Windows.

<h3>3.Clonando o projeto ou baixando</h3>

Se vc usa o CMDER sabe a estrutura para clonar um projeto

````bash
git clone https://github.com/felipeqa/docker_com_phantomjs.git
````

Senão, baixe o código em formato zip e extraia na pasta raiz C:/.

![Passo 4](readme_images/Picture4.jpg?raw=true)

<h3>4.Entendendo a estrutura de um Dockerfile</h3>

O Dockerfile é a nossa "receita de bolo" para criar um container de acordo com a nossa necessidade.

Sem me aprofundar muito, este nosso Dockerfile utiliza a versão Ruby 2.3, em uma versão linux Debian e também utilizamos o phantomJs para executar o teste em "Headless".

```Dockerfile

FROM ruby:2.3

MAINTAINER Felipe Rodrigues <felipe_rodriguesx@hotmail.com>

ENV app_path /opt/docker_com_phantomjs/
WORKDIR ${app_path}

COPY Gemfile* ${app_path}

RUN set -x \
&& apt-get update \
&& apt-get install -y wget libfontconfig1 \
&& rm -rf /var/lib/apt/lists/* \
&& wget -O /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 https://github.com/Medium/phantomjs/releases/download/v2.1.1/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
&& apt-get remove -y wget \
&& md5sum /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
| grep -q "1c947d57fce2f21ce0b43fe2ed7cd361" \
&& tar -xjf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /tmp \
&& rm -rf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
&& mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs \
&& rm -rf /tmp/phantomjs-2.1.1-linux-x86_64 \
&& gem install bundler \
&& bundle install


COPY . ${app_path}

ENTRYPOINT ["bundle", "exec", "cucumber"]

```

<h4>Detalhando brevemente nosso Dockerfile:</h4>

FROM é nossa imagem base.

MAINTAINER é mera formalidade.

ENV são variáveis de ambiente.

WORKDIR é o nosso diretório onde iremos trabalhar (WORKING DIRECTORY).

COPY é para copiar o nosso Gemfile para a pasta que definimos.

Agora temos um grande bloco onde são executadas algumas instruções e também a instalação do phantomjs.

COPY para copiar novamente

ENTRYPOINT é o comando que eu quero executar quando eu rodar o container

<h3>5.Executando os testes</h3>

Agora iremos rodar nossos testes dentro do container.

Primeiro, na pasta raiz do projeto temos que buildar essa imagem:

```bash
docker build -t cucumber/cucumber .
```

![Passo 5](readme_images/Picture5.jpg?raw=true)

As dependências vão ser baixadas:

![Passo 6](readme_images/Picture6.jpg?raw=true)

E os comando serão executados:

![Passo 7](readme_images/Picture7.jpg?raw=true)

![Passo 8](readme_images/Picture8.jpg?raw=true)

![Passo 9](readme_images/Picture9.jpg?raw=true)

![Passo 10](readme_images/Picture10.jpg?raw=true)

Após o build com sucesso, vamos olhar nossas imagens:

```bash
docker images
```

![Passo 11](readme_images/Picture11.jpg?raw=true)

Agora iremos rodar nossos teste:

docker run <id_da_image>

No meu caso o IMAGE ID é: 248017b7511b

```bash
docker run 248017b7511b
```

Teste executado com sucesso:

![Passo 12](readme_images/Picture12.jpg?raw=true)

Mas.... Somos QA neh? Vamos ver se isso está correto mesmo?

Vamos alterar nosso arquivo teste_steps.rb, alterar o nosso assert_text.

De:

```rb
assert_text("As Melhores Ofertas | Promoções")
```

Para:

```rb
assert_text("Eu sou QA, meu papel é evitar Bug")
```

![Passo 13](readme_images/Picture13.jpg?raw=true)

Agora vamos buildar uma nova imagem, com a nossa alteração do assert_text:


```bash
docker build -t cucumber/assert_error .
```

Como já temos as dependências, o build vai ser rápido.

![Passo 14](readme_images/Picture14.jpg?raw=true)

Agora vamos pegar o IMAGE ID, com o comando :

```bash
docker images
```

![Passo 15](readme_images/Picture15.jpg?raw=true)

Agora iremos rodar esse teste dentro da nova imagem:

docker run <id_da_image>

No meu caso o IMAGE ID é: 73a879b069af

```bash
docker run 73a879b069af
```

EEEEEhhhhhhhhhh?

![Passo 16](readme_images/Picture16.jpg?raw=true)

O teste quebrou, pois não encontrou o texto " Eu sou QA, meu papel é evitar Bug"

SENSACIONAL neh?

Então é isso aí galera, por hoje é só!

Estou trabalhando no rbenv for Windows e quanto estiver pronto lanço para vcs.

Espero que gostem. Um grande abraço.

Contato
-------
Estou aberto a sugestões, elogios, críticas ou qualquer outro tipo de comentário.

*	E-mail: felipe_rodriguesx@hotmail.com.br
*	Linkedin: <https://www.linkedin.com/in/luis-felipe-rodrigues-de-oliveira-2b056b5a/>

Licença
-------
Esse código é livre para ser usado dentro dos termos da licença MIT license.
