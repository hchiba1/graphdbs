#!/usr/bin/env ruby

input_file = ARGV[0]
unless input_file
  puts "Usage: #{File.basename($0)} <input_file>"
  exit 1
end
unless File.exist?(input_file)
  puts "Error: cannot open '#{input_file}'"
  exit 1
end

puts '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .'
puts '@prefix dct: <http://purl.org/dc/terms/> .'
puts '@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .'
puts '@prefix ncbigene: <http://identifiers.org/ncbigene/> .'
puts '@prefix taxid: <http://identifiers.org/taxonomy/> .'
puts '@prefix hgnc: <http://identifiers.org/hgnc/> .'
puts '@prefix mim: <http://identifiers.org/mim/> .'
puts '@prefix mirbase: <http://identifiers.org/mirbase/> .'
puts '@prefix ensembl: <http://identifiers.org/ensembl/> .'
puts '@prefix nuc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/> .'
puts '@prefix : <http://purl.org/net/orthordf/hOP/ontology#> .'

def format_str_array(str)
  return str.split('|')
           .map { |x| "\"#{x}\"" }
           .join(" ,\n        ")
end

def format_links(str)
  str_array = []
  str.split('|').each do |a|
    if a =~ /^MIM:(\d+)$/
      str_array << "mim:#{$1}"
    elsif a =~ /^HGNC:HGNC:(\d+)$/
      str_array << "hgnc:#{$1}"
    elsif a =~ /^Ensembl:(ENSG\d+)$/
      str_array << "ensembl:#{$1}"
    elsif a =~ /^miRBase:(MI\d+)$/
      str_array << "mirbase:#{$1}"
    end
  end
  return str_array.join(" ,\n        ")
end

def filter_str(str)
  str_array = []
  str.split('|').each do |a|
    if a =~ /^MIM:(\d+)$/
    elsif a =~ /^HGNC:HGNC:(\d+)$/
    elsif a =~ /^Ensembl:(ENSG\d+)$/
    elsif a =~ /^miRBase:(MI\d+)$/
    else
      str_array << "\"#{a}\""
    end
  end
  return str_array.join(" ,\n        ")
end

def format_date(date)
  r = date.match(/^(\d{4})(\d{2})(\d{2})$/)
  return "#{r[1]}-#{r[2]}-#{r[3]}"
end

File.open(input_file, 'r') do |file|
  header = file.readline
  file.each_line do |line|
    line = line.chomp
    fields = line.split("\t")
    puts
    puts "ncbigene:#{fields[1]} a nuc:Gene ;"
    puts "    dct:identifier #{fields[1]} ;"
    puts "    rdfs:label \"#{fields[2]}\" ;"
    if fields[10] != "-"
      puts "    nuc:standard_name \"#{fields[10]}\" ;"
    end
    if fields[4] != "-"
      synonyms = format_str_array(fields[4])
      puts "    nuc:gene_synonym #{synonyms} ;"
    end
    puts "    dct:description \"#{fields[8]}\" ;"
    if fields[13] != "-"
      alternatives = format_str_array(fields[13])
      puts "    dct:alternative #{alternatives} ;"
    end
    if fields[5] != "-"
      links = format_links(fields[5])
      if links != ""
        puts "    nuc:dblink #{links} ;"
      end
    end
    puts "    :typeOfGene \"#{fields[9]}\" ;"
    if fields[12] == "O"
      puts "    :nomenclatureStatus \"official\" ;"
    elsif fields[12] == "I"
      puts "    :nomenclatureStatus \"interim\" ;"
    end
    if fields[11] != "-"
      puts "    :fullName \"#{fields[11]}\" ;"
    end
    if fields[5] != "-"
      db_xref = filter_str(fields[5])
      if db_xref != ""
        puts "    nuc:db_xref #{db_xref} ;"
      end
    end
    if fields[15] != "-"
      feature_type = format_str_array(fields[15])
      puts "    :featureType #{feature_type} ;"
    end
    puts "    :taxid taxid:#{fields[0]} ;"
    puts "    nuc:chromosome \"#{fields[6]}\" ;"
    puts "    nuc:map \"#{fields[7]}\" ;"
    date = format_date(fields[14])
    puts "    dct:modified \"#{date}\"^^xsd:date ."
  end
end
