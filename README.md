<h1>Arquitetura do projeto</h1>

Integrando seus Testes Automatizados no Jenkins usando containers Docker
-------------------------

  Esse projeto é para vc QA que já faz automação na sua empresa e ainda não integrou ao seu ambiente de CI/CD, no caso aqui utilizaremos o Jenkins.
  O intuito desse post e mostrar como integrar os testes no Jenkins e não como configurar o ambiente com Jenkins e Docker.


<h3>1. O que precisamos?</h3>

* Jenkins: [Jenkins Info](https://jenkins.io/)
* Docker: [Docker info](https://www.docker.com/)
* Cucumber Reports Plugin for Jenkins [Cucumber Reports](https://wiki.jenkins.io/display/JENKINS/Cucumber+Reports+Plugin)
* PowerShell Plugin for Jenkins [PowerShell for Jenkins](https://wiki.jenkins.io/display/JENKINS/PowerShell+Plugin)


<h3>2. Vamos começar? </h3>

Primeiramente vou mostrar como integrar os teste no Jenkins usando scripts feito em PowerShell.


<h3>3. Executando o projeto localmente </h3>

Vamos começar executando os testes localmente:

```bash
cucumber
```

![Passo 1](readme_images/Picture1.jpg?raw=true)


Agora vamos executar o mesmo teste só que vamos utilizar uma variável de ambiente chamada BROWSER:

```bash
cucumber BROWSER=remote
```

![Passo 2](readme_images/Picture2.jpg?raw=true)

Opa parece que aconteceu algo estranho aqui:

```
 invalid byte sequence in UTF-8 (ArgumentError)
```

Vamos entender melhor isso abrindo o arquivo env.rb .

![Passo 3](readme_images/Picture3.jpg?raw=true)

Como podemos ver, ao passar a variável BROWSER=remote ele cai no if BROWSER.eql?('remote')

```
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :desired_capabilities => :chrome,
    :url => "http://selenium-hub:4444/wd/hub"
  )
end
```

Onde eu registro o driver utilizado e passo alguns parâmetros, o mais diferente deles é o url.

Da onde surgiu essa url?

Daqui a pouco descobriremos.

<h3>4. Criar um Dockerfile com Ruby</h3>

Agora vamos começar a montar a nossa Arquitetura:

Primeiro vamos montar um Dockerfile:

![Passo 4](readme_images/Picture4.jpg?raw=true)


<h3>5. Entendendo a estrutura de um Dockerfile</h3>

O Dockerfile é a nossa "receita de bolo" para criar um container de acordo com a nossa necessidade.


```Dockerfile
FROM ruby:2.3

MAINTAINER Felipe Rodrigues <felipe_rodriguesx@hotmail.com>

ENV app_path /opt/jenkins/
WORKDIR ${app_path}

COPY Gemfile* ${app_path}

RUN bundle install


COPY . ${app_path}

ENTRYPOINT ["bundle", "exec", "cucumber -p ${BROWSER} -p ${TAG}  --format json -o /opt/jenkins/cucumber.json"]
```

<h4>Detalhando brevemente nosso Dockerfile:</h4>

FROM é nossa imagem base no caso ruby:2.3

MAINTAINER é mera formalidade.

ENV é utilizado para criar variáveis de ambiente, no caso foi criada a variável app_path com o path /opt/jenkins/

WORKDIR é o diretório onde quando o container for executado ele vai executar o comando do ENTRYPOINT nesse diretório (WORKING DIRECTORY).

COPY é para copiar o nosso Gemfile para a pasta que definimos, no caso app_path que representa /opt/jenkins/

RUN é para colocar comandos na hora de fazer o build da imagem, nesse caso usamos o bundle install

COPY para compiar tudo do diretória atual (.ponto) para a pasta o path app_path

ENTRYPOINT é o comando que eu quero executar quando eu rodar o container

Agora que temos o Dockerfile com Ruby, vamos começar o nosso script de setup:


<h3>6. Script setup powershell</h3>

Para executar nossos teste dentro de containers, nós vamos precisar de dois containers, correto?

* Primeiro, um com o Ruby. (Opa, esse já criamos a receita dele com o Dockerfile)
* Segundo, um que tenha o chrome, chromedriver e tudo que for necessário (Iiii, e agora?)

Como não vamos inventar a roda novamente, vamos fazer o seguinte:

Vamos visitar o Docker Hub e pesquisar por selenium:

Docker Hub Selenium [Docker Selenium Link](https://hub.docker.com/r/selenium/standalone-chrome/)

GitHub Selenium [Git Link](https://github.com/SeleniumHQ/docker-selenium)

Veremos uma infinidade de opções e vamos utilizar a imagem selenium/standalone-chrome

[Selenium Standalone](https://github.com/SeleniumHQ/docker-selenium/tree/master/StandaloneChrome)

Fica como exercício dar uma lida nesses três links.

Vamos agora criar o nosso arquivo setup.ps1, esse arquivo foi criado na pasta script

```powershell
docker rm -f container-ruby
docker rm -f selenium-hub
docker pull  selenium/standalone-chrome
docker run -d -p 4444:4444 --name selenium-hub selenium/standalone-chrome
docker build -t cucumber/cucumber .
```

Aqui é basicamente o seguinte:

* As duas primeiras linhas removem os containers com os nomes container-ruby e selenium-hub caso ele exista.
* A terceira faz download ou atualiza a imagem selenium/standalone-chrome.
* A quarta linha inicializa o container e o nomeia como selenium-hub na porta 4444
* A quinta linha faz o build do nosso Dockerfile criando uma imagem o nome de cucumber/cucumber

<h4>Selenium-hub?</h4>

Sim, lembra da nossa url (http://selenium-hub:4444/wd/hub) no nosso arquivo env.rb?

Então, ela é o nome do nosso container mais a porta que ele roda.

Como exercício execute o comando no seu ambiente local (se vc tiver o docker instalado na sua máquina):

```bash
docker run -d -p 4444:4444 --name selenium-hub selenium/standalone-chrome
```

Agora vá em localhost:4444 e clique no link console.

![Passo 5](readme_images/Picture5.jpg?raw=true)

<h3>7. Script test powershell</h3>

Depois que aprendemos um pouco sobre o script de setup, vamos agora criar o script que dispara os testes chamado test.ps1:

```bash
Param(
  [string]$BROWSER,
  [string]$TAG
)
docker run -v "$(pwd):/opt/jenkins" -e BROWSER=$BROWSER -e TAG=$TAG -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm -f container-ruby
docker rm -f selenium-hub
```

Aqui basicamente é o seguinte:
* Recebemos dois parâmetros $BROWSER e $TAG
* Depois executamos o container com o nome de container-ruby a partir da nossa imagem cucumber/cucumber, criamos um volume, fazemos um link com o container selenium-hub, esse link é o que faz o dois containers conversarem entre eles.
* Depois removemos os dois containers

Feito isso temos os dois scripts configurados.

<h3>8. Validar os scripts localmente</h3>

Até agora muito legal neh? Mas agora vamos ver se isso funciona de fato?

Então vamos validar se o script realmente funciona, primeiro abra o powershell:

![Passo 6](readme_images/Picture6.jpg?raw=true)

Vamos rodar primeiro o script que faz o setup:

```bash
 powershell -File .\script\setup.ps1
```

![Passo 7](readme_images/Picture7.jpg?raw=true)

![Passo 8](readme_images/Picture8.jpg?raw=true)

O setup como podemos ver funcionou, sem problemas.

Agora vamos rodar o script que realmente faz os teste, faz o link do meu container ruby com o selenium-hub:

```bash
powershell -File .\script\test.ps1
```

![Passo 9](readme_images/Picture9.jpg?raw=true)

Opa, parece que deu algo errado! ELe não encontrou nenhum profile.

Pois é, lembra que o nosso script de test.ps1 recebia dois parâmetros? $BROWSER e $TAG, então temos que passar esses parâmetros para que o script funcione corretamente, como o script remove os containers container-ruby e selenium-hub, teremos que fazer o setup novamente.

```bash
 powershell -File .\script\setup.ps1
```

![Passo 7](readme_images/Picture7.jpg?raw=true)

![Passo 8](readme_images/Picture8.jpg?raw=true)

Setup feito novamente, agora vamos criar esses parâmetros.

```bash
$BROWSER = 'remote'
$TAG = 'all'
```

Execute esse dois comandos no seu powershell

![Passo 10](readme_images/Picture10.jpg?raw=true)

Agora vamos executar o script test.ps1 e validar se funciona realmente, só que faremos uma pequena alteração que é passar os dois parâmetros que acabamos de definir:

```bash
powershell -File .\script\test.ps1  $BROWSER $TAG
```

![Passo 11](readme_images/Picture11.jpg?raw=true)

Opa, aparentemente tudo ok!

Agora vamos recapitular novamente e entender como tudo aconteceu.

Aqui são todos os comando existentes em nosso dois script:

```bash
#setup.ps1
docker rm -f container-ruby
docker rm -f selenium-hub
docker pull  selenium/standalone-chrome
docker run -d -p 4444:4444 --name selenium-hub selenium/standalone-chrome
docker build -t cucumber/cucumber .
#Params
$BROWSER = 'remote'
$TAG = 'all'
#test.ps1
Param(
  [string]$BROWSER,
  [string]$TAG
)
docker run -v "$(pwd):/opt/jenkins" -e BROWSER=$BROWSER -e TAG=$TAG -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm -f container-ruby
docker rm -f selenium-hub
```

Vamos ligar cada comando a sua ação agora:

* docker rm -f container-ruby => remove o container com o nome "container-ruby" caso ele exista
* docker rm -f selenium-hub => remove o container com o nome "selenium-hub" caso ele exista
* docker pull  selenium/standalone-chrome => faz o download da imagem selenium/standalone-chrome ou atualiza caso esteja desatualizada
* docker run -d -p 4444:4444 --name selenium-hub selenium/standalone-chrome => esse comando é responsável por subir o container com o nome selenium-hub na porta 4444
* docker build -t cucumber/cucumber . => esse comando é responsável por fazer o build da nossa imagem cucumber/cucumber a partir do nosso Dockerfile o '.(ponto)', significa que o Dockerfile está no diretório atual, ou seja! Na raiz do projeto.
* Param => são aqueles parâmetros que criamos no terminal e depois passamos $BROWSER e $TAG par o script test.ps1
* docker run -v "$(pwd):/opt/jenkins" -e BROWSER=$BROWSER -e TAG=$TAG -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber => Esse comando faz bastante coisa, vamos quebrar ele por partes:

```
-v "$(pwd):/opt/jenkins"
Mapeia um volume dentro do container /opt/jenkins para o nosso host $(pwd), ou seja se o meu container criar qualquer arquivo nessa pasta, como cucumber.json ou os prints dos testes esses arquivos serão disponibilizados no meu host.
```

```
-e BROWSER=$BROWSER -e TAG=$TAG
Aqui são os exports de variavéis de ambiente, ou seja, quando setamos $BROWSER = 'remote' e $TAG = 'all', automaticamente esse esse trecho do comando fica assim:
-e BROWSER=remote -e TAG=all => Agora vou mostrar onde isso é utilizado, no nosso Dockerfile existe um comando chamado ENTRYPOINT:
ENTRYPOINT ["bundle", "exec", "cucumber -p ${BROWSER} -p ${TAG}  --format json -o /opt/jenkins/cucumber.json"] => quando fazemos esse export esse comando dentro do nosso container é executado assim:
ENTRYPOINT ["bundle", "exec", "cucumber -p remote -p all  --format json -o /opt/jenkins/cucumber.json"] ou seja, passamos como variavéis de ambiente
E como podemos ver existe uma saída chamada cucumber.json para o path /opt/jenkins/ ou seja a pasta que mapeamos um volume, então no final da execução teremos esse arquivo salvo no nosso host.
```
Olhando nosso arquivo cucumber.yml veremos que tanto remote e all são profiles definidos lá! Por isso quando executamos o script sem os parâmetros os profiles não foram encontrados:

![Passo 9](readme_images/Picture9.jpg?raw=true)

```
--name container-ruby => é somente para nomear o container
```

```
--link selenium-hub:selenium-hub => esse trecho é responsável por fazer o link entre o container container-ruby e selenium-hub, ele faz os dois containers conversarem entre si
```

```
cucumber/cucumber é a partir dessa imagem que estamos executando o docker run -v "$(pwd):/opt/jenkins" -e BROWSER=$BROWSER -e TAG=$TAG -P --name container-ruby  --link selenium-hub:selenium-hub, essa imagem é aquela que contruimos com o build do Dockerfile
```

* docker rm -f container-ruby => remove o container com o nome "container-ruby" caso ele exista
* docker rm -f selenium-hub => remove o container com o nome "selenium-hub" caso ele exista

OBS: Vc não precisa criar um script PowerShell ou Shell Script para integrar seus teste no Jenkins, vc pode colocar comando a comando no build do Jenkins que o resultado é o mesmo!

Ou seja, executar esses comandos de forma sequencial:

```bash
docker rm -f container-ruby
docker rm -f selenium-hub
docker pull  selenium/standalone-chrome
docker run -d -p 4444:4444 --name selenium-hub selenium/standalone-chrome
docker build -t cucumber/cucumber .
$BROWSER = 'remote'
$TAG = 'all'
docker run -v "$(pwd):/opt/jenkins" -e BROWSER=$BROWSER -e TAG=$TAG -P --name container-ruby  --link selenium-hub:selenium-hub cucumber/cucumber
docker rm -f container-ruby
docker rm -f selenium-hub
```

O resultado é o mesmo que os scripts!

![Passo 40](readme_images/Picture40.jpg?raw=true)

![Passo 41](readme_images/Picture41.jpg?raw=true)

Agora que entendemos um pouco sobre cada comando vamos listar os comando executados:

Script setup:

```bash
powershell -File .\script\setup.ps1
```

Variavéis de Ambiente:

```bash
$BROWSER = 'remote'
$TAG = 'all'
```

Script test:

```bash
powershell -File .\script\test.ps1  $BROWSER $TAG
```

Sabendo que isso é o suficiente para os nossos testes localmente usando docker, vamos simplesmente passar esses comando para o Jenkins:

<h3>9. Criando um Job no Jenkins</h3>

Primeiramente vamos acessar o Jenkins:

![Passo 12](readme_images/Picture12.jpg?raw=true)

Agora clicar em Novo Job:

![Passo 13](readme_images/Picture13.jpg?raw=true)

Vamos chamar de jenkins-ci e selecionar a opção Construir um projeto de software free-style e clicar em ok.

![Passo 14](readme_images/Picture14.jpg?raw=true)

Agora vamos fazer a primeira configuração, vamos só fazer com que o job faça um clone e atualize do github:

![Passo 15](readme_images/Picture15.jpg?raw=true)

Vamos salvar esse job:

![Passo 16](readme_images/Picture16.jpg?raw=true)

Agora vamos clicar em Construir Agora e ver o que acontece:

![Passo 17](readme_images/Picture17.jpg?raw=true)

Opa, parece que não aconteceu muita coisa, vamos olhar no detalhe:

* Clicar no job 1.

![Passo 18](readme_images/Picture18.jpg?raw=true)

Agora vamos olhar o log, clicar em saída do console:

![Passo 19](readme_images/Picture19.jpg?raw=true)

Até agora tudo bem, vamos ver o que temos de arquivo na nossa worspace, clicar em jenkins-ci no header da página:

![Passo 20](readme_images/Picture20.jpg?raw=true)

Agora clicar em Workspace:

![Passo 21](readme_images/Picture21.jpg?raw=true)

Legal, todos os meus arquivos dos projeto estão aqui. Agora vamos configurar o que o nosso job deve fazer:

* Vamos até a área de build e adicionar um passo no build do tipo Windows PowerShell:

![Passo 22](readme_images/Picture22.jpg?raw=true)

Agora vamos adicionar aqueles comando que validamos quando executamos localmente:

Script setup:

```bash
powershell -File .\script\setup.ps1
```

Variavéis de Ambiente:

```bash
$BROWSER = 'remote'
$TAG = 'all'
```

Script test:

```bash
powershell -File .\script\test.ps1  $BROWSER $TAG
```

Quando adicionamos o step Windows PowerShell, estamos de fato montando um script que será executado como PowerShell pelo próprio Jenkins:

![Passo 23](readme_images/Picture23.jpg?raw=true)

Agora vamos configurar um pós build, ou seja, depois que o Jenkins executar esse bloco de PowerShell ele vai executar esse pós build, e esse pós build é sensacional, estou falando do cucumber reports!

Lembra que quando eu rodo o segundo container eu também mapeio um volume? E também disse que após o final do teste ele cria um arquivo chamado cucumber.json e uma pasta com os prints dos testes. Então, vamos configurar o cucumber reports para ver isso acontecer.

![Passo 24](readme_images/Picture24.jpg?raw=true)

Vamos apenas alterar o Build Status para Failure caso aconteça qualquer erro!

![Passo 25](readme_images/Picture25.jpg?raw=true)

Agora vamos salvar e executar novamente (clicar em Construir Agora) e dar uma olhada no log de saída:

![Passo 26](readme_images/Picture26.jpg?raw=true)

![Passo 27](readme_images/Picture27.jpg?raw=true)

![Passo 28](readme_images/Picture28.jpg?raw=true)

![Passo 29](readme_images/Picture29.jpg?raw=true)

Opa, parece que deu certo!

Vamos clicar no job e ver se criou com sucesso o cucumber reports?

* Vamos clicar no Job 5.

![Passo 30](readme_images/Picture30.jpg?raw=true)

Agora vamos clicar no Cucumber reports.

MINHA NOSSA! QUE BRUXARIA É ESSA!!!!!!

![Passo 31](readme_images/Picture31.jpg?raw=true)

Aqui o print do teste de frontend:

MINHA NOSSA! QUE BRUXARIA É ESSA!!!!!!

![Passo 32](readme_images/Picture32.jpg?raw=true)

O Cucumber reports oferece muitos reports:

![Passo 33](readme_images/Picture33.jpg?raw=true)

Agora vamos olhar o nosso Workspace:

![Passo 34](readme_images/Picture34.jpg?raw=true)

Como podemos ver foi criado um arquivo chamado cucumber.json e também uma pasta chamada prints com o print do teste.

Agora vamos fazer uma pequena alteração, alterar o parâmetro $TAG do nosso job e usar outro profile, agora vamos usar o profile frontend.

Clicar em configurar e alterar $TAG = 'all' para $TAG = 'frontend' :

![Passo 35](readme_images/Picture35.jpg?raw=true)

Clicar em salvar.

E agora vamos executar o job novamente:

![Passo 36](readme_images/Picture36.jpg?raw=true)

Como podemos ver sucesso.

![Passo 39](readme_images/Picture39.jpg?raw=true)

Vamos ver o cucumber reports?

![Passo 37](readme_images/Picture37.jpg?raw=true)

Como podemos ver alteramos a tag e executamos apenas o teste de frontend.

![Passo 38](readme_images/Picture37.jpg?raw=true)

Então galera é isso!

Essa é apenas a primeira parte do post!

Vou fazer a segunda parte utilizando shell script e também a criar um build parametrizado. Se vc olhar a pasta script do projeto, vc pode ver que os scripts são bem parecidos.

A ideia principal desse post é que se vc consegue executar seus testes por linha de comando localmente utilizando docker então vc consegue integrar isso ao seu CI/CD.

Espero que essa ideia possa ajudar vcs no dia-a-dia!

Até o próximo!!!!!

Contato
-------
Estou aberto a sugestões, elogios, críticas ou qualquer outro tipo de comentário.

*	E-mail: felipe_rodriguesx@hotmail.com.br
*	Linkedin: <https://www.linkedin.com/in/luis-felipe-rodrigues-de-oliveira-2b056b5a/>

Licença
-------
Esse código é livre para ser usado dentro dos termos da licença MIT license.
