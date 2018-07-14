Dado(/^que eu queira saber os detalhes do endereço de um cep válido "([^"]*)"$/) do |cepValido|
	@response = HTTParty.get("http://correiosapi.apphb.com/cep/#{cepValido}")
end

Quando(/^eu receber a resposta da API$/) do
	puts @response
end


Então(/^devo validar cep, tipo de logradouro, logradouro, bairro, cidade,estado e o response code.$/) do
	expect(@response.code).to eq(200)
	expect(@response['cep']).to eq('06342080')
	expect(@response['tipoDeLogradouro']).to eq('Rua')
	expect(@response['logradouro']).to eq('Maria José Ferreira')
	expect(@response['bairro']).to eq('Jardim Helena')
	expect(@response['cidade']).to eq('Carapicuíba')
	expect(@response['estado']).to eq('SP')
end

Dado(/^que eu queira saber os detalhes da resposta de um cep inválido "([^"]*)"$/) do |cepInvalido|
@response = HTTParty.get("http://correiosapi.apphb.com/cep/#{cepInvalido}")
end

Então(/^devo validar mensagem de erro e o response code\.$/) do
	expect(@response.code).to eq(404)
	expect(@response['message']).to eq ('Endereço não encontrado!')
end
