require 'redmine'
require 'open-uri'
require 'issue'

Redmine::Plugin.register :redmine_wiki_sql do
  name 'Redmine Wiki SQL'
  author 'Rodrigo Ramalho'
  author_url 'http://www.rodrigoramalho.com/'
  description 'Allows you to run SQL queries and have them shown on your wiki in table format'
  version '0.0.1'

  Redmine::WikiFormatting::Macros.register do
    desc "Run SQL query"
    macro :sql do |obj, args, text|
       
        _sentence = args.join(",")
        _sentence = _sentence.gsub("\\(", "(")
        _sentence = _sentence.gsub("\\)", ")")
        
        result = ActiveRecord::Base.connection.select_all _sentence
        unless result.nil?
          _line = result[0]
          unless _line.nil?
            _thead = '<tr>'
            _line.each do |key,value|
              _thead << '<th>' + key.to_s + '</th>'
            end
            _thead << '</tr>'
            
            _tbody = ''
            result.each do |record|
              unless record.nil?
                _tbody << '<tr>'
                record.each do |key,value|
                  _tbody << '<td>' + textilizable(value.to_s) + '</td>'
                end
                _tbody << '</tr>'
              end 
            end
            
            text = '<table>' << _thead << _tbody << '</table>' 
                       
            text.html_safe
          else
            ''.html_safe
          end
        else
          ''.html_safe
        end
    end	
  end
	
end
