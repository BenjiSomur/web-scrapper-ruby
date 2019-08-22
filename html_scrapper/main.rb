require 'open-uri'
require 'nokogiri'
require "fileutils"


class Webscrapper

	def initialize
		@pagina = $stdin.gets.chomp
		if @pagina.include?('https')
			@pagina = @pagina.sub('https','http')
		end
		@feedback = open(@pagina)
		@html = @feedback.read
		@documento = Nokogiri::HTML(@html)
		@nombre = @documento.at_css('title').text
		FileUtils::mkdir_p @nombre
		puts 'Descargando contenido...'
		get_html
		puts 'Descargando stylesheets...'
		get_css
		puts'Descargando js...'
		get_js
		puts 'Descargando imagenes...'
		get_img
	end

	def get_html
		file_html = File.new("#{@nombre}/index.html", "w")
		file_html.puts(@html)
		file_html.close
	end

	def get_css
		nodeset = @documento.xpath('//link')
		links = nodeset.map { |element| element["href"]  }.compact
		links.each do |link|
			begin
				puts link
				if link.include?('.css')
					if link.include?('https')
						link = link.sub('https','http')
					end
					directory = get_directory(link)
					FileUtils::mkdir_p "#{@nombre}/#{directory}"
					if link.include?('https')||link.include?('http')
						@feedback = open(link)
					else
						@feedback = open(@pagina+link)
					end
					css = @feedback.read
					file_css = File.open("#{@nombre}/#{directory}#{get_nombre_archivo(link)}", "w")
					file_css.puts(css)
					file_css.close
				end
			rescue
				puts "stylesheet #{link} not found"
			end
		end
	end

	def get_js
		nodeset = @documento.xpath('//script')
		links = nodeset.map { |element| element["src"]  }.compact
		links.each do |link|
			begin
				puts link
				if link.include?('.js')
					if link.include?('https')
						link = link.sub('https','http')
					end
					directory = get_directory(link)
					FileUtils::mkdir_p "#{@nombre}/#{directory}"
					if link.include?('https')||link.include?('http')
						@feedback = open(link)
					else
						@feedback = open(@pagina+link)
					end
					js = @feedback.read
					file_js = File.open("#{@nombre}/#{directory}#{get_nombre_archivo(link)}", "w")
					file_js.puts(js)
					file_js.close
				end
			rescue
				puts "script #{link} not found"
			end
		end
	end

	def get_img
		nodeset = @documento.xpath('//img')
		links = nodeset.map { |element| element["src"]  }.compact
		links.each do |link|
			begin
				puts link
				if link.include?('https')
					link = link.sub('https', 'http')
				end
				directory = get_directory(link)
				FileUtils::mkdir_p "#{@nombre}/#{directory}"
				if link.include?('https')||link.include?('http')
					@feedback = open(link)
				else
					@feedback = open(@pagina+link)
				end
				img = @feedback.read
				file_img = File.open("#{@nombre}/#{directory}#{get_nombre_archivo(link)}", "w")
				file_img.puts(img)
				file_img.close
			rescue
				puts "image #{link} not found"
			end
		end
	end

	def get_directory(link)
		partes = link.split('/')
		nuevo_link='.'
		contador = 0
		partes.each do |element|
			contador+=1
			unless element.include?('.css')
				unless contador == partes.length
					nuevo_link += "#{element}/"
				end
			end
		end
		return nuevo_link
	end

	def get_nombre_archivo(link)
		partes = link.split('/')
		nombre=''
		contador = 0
		partes.each do |element|
			contador+=1
			if contador == partes.length
				if element.include?('?')
					partes_nombre = element.split('?')
					nombre = partes_nombre[0]
				else
					nombre = element
				end
			end
		end
		return nombre
	end
end

th = Thread.new{
	aplicacion = Webscrapper.new
}

begin
	th.join
	puts 'completado'
rescue Interrupt => i
	puts "\nFin de la ejecucion"
rescue Exception => e
	puts "\nOcurrio una excepcion #{e.message}\n #{e.backtrace.inspect}"
end
