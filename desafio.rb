require 'date'

file = File.read('banco.txt')
registros = []

file.split("****\n***").each do |bloco|

  next if bloco.strip.empty?

  begin
    origem = bloco.match(/Origem:\s(.+)/)[1].strip
    data = bloco.match(/Data:\s(\d{2}-\d{2}-\d{4})\s+Hora:\s([\d:]+)/)
    duracao = bloco.match(/Duracao:\s(.+)/)[1].strip
    destino = bloco.match(/Destino:\s(.+)/)[1].strip

    data_hora = DateTime.strptime("#{data[1]} #{data[2]}", '%d-%m-%Y %H:%M:%S')

    registro = {
      origem: origem,
      data: data_hora,
      duracao: duracao,
      destino: destino
    }

    registros << registro

  rescue Date::Error => e
    puts "Erro ao processar a data/hora no bloco: #{bloco}"
    puts "Erro: #{e.message}"
  end
end

#Encontra a ligação mais antiga
l_antiga = registros.min_by { |registro| registro[:data] }
#Encontrar a ligação com mais duração
l_duracao = registros.max_by do |registro|
  registro[:duracao].match(/(\d+) minutos/)[1].to_i
end

#======================================================================================================
#Contabiliza o número de ligações por pessoa
contagem_origem = registros.each_with_object(Hash.new(0)) do |registro, contagem|
  contagem[registro[:origem]] += 1
end

contagem_destino = registros.each_with_object(Hash.new(0)) do |registro, contagem|
  contagem[registro[:destino]] += 1
end
#======================================================================================================

#======================================================================================================
#Cliente que ligou mais vezes
#Encontra a pessoa que ligou mais vezes
cliente_premium = contagem_origem.max_by { |_, quantidade| quantidade }
#======================================================================================================

#======================================================================================================
#Cliente que recebeu mais ligações
#Encontra a pessoa que ligou mais vezes
cliente_pai_de_santo = contagem_destino.max_by { |_, quantidade| quantidade }
#======================================================================================================

#======================================================================================================
#Tarifação
tarifacao = registros.each_with_object(Hash.new(0)) do |registro, tarifacao|
  minutos = registro[:duracao].match(/(\d+) minutos/)[1].to_i
  tarifacao[registro[:origem]] += (minutos * 0.80)
end
#======================================================================================================

#Resultados
puts "Ligação mais antiga:"
puts "Origem: #{l_antiga[:origem]} \nDestino:#{l_antiga[:destino]} \nData:#{l_antiga[:data]}"

puts "\nLigação com maior duracao: "
puts "Origem: #{l_duracao[:origem]} \nDestino:#{l_duracao[:destino]} \nDuração:#{l_duracao[:duracao]}"

puts "\nQuem ligou mais vezes:"
puts "#{cliente_premium[0]} com #{cliente_premium[1]} ligações."

puts "\nQuem mais recebeu ligações:"
puts "#{cliente_pai_de_santo[0]} com #{cliente_pai_de_santo[1]} ligações."

puts "\nTarifação por origem:"
tarifacao.each do |origem, valor|
  puts "#{origem}: R$ #{'%.2f' % valor}"
end
