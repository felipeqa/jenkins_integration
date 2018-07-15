#encoding: utf-8
#language: pt
@all
Funcionalidade: API Correios CEP
Utilizando um CEP válido, essa API retorna todos os detalhes de um endereço para aquele CEP.
@cepvalido @backend
Cenário: Buscar CEP válido
Dado que eu queira saber os detalhes do endereço de um cep válido "06342080"
Quando eu receber a resposta da API
Então devo validar cep, tipo de logradouro, logradouro, bairro, cidade,estado e o response code.

@cepinvalido @backend
Cenário: Buscar CEP inválido
Dado que eu queira saber os detalhes da resposta de um cep inválido "78912800"
Quando eu receber a resposta da API
Então devo validar mensagem de erro e o response code.
