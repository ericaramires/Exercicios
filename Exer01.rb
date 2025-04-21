require 'terminal-table'

ficheiro=File.open("managedata.csv")
dados=ficheiro.read
ficheiro.close

linhas=dados.split("\n")
linhas = linhas[2..-1]

categorias=[]

for linha in linhas
  colunas=linha.split(";")
  if not categorias.include?(colunas[1]) and colunas[1] != nil  and colunas[1] != "Void" and colunas[1] != "Paycheck"
    categorias.push(colunas[1])
  end
end

totais = {}
for cat in categorias
  totais[cat] = [0.0] * 12
end

for linha in linhas
  colunas = linha.split(";")
  categoria = colunas[1]
  data = colunas[3]
  valor = colunas[5]

  if categoria != nil and data != nil and valor != nil
    begin
      mes = data.split("-")[1].to_i - 1
      valor_float = valor.gsub("$", "").gsub(",", ".").to_f
      totais[categoria][mes] += valor_float
    rescue
      next
    end
  end
end

meses = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"]
cabecalho = ["Categorias"] + meses + ["Totais"]
linhas_tabela = []

for categoria in categorias
  valores = totais[categoria]
  total = 0.0
  linha = [categoria]
  for i in 0..11
    linha.push(sprintf("%.2f€", valores[i]))
    total += valores[i]
  end
  linha.push(sprintf("%.2f€", total))
  linhas_tabela.push(linha)
end

tabela = Terminal::Table.new title: "Resumo por Categorias e Meses", headings: cabecalho, rows: linhas_tabela

puts tabela

File.open("tabela.txt","w") {|f| f.write(tabela)}
File.open("resultado.csv", "w") do |file|
  file.puts cabecalho.join(";")
  linhas_tabela.each { |linha| file.puts linha.join(";") }
end
