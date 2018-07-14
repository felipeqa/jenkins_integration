Dado("que eu esteja na busca do bing") do
  visit "http://bing.com"
  #Comando visit indica qual pagina vc quer abrir
end

Quando("eu faço uma busca qualquer") do
  find("#sb_form_q").set "promobit"
  #find = busca na página ("#sb_form_q") = # + id do elemento .set = escreve "prommobit" = texto que eu quero que o capybara escreva
  #Logo essa linha significa = Busca esse elemnto por id e escreva promobit

  find("#sb_form_go").click
  #Aqui já é um pouco diferente
  #busca esse elemento por id e click nele
  #Dica eu sempre costumo buscar os elementos com o find e uso o .set para escrever ou o click para clicar
end

Então("eu recebo o resultado dessa busca") do
  assert_text("As Melhores Ofertas | Promoções")
end
